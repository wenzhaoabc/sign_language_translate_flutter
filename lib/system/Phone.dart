import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Phone {
  static const MethodChannel _channel = MethodChannel('phone_plugin');

  static Future<void> makeCall(String phoneNumber) async {
    try {
      await _channel.invokeMethod('makeCall', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      debugPrint("Failed to make a call: '${e.message}'.");
    }
  }
}
