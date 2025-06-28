import 'package:al_raheeq_library/app/config/get_version.dart';
import 'package:al_raheeq_library/app/config/launch_url.dart';
import 'package:al_raheeq_library/app/config/share_app.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/routes/routes.dart';
import 'package:al_raheeq_library/app/features/about/view/screens/about_page.dart';
import 'package:al_raheeq_library/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:al_raheeq_library/app/features/favorite%20&%20comment/view/screens/favorite_page.dart';
import 'package:al_raheeq_library/app/features/home/view/controller/hijri_date_controller.dart';
import 'package:al_raheeq_library/app/features/home/view/controller/navigation_controller.dart';
import 'package:al_raheeq_library/app/features/setting/view/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.sliderDrawerKey,
  });
  final GlobalKey<ScaffoldState> sliderDrawerKey;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final BottmNavigationController navigationController =
        Get.put(BottmNavigationController(), permanent: true);

    final AppVersionController appVersionController =
        Get.find<AppVersionController>();

    final List<Map<String, dynamic>> drawerItemList = [
      {
        "title": 'الرئيسية',
        "icon": 'house',
        "onTap": () {
          navigationController.goToPage(0);
          sliderDrawerKey.currentState?.closeDrawer();
        }
      },

      {
        "title": 'السيرة ذاتية',
        "icon": 'clipboard-user',
        "onTap": () {
          Get.to(AboutPage(
            fileName: 'about1.htm',
          ));
        }
      },
      {
        "title": 'حول التطبيق',
        "icon": 'info',
        "onTap": () {
          Get.to(AboutPage(
            fileName: 'about2.htm',
          ));
        }
      },
      // {"title": 'المفضلة', "icon": 'star', "onTap": () {}},
      {
        "title": 'الاعدادات',
        "icon": 'settings',
        "onTap": () {
          Get.toNamed(
            Routes.setting,
          );
        }
      },
      {
        "title": 'سياسية الخصوصية',
        "icon": 'confidential-discussion',
        "onTap": () {
          urlLauncher('https://library.yaqoobi.net/privacy_policy_lib_yq.html');
        }
      },
      {
        "title": 'المفضلة والاشارات المرجعية',
        "icon": 'wishlist-star',
        "onTap": () {
          FavoriteController favoriteController;
          if (Get.isRegistered<FavoriteController>()) {
            favoriteController = Get.find<FavoriteController>();
          } else {
            favoriteController = Get.put(FavoriteController());
          }

          favoriteController.loadBookmarks();
          favoriteController.loadComments();
          Get.to(
            FavoritePage(),
          );
        }
      },
      {
        "title": 'مشاركة التطبيق',
        "icon": 'share-square',
        "onTap": () {
          shareApp(context);
        }
      },
    ];
    final HijriDateController hijriDateController =
        Get.put(HijriDateController());
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Image.asset(
              'assets/images/drawer_header.png',
            ),
          ),
          Obx(() => Text(
                hijriDateController.hijriDate.value,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              )),
          ...List.generate(
            drawerItemList.length,
            (index) {
              return index < drawerItemList.length - 1
                  ? drawerItemWidget(
                      title: drawerItemList[index]['title'],
                      icon: drawerItemList[index]['icon'],
                      onTap: drawerItemList[index]['onTap'],
                      totalItems: drawerItemList.length,
                      tag: index,
                      context: context,
                    )
                  : Column(
                      children: [
                        const Divider(),
                        drawerItemWidget(
                          title: drawerItemList[index]['title'],
                          icon: drawerItemList[index]['icon'],
                          onTap: drawerItemList[index]['onTap'],
                          totalItems: drawerItemList.length,
                          tag: index,
                          context: context,
                        ),
                      ],
                    );
            },
          ),
          Obx(
            () => ListTile(
              leading: SvgPicture.asset(
                'assets/svgs/moon.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
              title: const Text(
                'تبديل الوضع الليلي',
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: settingsController.isDarkMode.value,
                  onChanged: (value) {
                    settingsController.isDarkMode.value = value;

                    final ThemeColorScheme themeToUse = value
                        ? settingsController.darkColorScheme
                        : settingsController.selectedColorScheme.value;

                    print('🌗 سوئیچ شد به حالت: ${value ? "تاریک" : "روشن"}');
                    print('🎯 رنگ انتخاب‌شده برای تم:');
                    print('🔹 primary: ${themeToUse.primary.value}');
                    print('🔹 onPrimary: ${themeToUse.onPrimary.value}');
                    print('🔹 surface: ${themeToUse.surface.value}');

                    settingsController.setTheme(
                      settingsController.themeColorSchemes[0],
                      isDarkMode: value,
                      themeindex: settingsController.themeIndex.value,
                    );

                    Constants.localStorage.write('isDarkMode', value);
                  },
                ),
              ),
              onTap: () {},
            ),
          ),

          // Spacer(),
          Column(
            children: [
              const Gap(100),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'الاصدار: ',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: appVersionController.version.value,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(5),
              ZoomTapAnimation(
                onTap: () {
                  urlLauncher('https://dijlah.org');
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Powered by ',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'DIjlah IT',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile drawerItemWidget({
    required String title,
    required String icon,
    required int tag,
    required int totalItems,
    required Function() onTap,
    required BuildContext context,
  }) {
    bool isLastItem = tag == totalItems - 1;
    return ListTile(
      leading: SvgPicture.asset(
        'assets/svgs/$icon.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      trailing: !isLastItem
          ? SvgPicture.asset(
              'assets/svgs/angle-left.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            )
          : const SizedBox(),
      onTap: onTap,
    );
  }
}
