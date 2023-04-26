// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sign_language/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  Socket socket = io("ws://127.0.0.1:5002");
  socket.onConnect((_) {
    print("object");
    socket.emit('message', "test");
  });
}
