import 'dart:async';
import 'package:al_raheeq_library/app/features/audio/repository/audio_handler.dart';
import 'package:al_raheeq_library/app/features/audio/view/controller/audio_service_controller.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  AudioHandler? audioHandler;
  var isInitialized = false.obs;

  var isFullScreen = false.obs;
  var isPlaying = false.obs;
  var volume = 1.0.obs;
  var isVolumePanelVisible = false.obs;
  var position = Duration.zero.obs;
  var duration = Duration.zero.obs;

  var visualizerValues = <double>[].obs;

  Timer? _positionTimer;

  @override
  void onInit() {
    super.onInit();
    final audioServiceController = Get.find<AudioServiceController>();
    print('==>>=onInit');

    // دریافت مقدار فعلی به صورت دستی
    if (audioServiceController.isInitialized.value) {
      print('==>>=AudioServiceController isInitialized is already true');

      audioHandler = audioServiceController.audioHandler;
      isInitialized.value = true;

      print('==>>=AudioHandler set and isInitialized set to true');

      audioHandler!.playbackState.listen((playbackState) {
        final newPosition = playbackState.position;
        final newDuration =
            audioHandler!.mediaItem.value?.duration ?? Duration.zero;

        position.value = newPosition;
        duration.value = newDuration;

        isPlaying.value = playbackState.playing;
      });
    }

    // سپس برای تغییرات آینده listen می‌کنیم
    audioServiceController.isInitialized.listen((initialized) {
      print('==>>=AudioServiceController isInitialized changed: $initialized');

      if (initialized) {
        print(
            '==>>=AudioServiceController audioHandler: ${audioServiceController.audioHandler}');

        audioHandler = audioServiceController.audioHandler;
        isInitialized.value = true;

        print('==>>=AudioHandler set and isInitialized set to true');

        audioHandler!.playbackState.listen((playbackState) {
          final newPosition = playbackState.position;
          final newDuration =
              audioHandler!.mediaItem.value?.duration ?? Duration.zero;

          position.value = newPosition;
          duration.value = newDuration;

          isPlaying.value = playbackState.playing;
        });
      }
    });
  }

  // Future<void> initAudioHandler() async {
  //   audioHandler = AudioHandlerImpl();

  //   // Listen to playback state and update isPlaying
  //   audioHandler!.playbackState.listen((state) {
  //     isPlaying.value = state.playing;
  //   });

  //   // Update position and duration periodically
  //   _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
  //     if (audioHandler?.player != null) {
  //       position.value = audioHandler!.player.position;
  //       duration.value = audioHandler!.player.duration ?? Duration.zero;
  //     }
  //   });

  //   isInitialized.value = true;
  // }

  Future<void> play(
      String url, String title, String artist, String image) async {
    if (!isInitialized.value || audioHandler == null) {
      print('audioHandler not initialized!');
      return;
    }
    await audioHandler!.playFromUri(
      Uri.parse(url),
      {
        'title': title,
        'artist': artist,
        'album': 'Album Name',
        'artUri': image,
      },
    );

    updateVisualizer();
  }

  Future<void> togglePlayPause(
      String url, String title, String artist, String image) async {
    if (!isInitialized.value || audioHandler == null) return;

    if (isPlaying.value) {
      await audioHandler!.pause();
    } else {
      final currentMedia = audioHandler!.mediaItem.valueOrNull;
      if (currentMedia != null && currentMedia.id == url) {
        await audioHandler!.play();
      } else {
        await play(url, title, artist, image);
      }
    }
  }

  void setVolume(double value) {
    volume.value = value;
    if (audioHandler is AudioHandlerImpl) {
      try {
        (audioHandler as AudioHandlerImpl).setVolume(value);
      } catch (_) {}
    }
  }

  void toggleVolumePanel() {
    isVolumePanelVisible.value = !isVolumePanelVisible.value;
  }

  void seekForward() {
    if (!isInitialized.value || audioHandler == null) return;
    final newPos = position.value + const Duration(seconds: 10);
    audioHandler!.seek(newPos);
  }

  void seekBackward() {
    if (!isInitialized.value || audioHandler == null) return;
    final newPos = position.value - const Duration(seconds: 10);
    audioHandler!.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void seekTo(Duration pos) {
    if (!isInitialized.value || audioHandler == null) return;
    audioHandler!.seek(pos);
  }

  void updateVisualizer() {
    // Visualizer update logic here (to be implemented)
  }

  @override
  void onClose() {
    audioHandler?.stop();
    _positionTimer?.cancel();
    super.onClose();
  }
}
