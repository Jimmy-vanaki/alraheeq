import 'package:al_raheeq_library/app/features/ai_support/view/screens/support_page.dart';
import 'package:al_raheeq_library/app/features/download/view/screens/download_page.dart';
import 'package:al_raheeq_library/app/features/favorite%20&%20comment/view/screens/favorite_page.dart';
import 'package:al_raheeq_library/app/features/home/view/widgets/custom_drawer.dart';
import 'package:al_raheeq_library/app/features/home/view/controller/navigation_controller.dart';
import 'package:al_raheeq_library/app/features/bookList/view/screens/book_list_page.dart';
import 'package:al_raheeq_library/app/features/home/view/widgets/bottom_navigation_bar.dart';
import 'package:al_raheeq_library/app/features/category/view/screens/category_page.dart';
import 'package:al_raheeq_library/app/features/library/view/screens/library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final size = MediaQuery.of(context).size;
    final BottmNavigationController navigationController =
        Get.find<BottmNavigationController>();
    // final AudioController audioController =
    //     Get.put(AudioController(), permanent: true);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            ZoomTapAnimation(
              onTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
              child: SvgPicture.asset(
                'assets/svgs/menu-burger.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Gap(10),
            Text(
              "الرحيق المختوم",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontFamily: 'SegoeUI',
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        shadowColor: Colors.black26,
        leading: null,
        actions: [
          Image.asset(
            'assets/images/co-app-1.png',
            width: 40,
            height: 40,
          ),
        ],
      ),
      drawer: CustomDrawer(
        sliderDrawerKey: scaffoldKey,
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Obx(
              () => PageView(
                controller: navigationController.pageController.value,
                onPageChanged: navigationController.animatedToPage,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const LibraryPage(),
                  const CategoryPage(),
                  const DownloadPage(),
                  const BookListPage(),
                  // const FavoritePage(),
                  const SupportPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CostumBottomNavigationBar(),
    );
  }
}
