import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToast {
  static Color _getColor(String type) {
    switch (type) {
      case 'error':
        return Colors.redAccent;
      case 'warning':
        return Colors.amberAccent;
      case 'success':
        return Colors.greenAccent;
      case 'default':
      default:
        return Colors.blueAccent;
    }
  }

  static void showToast({required String msg, String type = 'default'}) {
    Fluttertoast.showToast(msg: msg, textColor: _getColor(type));
  }
}
