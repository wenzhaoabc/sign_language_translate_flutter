import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/res/constant.dart';

class PhoneUtils {
  static const MethodChannel _channel = MethodChannel('SOS_PHONE');

  static Future<bool> makePhoneCall(String to, String content) async {
    try {
      bool repeat = getBoolAsync(Constant.sosRepeat, defaultValue: true);
      bool voicer = getBoolAsync(Constant.sosVoicer, defaultValue: true);
      final bool success = await _channel.invokeMethod('makePhoneCall',
          {"to": to, "content": content, "repeat": repeat, "voicer": voicer});
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
}
