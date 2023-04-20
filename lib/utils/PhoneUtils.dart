import 'package:flutter/services.dart';

class PhoneUtils {
  static const MethodChannel _channel = MethodChannel('sos_phone');

  static Future<bool> makePhoneCall(String to, String content) async {
    try {
      final bool success = await _channel
          .invokeMethod('makePhoneCall', {"to": to, "content": content});
      return success;
    } on PlatformException catch (e) {
      throw 'Unable to make phone call: ${e.message}';
    }
  }
}
