import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language/res/colours.dart';

class AppProvider extends ChangeNotifier {
  TextStyle _textStyle = const TextStyle(fontSize: 20, color: Colours.text);
  TextStyle _hintTextStyle = const TextStyle(
      fontSize: 14, color: Colours.text, textBaseline: TextBaseline.alphabetic);
  TextStyle _sosTextStyle = const TextStyle(fontSize: 18, color: Colours.text);

  TextStyle get sosTextStyle => _sosTextStyle;

  TextStyle get hintTextStyle => _hintTextStyle;

  TextStyle get textStyle => _textStyle;

  double _normalFontSize = 20;

  double get normalFontSize => _normalFontSize;

  double _smallFontSize = 16;

  double get smallFontSize => _smallFontSize;

  void setFontLarge(bool large) {
    double fontSize = large ? 24 : 20;
    double hintFontSize = large ? 18 : 14;
    double sosFontSize = large ? 22 : 18;
    _normalFontSize = large ? 24 : 20;
    _smallFontSize = large ? 20 : 16;
    _textStyle = TextStyle(fontSize: fontSize, color: Colors.black);
    _hintTextStyle = TextStyle(
        fontSize: hintFontSize,
        color: Colors.black,
        textBaseline: TextBaseline.alphabetic);
    _sosTextStyle = TextStyle(fontSize: sosFontSize, color: Colors.black);
  }
}
