import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
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
    List<String>? strList = getStringListAsync(Constant.sosList);
    if (strList == null || strList.isEmpty) {
      return;
    }
    debugPrint("添加SOS : strList = $strList");
    for (var value in strList) {
      var jsonItem = jsonDecode(value);
      SOSItem item = SOSItem.fromJson(jsonItem);
      SosItemList.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(Constant.bg_img_url),
            // image: AssetImage("images/R_C.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('添加'),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                    onPressed: () async {
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
                      SosItemList.add(SOSItem(title!, content!, to!));
                      List<String> strList = List.generate(SosItemList.length,
                          (index) => SosItemList.elementAt(index).toString());
                      await setValue(Constant.sosList, strList);
                      debugPrint("add new SOSItem after: $strList");
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
        TextField(
          cursorColor: Colors.black,
          cursorWidth: 2,
          onChanged: (text) => function(text),
          style: const TextStyle(fontSize: 16),
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            border:
                const UnderlineInputBorder(borderSide: BorderSide(width: 1)),
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
        const SizedBox(height: 5),
        TextField(
          maxLines: 5,
          onChanged: (text) {
            content = text;
          },
          style: const TextStyle(fontSize: 16),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('[\[\]\(\)\{\}]'))
          ],
          decoration: const InputDecoration(
            // contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            border: OutlineInputBorder(),
          ),
        )
      ],
    );
  }
}
