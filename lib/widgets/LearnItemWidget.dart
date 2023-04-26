import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/study/WordDetailPage.dart';
import 'package:sign_language/widgets/WordTagWidget.dart';

class LearnItemWidget extends StatefulWidget {
  const LearnItemWidget(this.word, {Key? key}) : super(key: key);

  final WordItemInfo word;

  @override
  State<LearnItemWidget> createState() => _LearnItemWidgetState();
}

class _LearnItemWidgetState extends State<LearnItemWidget> {
  final _ColorList = const [Colors.green, Colors.red, Colors.blue];

  // 当前是否处于黑暗模式
  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  @override
  Widget build(BuildContext context) {
    // 当前设备的宽度
    double deviceWidth = MediaQuery.of(context).size.width;
    // 当前主要颜色
    Color currentColor = isInDark() ? Colours.dark_app_main : Colours.d_bg;
    double marginTop = 10;
    // 字体大小
    double wordFontSize = 22;
    // 单词标签
    List<String>? tags = widget.word.tags?.split(',');
    return SizedBox(
      width: deviceWidth,
      height: 100,
      child: Neumorphic(
        margin: EdgeInsets.only(top: marginTop, bottom: 10, left: 15, right: 15),
        style: NeumorphicStyle(
          color: currentColor,
          boxShape: NeumorphicBoxShape.roundRect(
            const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 12, top: marginTop, bottom: 10),
              child: Image.network(
                widget.word.img!,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12, top: marginTop, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.word.word,
                    style: TextStyle(
                      fontSize: wordFontSize,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      (tags?.length) ?? 0,
                      (index) => WordTagWidget(tags![index], _ColorList[index]),
                    ),
                  )
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(left: 12, top: 10, bottom: 10, right: 12),
                child: NeumorphicIcon(
                  style: const NeumorphicStyle(color: Colors.blueAccent),
                  Icons.arrow_forward_ios_rounded,
                  size: 30,
                ),
              ),
              onTap: () {
                WordItemInfo currentWord = widget.word;
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => WordDetailPage(currentWord),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(0.0, 1.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
