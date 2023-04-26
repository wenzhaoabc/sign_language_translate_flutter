import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/toolkit/chat/chat_page.dart';
import 'package:sign_language/toolkit/sos_page.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';
import 'package:sign_language/widgets/FlatSettingWidget.dart';
import 'package:sign_language/widgets/SOSListWidget.dart';

class ToolkitPage extends StatefulWidget {
  const ToolkitPage({Key? key}) : super(key: key);

  @override
  State<ToolkitPage> createState() => _ToolkitPageState();
}

class _ToolkitPageState extends State<ToolkitPage> {
  String? phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('工具箱'),
      ),
      body: Column(
        children: [
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getHintText('特色功能'),
                FlatSettingItem(
                    handleOnTap: () {
                      Navigator.of(context)
                          .push(MySlidePageRoute(page: const SOSPage()));
                    },
                    title: '紧急呼救'),
                FlatSettingItem(handleOnTap: () {}, title: '无障碍通话'),
                FlatSettingItem(
                    handleOnTap: () {
                      // Navigator.of(context)
                      //     .push(MySlidePageRoute(page: ChatPage()));
                      // Get.to(ChatPage());
                      Get.toNamed('/chat');
                    },
                    title: '聊天助手'),
              ],
            ),
          ),
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_getHintText('我的紧急呼救'), const SOSListWidget()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getHintText(String text) {
    bool isInDark = Theme.of(context).primaryColor == Colours.dark_app_main;
    Color textColor = isInDark ? Colors.grey : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }
}
