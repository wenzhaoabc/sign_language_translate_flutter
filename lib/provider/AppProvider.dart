import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';

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

  bool _isInLargeFont = false;

  bool get inLargeFont => _isInLargeFont;

  void setFontLarge(bool large) {
    _isInLargeFont = large;
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

  // SOS - 紧急呼救项
  List<SOSItem> _sosItemList = [];

  List<SOSItem> get sosItemList {
    if (_sosItemList.isEmpty) {
      List<String>? strList = getStringListAsync(Constant.sosList);
      if (strList == null) {
        _sosItemList.addAll([
          SOSItem('抢劫遇险', '110中心你好，我是一名聋哑人士，以下语音为文本合成，我现在顶山公寓室内遭遇抢劫情况，请速来救援',
              '110'),
          SOSItem(
              '测试项', '紧急中心你好，我是一名聋哑人士，我现在户外遭遇紧急情况，我在乞灵山山顶，请速来救援', '18105022730')
        ]);
      } else {
        for (var value in strList) {
          var jsonItem = jsonDecode(value);
          SOSItem item = SOSItem.fromJson(jsonItem);
          _sosItemList.add(item);
        }
      }
    }
    return _sosItemList;
  }

  void addSosItem(SOSItem item) {
    _sosItemList.add(item);
    notifyListeners();
  }

  void deleteSosItem(String title) {
    _sosItemList.removeWhere((element) => element.title == title);
    notifyListeners();
  }

  // 用户个人信息
  User? _user;

  User? get currentUser => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // 电话呼救
  bool _phoneIsRepeat = false;

  bool get phoneIsRepeat => _phoneIsRepeat;

  void setPhoneIsRepeat(bool repeat) {
    if (repeat != _phoneIsRepeat) {
      _phoneIsRepeat = repeat;
      notifyListeners();
      setValue(Constant.sosRepeat, repeat);
    }
  }

  // 险情感知
  bool _detectSensor = false;

  bool get detectSensor => _detectSensor;

  void setDetectSensor(bool detect) {
    if (detect != _detectSensor) {
      _detectSensor = detect;
      notifyListeners();
      setValue(Constant.detectDevice, detect);
    }
  }

  List<SMSItem> _smsList = [];

  List<SMSItem> get smsList {
    if (_smsList.isEmpty) {
      _smsList.addAll([
        SMSItem(
          '测试项',
          '紧急救援中心你好，我是一名聋哑人士，我在户外遇险，腿部受伤，丧失活动能力，我的位置是${Constant.smsLocation}，请速来救援。',
          '18105022730',
        ),
      ]);
    }
    return _smsList;
  }

  void addSMSItem(SMSItem item) {
    _smsList.add(item);
    notifyListeners();
  }

  void deleteSMSItem(String title) {
    _smsList.removeWhere((element) => element.title == title);
    notifyListeners();
  }
}
