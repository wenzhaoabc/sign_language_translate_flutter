import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_state/phone_state.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/utils/FileUtil.dart';

class PhoneUtils {
  static const MethodChannel _channel = MethodChannel('SOS_PHONE');

  static Future<bool> makePhoneCall(
      String title, String to, String content) async {
    bool repeat = getBoolAsync(Constant.sosRepeat, defaultValue: true);
    bool voicer = getBoolAsync(Constant.sosVoicer, defaultValue: true);

    final rootPath = await getApplicationDocumentsDirectory();

    var player = AudioPlayer();

    var hasFile = await FileUtil.fileExisted("sos_$title.mp3");
    if (hasFile == false) {
      var res = await dio.post('/tts',
          data: {"text": content, "voicer": voicer ? "xiaoyan" : "xiaofeng"},
          options: Options(responseType: ResponseType.bytes));
      debugPrint("res =  \n length = ${(res.data as List).length}");
      FileUtil.writeAudioToFile(Uint8List.fromList(res.data), "sos_$title.mp3");
    }

    try {
      player
          .setAudioSource(AudioSource.file("${rootPath.path}/sos_$title.mp3"));
      // player.setAndroidAudioAttributes(
      //   const AndroidAudioAttributes(
      //     contentType: AndroidAudioContentType.speech,
      //     // flags: AndroidAudioFlags.audibilityEnforced,
      //     // usage: AndroidAudioUsage.voiceCommunication,
      //   ),
      // );
    } catch (e) {
      return false;
    }
    player.setLoopMode(repeat ? LoopMode.one : LoopMode.off);

    try {
      final bool success =
          await _channel.invokeMethod('makePhoneCall', {"to": to});

      PhoneState.phoneStateStream.listen((status) {
        switch (status) {
          case PhoneStateStatus.NOTHING:
            break;
          case PhoneStateStatus.CALL_INCOMING:
            break;
          case PhoneStateStatus.CALL_STARTED:
            debugPrint("正在通话");
            // player.setAndroidAudioAttributes();
            player.play();
            break;
          case PhoneStateStatus.CALL_ENDED:
            player.stop();
            break;
          default:
            break;
        }
      });
      return success;
    } on PlatformException catch (e) {
      throw 'Unable to make phone call: ${e.message}';
    }
  }

  static Future<bool> createShortCut(
      String title, String to, String content) async {
    try {
      final bool success = await _channel.invokeMethod(
          'createShortCut', {"to": to, "content": content, "title": title});
      return success;
    } on PlatformException catch (e) {
      throw 'Unable to make phone call: ${e.message}';
    }
  }

  static Future<bool> initTTS() async {
    try {
      final bool success = await _channel.invokeMethod('initTTS');
      return success;
    } on PlatformException catch (e) {
      throw 'Unable to initTTS: ${e.message}';
    }
  }
}
