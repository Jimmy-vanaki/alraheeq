import 'package:al_raheeq_library/app/features/home/view/controller/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CostumBottomNavigationBar extends StatelessWidget {
  CostumBottomNavigationBar({
    super.key,
  });

  final BottmNavigationController navigationController = Get.find<BottmNavigationController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width - 80,
      height: 60,
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomAppBarItem(
            icon: 'books',
            page: 0,
            context: context,
            selectIcon: 'fill/books',
            title: 'الرئيسية',
          ),
          _bottomAppBarItem(
            icon: 'category-alt',
            page: 1,
            context: context,
            selectIcon: 'fill/category-alt',
            title: 'تصانيف',
          ),
          _bottomAppBarItem(
            icon: 'arrow-down-to-square',
            page: 2,
            context: context,
            selectIcon: 'fill/arrow-down-to-square',
            title: 'تحميل',
          ),
          _bottomAppBarItem(
            icon: 'book-alt',
            page: 3,
            context: context,
            selectIcon: 'fill/book-alt',
            title: 'كتب',
          ),
          _bottomAppBarItem(
            icon: 'wishlist-star',
            page: 4,
            context: context,
            selectIcon: 'fill/wishlist-star',
            title: 'اشارات',
          ),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem({
    required String icon,
    required String title,
    required String selectIcon,
    required int page,
    required BuildContext context,
  }) {
    return ZoomTapAnimation(
      onTap: () {
        navigationController.goToPage(page);
      },
      child: Obx(
        () => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/${navigationController.currentPage.value == page ? selectIcon : icon}.svg',
                  colorFilter: ColorFilter.mode(
                    navigationController.currentPage.value == page
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(120),
                    BlendMode.srcIn,
                  ),
                  width: 25,
                  height: 25,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 8,
                    color: navigationController.currentPage.value == page
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(120),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
