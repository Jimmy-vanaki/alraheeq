import 'package:al_raheeq_library/app/features/audio/repository/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';

class AudioServiceController extends GetxController {
  AudioHandler? audioHandler;

  RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    try {
      // await Permission.microphone.request();
      audioHandler = await AudioService.init(
        builder: () => AudioHandlerImpl(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.dijlah.SealedNectar',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
        ),
      );
      isInitialized.value = true;
      print('AudioService initialized!');
    } catch (e) {
      print('========>>>AudioService init error: $e');
    }
  }
}
