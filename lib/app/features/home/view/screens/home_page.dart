import 'package:al_raheeq_library/app/config/functions.dart';
import 'package:al_raheeq_library/app/core/common/widgets/audio_visualizer.dart';
import 'package:al_raheeq_library/app/features/audio/view/controller/audio_controller.dart';
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
        width: Get.width,
        height: Get.height,
        child: Stack(
          children: [
            Obx(
              () => PageView(
                controller: navigationController.pageController.value,
                onPageChanged: navigationController.animatedToPage,
                physics: const BouncingScrollPhysics(),
                children: [
                  const LibraryPage(),
                  const CategoryPage(),
                  const DownloadPage(),
                  const BookListPage(),
                  const FavoritePage(),
                ],
              ),
            ),

            // Obx(
            //   () => AnimatedPositioned(
            //     bottom: 0,
            //     left: 0,
            //     right: 0,
            //     duration: Duration(milliseconds: 300),
            //     child: AnimatedContainer(
            //       height: audioController.isFullScreen.value
            //           ? 62
            //           : (Get.height - 145),
            //       duration: Duration(milliseconds: 300),
            //       padding: EdgeInsets.symmetric(horizontal: 10),
            //       decoration: BoxDecoration(
            //         color: Theme.of(context).colorScheme.onPrimary,
            //         borderRadius:
            //             BorderRadius.vertical(top: Radius.circular(20)),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.black.withOpacity(0.1),
            //             blurRadius: 10,
            //           ),
            //         ],
            //       ),
            //       child: GetBuilder<AudioController>(
            //         init: AudioController(),
            //         builder: (controller) => Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             // دکمه پخش/مکث
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 ZoomTapAnimation(
            //                   onTap: () {
            //                     audioController.isFullScreen.value =
            //                         !audioController.isFullScreen.value;
            //                   },
            //                   child: SvgPicture.asset(
            //                     'assets/svgs/full-screen.svg',
            //                     colorFilter: ColorFilter.mode(
            //                       Theme.of(context).colorScheme.primary,
            //                       BlendMode.srcIn,
            //                     ),
            //                     width: 20,
            //                     height: 20,
            //                   ),
            //                 ),
            //                 Obx(() {
            //                   return Column(
            //                     children: [
            //                       SliderTheme(
            //                         data: SliderTheme.of(context).copyWith(
            //                           trackHeight: 1.0,
            //                           thumbShape: const RoundSliderThumbShape(
            //                               enabledThumbRadius: 6.0),
            //                         ),
            //                         child: Slider(
            //                           value: controller.position.value.inSeconds
            //                               .toDouble(),
            //                           min: 0.0,
            //                           max: controller.duration.value.inSeconds
            //                               .toDouble(),
            //                           onChanged: (value) {
            //                             controller.seekTo(
            //                                 Duration(seconds: value.toInt()));
            //                           },
            //                           activeColor:
            //                               Theme.of(context).colorScheme.primary,
            //                           inactiveColor:
            //                               Colors.white.withOpacity(0.5),
            //                         ),
            //                       ),
            //                       Row(
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.spaceBetween,
            //                         children: [
            //                           Text(
            //                             formatDuration(
            //                                 controller.position.value),
            //                             style: TextStyle(
            //                                 color: Theme.of(context)
            //                                     .colorScheme
            //                                     .primary,
            //                                 fontSize: 10),
            //                           ),
            //                           Text(
            //                             formatDuration(
            //                                 controller.duration.value),
            //                             style: TextStyle(
            //                                 color: Theme.of(context)
            //                                     .colorScheme
            //                                     .primary,
            //                                 fontSize: 10),
            //                           ),
            //                         ],
            //                       ),
            //                     ],
            //                   );
            //                 }),
            //                 const Gap(20),
            //                 // دکمه پخش و توقف
            //                 ZoomTapAnimation(
            //                   onTap: () {
            //                     controller.togglePlayPause(
            //                         "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
            //                   },
            //                   child: Obx(() => SvgPicture.asset(
            //                         controller.isPlaying.value
            //                             ? 'assets/svgs/pause-circle.svg'
            //                             : 'assets/svgs/play-circle.svg',
            //                         colorFilter: ColorFilter.mode(
            //                           Theme.of(context).colorScheme.primary,
            //                           BlendMode.srcIn,
            //                         ),
            //                         width: 35,
            //                         height: 35,
            //                       )),
            //                 ),
            //                 const Gap(20),
            //                 ZoomTapAnimation(
            //                   onTap: () {
            //                     controller.seekForward();
            //                   },
            //                   child: SvgPicture.asset(
            //                     'assets/svgs/time-forward-ten2.svg',
            //                     colorFilter: ColorFilter.mode(
            //                       Theme.of(context).colorScheme.primary,
            //                       BlendMode.srcIn,
            //                     ),
            //                     width: 20,
            //                     height: 20,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: CostumBottomNavigationBar(),
    );
  }
}
