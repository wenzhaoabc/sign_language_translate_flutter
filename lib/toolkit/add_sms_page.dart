import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class AddSMSPage extends StatefulWidget {
  const AddSMSPage({Key? key}) : super(key: key);

  @override
  State<AddSMSPage> createState() => _AddSMSPageState();
}

class _AddSMSPageState extends State<AddSMSPage> {
  String? to, title, content;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                _getTagInput('TO', '发送的手机号', (t) => to = t),
                const SizedBox(height: 20),
                _getTextArea(),
                const SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    children: [
                      GestureDetector(
                        child: Column(
                          children: [
                            Icon(Icons.location_on, color: Colors.red),
                            Text('位置标签'),
                          ],
                        ),
                        onTap: () {
                          var originText = _textEditingController.value.text;
                          _textEditingController.text =
                              originText + Constant.smsLocation;
                        },
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        child: Column(
                          children: [
                            Icon(Icons.question_mark_outlined, color: Colors.grey),
                            Text('敬请期待'),
                          ],
                        ),
                        onTap: () {},
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    style: const NeumorphicStyle(depth: 3, intensity: 0.8),
                    pressed: true,
                    onPressed: () {
                      content = _textEditingController.text;
                      var smsList =
                          Provider.of<AppProvider>(context, listen: false)
                              .smsList;

                      for (var value1 in smsList) {
                        if (value1.title == title) {
                          MyToast.showToast(msg: '名称重复', type: 'error');
                          return;
                        }
                      }
                      if (to == null || content == null || title == null) {
                        MyToast.showToast(msg: '内容不可为空', type: 'warning');
                        return;
                      }
                      Provider.of<AppProvider>(context, listen: false)
                          .addSMSItem(SMSItem(title!, content!, to!));
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
    ;
  }

  Widget _getTagInput(String tag, String hintText, Function(String) function) {
    var textColor = Colors.black;
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
    var textColor = Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('求救内容', style: TextStyle(color: textColor, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _textEditingController,
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

  void popToLast() {
    Navigator.of(context).pop();
  }
}
