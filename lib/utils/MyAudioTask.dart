import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/res/constant.dart';

class MyAudioTask extends BackgroundAudioTask {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // 初始化音频播放器
    var str = getStringAsync(Constant.sosfilePath);
    await _audioPlayer.setAudioSource(AudioSource.file(str));
    await _audioPlayer.setUrl('url_to_audio_file');
    await _audioPlayer.play();

    // 更新播放状态到前台界面
    // AudioServiceBackground.setState(
    //   controls: [MediaControl.pause, MediaControl.stop],
    //   playing: true,
    // );
  }

  @override
  Future<void> onStop() async {
    // 停止音频播放并释放资源
    await _audioPlayer.stop();
    await _audioPlayer.dispose();

    // 更新播放状态到前台界面
    AudioServiceBackground.setState(
      controls: [],
      playing: false,
    );

    // 关闭音频服务
    await super.onStop();
  }

  @override
  Future<void> onPlay() async {
    // 恢复音频播放
    await _audioPlayer.play();
    AudioServiceBackground.setState(playing: true);
  }

  @override
  Future<void> onPause() async {
    // 暂停音频播放
    await _audioPlayer.pause();
    AudioServiceBackground.setState(playing: false);
  }

// 其他音频控制方法的实现，例如 onSkipToNext、onSkipToPrevious 等
}
