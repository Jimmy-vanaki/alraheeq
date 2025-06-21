import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioHandlerImpl extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;
  AudioHandlerImpl() {
    // اتصال مستقیم جریان رویدادهای پخش به playbackState
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // مقداردهی اولیه mediaItem با یک آیتم خالی (اختیاری)
    mediaItem.add(const MediaItem(
      id: '',
      title: 'Unknown',
      artist: '',
      album: '',
    ));
  }
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  // بارگذاری و پخش از URL به همراه آپدیت متادیتا
  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    try {
      await _player.stop();
      final duration = await _player.setAudioSource(AudioSource.uri(uri));
      if (duration == null) {
        throw Exception('Unsupported audio format or broken URL');
      }

      // اطلاعات متادیتا از extras دریافت می‌شود
      final title = extras?['title'] ?? 'Unknown Title';
      final artist = extras?['artist'] ?? 'Unknown Artist';
      final album = extras?['album'] ?? '';
      final artUriString = extras?['artUri'] ?? '';

      mediaItem.add(
        MediaItem(
          id: uri.toString(),
          title: title,
          artist: artist,
          album: album,
          duration: duration,
          artUri: artUriString.isNotEmpty ? Uri.parse(artUriString) : null,
          extras: {
            'url': uri.toString(),
          },
        ),
      );

      await _player.play();
    } catch (e) {
      print('Error in playFromUri: $e');
      rethrow;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  // تبدیل رویداد پخش just_audio به PlaybackState مورد نیاز audio_service
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
