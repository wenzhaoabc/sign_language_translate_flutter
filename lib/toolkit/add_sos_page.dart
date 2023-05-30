import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class AddSOS extends StatefulWidget {
  const AddSOS({Key? key}) : super(key: key);

  @override
  State<AddSOS> createState() => _AddSOSState();
}

class _AddSOSState extends State<AddSOS> {
  bool inDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  String? to, title, content;
  List<SOSItem> SosItemList = [];

  // 初始化紧急呼救数据列表
  void initSosList() {
    SosItemList = Provider.of<AppProvider>(context,listen: false).sosItemList;
    return;
  }

  void popToLast() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: PageBgStyles.BeHappyBimgDecoration,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('添加'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            // scrolledUnderElevation: 1,
            bottomOpacity: 1,
            leading: InkWell(
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          body: Neumorphic(
            style: const NeumorphicStyle(depth: 2, color: Colours.d_bg),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                _getTagInput('名称', '取个标题', (t) => title = t),
                const SizedBox(height: 20),
                _getTagInput('TO', '呼叫的手机号', (t) => to = t),
                const SizedBox(height: 20),
                _getTextArea(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    style: const NeumorphicStyle(depth: 3, intensity: 0.8),
                    pressed: true,
                    onPressed: () {
                      initSosList();

                      for (var value1 in SosItemList) {
                        if (value1.title == title) {
                          MyToast.showToast(msg: '名称重复', type: 'error');
                          return;
                        }
                      }
                      if (to.isEmptyOrNull ||
                          title.isEmptyOrNull ||
                          content.isEmptyOrNull) {
                        MyToast.showToast(msg: '内容不可为空', type: 'warning');
                        return;
                      }
                      Provider.of<AppProvider>(context, listen: false)
                          .addSosItem(SOSItem(title!, content!, to!));
                      popToLast();
                      return;
                    },
                    child: const Text(
                      '添加',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ));
  }

  Widget _getTagInput(String tag, String hintText, Function(String) function) {
    var textColor = !inDark() ? Colors.black : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag, style: TextStyle(color: textColor, fontSize: 16)),
        SizedBox(height: 10),
        TextField(
          cursorColor: Colors.black,
          cursorWidth: 2,
          onChanged: (text) => function(text),
          style: const TextStyle(fontSize: 16),
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            hintText: hintText,
          ),
        )
      ],
    );
  }

  Widget _getTextArea() {
    var textColor = !inDark() ? Colors.black : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('求救内容', style: TextStyle(color: textColor, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          maxLines: 5,
          onChanged: (text) {
            content = text;
          },
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 16),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('[\[\]\(\)\{\}]'))
          ],
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              hintText: '请输入求救内容'),
        )
      ],
    );
  }
}
