import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/constant.dart';

class AudioUtil {
  static var player = AudioPlayer();

  static void playTextAudio(String content) async {
    bool voicer = getBoolAsync(Constant.sosVoicer, defaultValue: true);
    var res = await dio.post('/tts',
        data: {"text": content, "voicer": voicer ? "xiaoyan" : "xiaofeng"},
        options: Options(responseType: ResponseType.bytes));
    debugPrint(res.data.runtimeType.toString());
    // Uint8List.fromList(res.data);
    // var list_bytes = List.from(res.data);
    player.setAudioSource(MyCustomSource(res.data));
    player.play();
  }
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;

  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mp3',
    );
  }
}
