import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/toolkit/NewsPage.dart';
import 'package:sign_language/toolkit/chat/chat_page.dart';
import 'package:sign_language/toolkit/sos_page.dart';
import 'package:sign_language/toolkit/text_to_voice.dart';
import 'package:sign_language/toolkit/voice_to_text.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';
import 'package:sign_language/widgets/FlatSettingWidget.dart';
import 'package:sign_language/widgets/SOSListWidget.dart';
import 'package:sign_language/res/constant.dart';

class ToolkitPage extends StatefulWidget {
  const ToolkitPage({Key? key}) : super(key: key);

  @override
  State<ToolkitPage> createState() => _ToolkitPageState();
}

class _ToolkitPageState extends State<ToolkitPage> {
  String? phone;

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
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('工具箱'),
        ),
        body: Column(
          children: [
            Neumorphic(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: const EdgeInsets.all(10),
              style: const NeumorphicStyle(
                color: Colours.d_bg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getHintText('特色功能', Colors.black),
                  FlatSettingItem(
                      handleOnTap: () {
                        Navigator.of(context)
                            .push(MySlidePageRoute(page: const SOSPage()));
                      },
                      title: '紧急呼救'),
                  FlatSettingItem(
                      handleOnTap: () {
                        Get.toNamed('/chat');
                      },
                      title: '聊天助手'),
                  FlatSettingItem(
                      handleOnTap: () {
                        Navigator.of(context)
                            .push(MySlidePageRoute(page: const VoiceText()));
                      },
                      title: '无障碍对话'),
                  FlatSettingItem(
                      handleOnTap: () {
                        Navigator.of(context)
                            .push(MySlidePageRoute(page: const NewsListPage()));
                      },
                      title: '无障碍资讯'),
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: const EdgeInsets.all(10),
              style: const NeumorphicStyle(
                color: Colours.d_bg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  _getHintText('我的紧急呼救', Colors.red),
                  // Expanded(child: SOSListWidget()),
                  SOSListWidget()
                ],
              ),
            ),
          ],
        ),
        // elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget _getHintText(String text, Color in_color) {
    Color textColor = in_color;
    // Color textColor = isInDark ? Colors.grey : Colors.grey;
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
