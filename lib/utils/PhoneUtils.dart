import 'dart:ffi';
import 'dart:isolate';

import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';

// import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/toolkit/xfyy/utils/xf_socket.dart';
import 'package:sign_language/utils/FileUtil.dart';
import 'package:url_launcher/url_launcher.dart';

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
      player.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.audibilityEnforced,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
      );
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

  static Future<bool> makePhoneCall2(String to) async {
    try {
      var res = await _channel.invokeMethod('makePhoneCall', {"to": to});
      return res;
    } on PlatformException catch (e) {
      throw 'Unable to initTTS: ${e.message}';
    }
  }

  static Future<bool> makePhoneCallPlayVoice(String to, String content) async {
    try {
      // var res = await
      if (true) {
        final FlutterSoundPlayer playerModule = FlutterSoundPlayer();
        await playerModule.closePlayer();
        await playerModule.openPlayer();
        await playerModule
            .setSubscriptionDuration(const Duration(milliseconds: 10));

        XfSocket.connect(content, onFilePath: (path) {
          _channel.invokeMethod('makePhoneCall', {"to": to});
          PhoneState.phoneStateStream.listen((event) {
            if (event == PhoneStateStatus.CALL_STARTED) {
              playerModule.startPlayer(fromURI: path);
            } else if (event == PhoneStateStatus.CALL_ENDED) {
              playerModule.closePlayer();
            }
          });
        });
      }
      return true;
      // return res;
    } on PlatformException catch (e) {
      debugPrint("method channel 错误");
      return false;
    }
  }

  static Future<bool> makePhoneCallWhileAudio(String to, String content) async {
    bool repeat = getBoolAsync(Constant.sosRepeat, defaultValue: true);
    if (repeat) {
      content = "$content。$content。$content。";
    }
    // var player = AudioPlayer();
    // player.setAndroidAudioAttributes(
    //   const AndroidAudioAttributes(
    //     contentType: AndroidAudioContentType.speech,
    //     flags: AndroidAudioFlags.audibilityEnforced,
    //     usage: AndroidAudioUsage.voiceCommunication,
    //   ),
    // );
    XfSocket.connect(content, onFilePath: (path) async {
      // player.setAudioSource(AudioSource.file(path));
      // await player.play();
      Isolate.spawn(PlayM, path);
      _channel.invokeMethod(
          'makePhoneCall', {"to": to, "path": path, "content": content});
    });
    // Future.microtask(() => player.play());
    // Isolate.run(() => player.play());

    /*PhoneState.phoneStateStream.listen((event) async {
      debugPrint("event = $event");
      switch (event) {
        case PhoneStateStatus.CALL_STARTED:
          {
            debugPrint("正在通话");
            await player.play();
            break;
          }
        case PhoneStateStatus.CALL_ENDED:
          {
            debugPrint("正在挂断");
            player.stop();
            break;
          }
        default:
          break;
      }
    });*/
    return true;
  }

  static void PlayM(String filePath) {
    WidgetsFlutterBinding.ensureInitialized();
    var player = AudioPlayer();
    player.setAndroidAudioAttributes(
      const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.audibilityEnforced,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
    );
    player.setAudioSource(AudioSource.file(filePath));
    player.play();
  }

  // void _play(String path) async {
  //   await playerModule.startPlayer(fromURI: path);
  // }

  static Future<bool> sendSOSMessage(String to, String content) async {
    int locationIndex = content.indexOf(Constant.smsLocation);
    debugPrint("to = $to : content = $content");

    if (locationIndex >= 0) {
      // Location location = Location();
      //
      // bool _serviceEnabled;
      // PermissionStatus _permissionGranted;
      // LocationData _locationData;

      // _serviceEnabled = await location.serviceEnabled();
      // if (!_serviceEnabled) {
      //   _serviceEnabled = await location.requestService();
      //   if (!_serviceEnabled) {
      //     return false;
      //   }
      // }

      // _permissionGranted = await location.hasPermission();
      // if (_permissionGranted == PermissionStatus.denied) {
      //   _permissionGranted = await location.requestPermission();
      //   if (_permissionGranted != PermissionStatus.granted) {
      //     return false;
      //   }
      // }
      // _locationData = await location.getLocation();
      var loper = await Permission.location.request();
      if (loper.isDenied) {
        return false;
      }

      Map<Object?, Object?> res = await _channel.invokeMethod('getLocation');
      debugPrint(res.toString());

      String locationStr =
          "经度 : ${res['lon'] ?? 122.3}，维度 : ${res['lat'] ?? 23.34}";

      content = content.substring(0, locationIndex) +
          locationStr +
          content.substring(locationIndex + Constant.smsLocation.length);
    }

    debugPrint("发送文本 $content");

    var smsPer = await Permission.sms.request();
    if (smsPer.isDenied) {
      return false;
    }

    try {
      // var res = await _channel
      //     .invokeMethod("sendSOSMessage", {"to": to, "content": content});

      var smsLaunchUri = Uri(
        scheme: 'sms',
        path: '+86$to',
        query: encodeQueryParameters(<String, String>{
          'body': content,
        }),

        /// 注意：sms采用query
        // queryParameters: <String, dynamic>{
        //   'body': Uri.encodeComponent(content),
        // },
      );
      debugPrint(smsLaunchUri.toString());
      // Uri.encodeFull(smsLaunchUri);
      launchUrl(smsLaunchUri);
      // await sendSMS(message: content, recipients: [to]);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
