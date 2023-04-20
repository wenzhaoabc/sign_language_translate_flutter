// 创建一个新文件 phone_state_listener.dart，并添加以下代码
import 'dart:async';
import 'package:flutter/services.dart';

class PhoneStateListener {
  static const EventChannel _channel = const EventChannel('phone_state');

  Stream get phoneStateStream => _channel.receiveBroadcastStream();
}
