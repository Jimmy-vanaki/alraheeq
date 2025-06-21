import 'package:al_raheeq_library/app/features/audio/view/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioVisualizer extends StatelessWidget {
  final controller = Get.put(AudioController());

  AudioVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: controller.visualizerValues.map((value) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: 4,
            height: value,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      );
    });
  }
}
