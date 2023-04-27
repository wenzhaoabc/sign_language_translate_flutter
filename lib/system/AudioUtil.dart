import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioUtil {
  static const MethodChannel _channel = MethodChannel('VOICE_AUDIO');
  static Future<void> playText(String content) async {
    try {
      await _channel.invokeMethod('textToSpeech', {'content': content});
    } on PlatformException catch (e) {
      debugPrint("Failed to play text: '${e.message}'.");
    }
  }
}
