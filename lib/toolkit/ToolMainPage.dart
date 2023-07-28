import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/toolkit/sos_page.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';
import 'package:sign_language/widgets/SMSListWidget.dart';
import 'package:sign_language/widgets/SOSListWidget.dart';

class ToolMainPage extends StatefulWidget {
  const ToolMainPage({Key? key}) : super(key: key);

  @override
  State<ToolMainPage> createState() => _ToolMainPageState();
}

class _ToolMainPageState extends State<ToolMainPage> {
  @override
  Widget build(BuildContext context) {
    double fontSize = Provider.of<AppProvider>(context).normalFontSize;
    return Container(
      decoration: PageBgStyles.PageBallonDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          // bottomOpacity: 3,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('工具箱'),
        ),
        body: Column(
          children: [
            Neumorphic(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: const EdgeInsets.all(15),
              style: const NeumorphicStyle(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getHintText('特色功能', Colors.black),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        child: Column(
                          children: [
                            Neumorphic(
                              style: NeumorphicStyle(color: Colors.blue),
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                  'assets/images/tool_sos_phone.png',
                                  width: 35,
                                  fit: BoxFit.fitWidth),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '紧急求救',
                              style: TextStyle(fontSize: fontSize - 3),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(MyBottomSlidePageRoute(page: SOSPage()));
                        },
                      ),
                      GestureDetector(
                        child: Column(
                          children: [
                            Neumorphic(
                              style: NeumorphicStyle(color: Colors.amberAccent),
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                  'assets/images/tool_chat_robots.png',
                                  width: 35,
                                  fit: BoxFit.fitWidth),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '陪伴助手',
                              style: TextStyle(fontSize: fontSize - 3),
                            )
                          ],
                        ),
                        onTap: () {
                          Get.toNamed('/chat');
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              style: const NeumorphicStyle(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getHintText('我的短信求助', Colors.red),
                  SMSListWidget()
                ],
              ),
            ),
            SizedBox(height: 5),
            Neumorphic(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: const EdgeInsets.all(10),
              style: const NeumorphicStyle(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getHintText('我的紧急呼救', Colors.red),
                  // Expanded(child: SOSListWidget()),
                  SOSListWidget()
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // return ;
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
