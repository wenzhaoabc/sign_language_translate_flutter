import 'package:flutter/material.dart';

class ChatBottom extends StatefulWidget {
  const ChatBottom({Key? key}) : super(key: key);

  @override
  State<ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<ChatBottom> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
            constraints: BoxConstraints(
              maxHeight: 100.0,
              minHeight: 50.0,
            ),
            decoration: BoxDecoration(
                color: Color(0xFFF5F6FF),
                borderRadius: BorderRadius.all(Radius.circular(2))),
            child: TextField(
              controller: textEditingController,
              cursorColor: Color(0xFF464EB5),
              maxLines: null,
              maxLength: 200,
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                hintText: "回复",
                hintStyle: TextStyle(color: Color(0xFFADB3BA), fontSize: 15),
              ),
              style: TextStyle(color: Color(0xFF03073C), fontSize: 15),
            ),
          ),
        ),
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              alignment: Alignment.center,
              height: 70,
              child: Text(
                '发送',
                style: TextStyle(
                  color: Color(0xFF464EB5),
                  fontSize: 14,
                ),
              ),
            ),
            onTap: () {}),
      ],
    );
  }
}
