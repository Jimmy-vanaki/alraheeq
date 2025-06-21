import 'package:al_raheeq_library/app/config/functions.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/common/widgets/audio_visualizer.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/audio/repository/audio_handler.dart';
import 'package:al_raheeq_library/app/features/audio/view/controller/audio_controller.dart';
import 'package:audio_service/audio_service.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AudioBook extends StatelessWidget {
  final Map book;
  const AudioBook({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final audioController = Get.put(AudioController());
    double containerHeight = Get.height * 0.8;
    double remainingHeight = containerHeight - 536;

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 20,
              child: Container(
                decoration: Constants.containerBoxDecoration(context),
                padding: EdgeInsets.all(7),
                width: Get.width * 0.9,
                height: Get.height * 0.8,
              ),
            ),
            Positioned(
              top: 60,
              child: SizedBox(
                width: Get.width * 0.85,
                child: Column(
                  children: [
                    Hero(
                      tag: 'book-image-${book['id']}',
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: 200,
                        height: 300,
                        imageUrl: book['img'] ?? '',
                        placeholder: (context, url) => const CustomLoading(),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/not.jpg',
                          fit: BoxFit.cover,
                          width: 200,
                          height: 300,
                        ),
                      ),
                    ),
                    const Gap(5),
                    Text(
                      book['title'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(5),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: remainingHeight,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          book['description'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                    const Gap(20),
                    Center(
                      child: GetBuilder<AudioController>(
                        init: AudioController(),
                        builder: (controller) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              child: AudioVisualizer(),
                            ),
                            const Gap(20),
                            Obx(
                              () {
                                return Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 1.0,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6.0),
                                      ),
                                      child: Slider(
                                        value: controller
                                            .position.value.inSeconds
                                            .toDouble(),
                                        min: 0.0,
                                        max: controller.duration.value.inSeconds
                                            .toDouble(),
                                        onChanged: (value) {
                                          controller.seekTo(
                                              Duration(seconds: value.toInt()));
                                        },
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        inactiveColor:
                                            Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatDuration(
                                              controller.position.value),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 10),
                                        ),
                                        Text(
                                          formatDuration(
                                              controller.duration.value),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            const Gap(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Gap(20), 
                                ZoomTapAnimation(
                                  onTap: () {
                                    controller.toggleVolumePanel();
                                  },
                                  child: SvgPicture.asset(
                                    'assets/svgs/volume-down.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                                const Gap(30),
                                ZoomTapAnimation(
                                  onTap: () {
                                    controller.seekBackward();
                                  },
                                  child: SvgPicture.asset(
                                    'assets/svgs/time-forward-ten.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                                const Gap(20),
                                Obx(
                                  () => Expanded(
                                    child: Center(
                                      child: ZoomTapAnimation(
                                        onTap: () async {
                                          controller.togglePlayPause(
                                              book['sound_url'],
                                              book['title'],
                                              book['writer'],
                                              book['img']);
                                        },
                                        child: SvgPicture.asset(
                                          controller.isPlaying.value
                                              ? 'assets/svgs/pause-circle.svg'
                                              : 'assets/svgs/play-circle.svg',
                                          colorFilter: ColorFilter.mode(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            BlendMode.srcIn,
                                          ),
                                          width: 35,
                                          height: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(20),
                                ZoomTapAnimation(
                                  onTap: () {
                                    controller.seekForward();
                                  },
                                  child: SvgPicture.asset(
                                    'assets/svgs/time-forward-ten2.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                                const Gap(30),
                                ZoomTapAnimation(
                                  onTap: () {},
                                  child: SvgPicture.asset(
                                    'assets/svgs/arrows-repeat.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                                const Gap(20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Positioned(
                bottom: 110,
                right: 40,
                child: AnimatedOpacity(
                  opacity:
                      audioController.isVolumePanelVisible.value ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: audioController.isVolumePanelVisible.value
                      ? AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          color: Theme.of(context).colorScheme.primary,
                          // padding: EdgeInsets.all(20),
                          width: 50,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RotatedBox(
                                quarterTurns: 1,
                                child: Slider(
                                  value: audioController.volume.value,
                                  onChanged: audioController.setVolume,
                                  min: 0.0,
                                  max: 1.0,
                                  activeColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  inactiveColor: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
