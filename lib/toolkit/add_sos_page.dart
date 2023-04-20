import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';
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

  SOSItem? newItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('添加'),
      ),
      body: Neumorphic(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          children: [
            _getTagInput('名称', '取个标题', (title) => newItem?.title = title),
            const SizedBox(height: 20),
            _getTagInput('TO', '呼叫的手机号', (to) => newItem?.to = to),
            const SizedBox(height: 20),
            _getTextArea(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: NeumorphicButton(
                style: const NeumorphicStyle(depth: 3, intensity: 0.8),
                pressed: true,
                onPressed: () {
                  final str = getStringAsync('SOS');
                  final json = jsonDecode(str);
                  List<dynamic> tempList = json as List;
                  List<SOSItem> sosList = [];
                  for (var value in tempList) {
                    sosList.add(SOSItem.fromJson(value));
                  }
                  bool cont = false;
                  for (var value1 in sosList) {
                    if (value1.title == newItem?.title) {
                      MyToast.showToast(msg: '名称重复', type: 'error');
                      cont = true;
                      break;
                    }
                  }
                  if (cont == false) {
                    if (newItem == null ||
                        newItem!.to.isEmptyOrNull ||
                        newItem!.title.isEmptyOrNull ||
                        newItem!.content.isEmptyOrNull) {
                      MyToast.showToast(msg: '内容不可为空', type: 'warning');
                    }
                    sosList.add(newItem!);
                    setValue('SOS', jsonEncode(sosList));
                  }
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
    );
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
          onChanged: function,
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
            newItem?.content = text;
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
