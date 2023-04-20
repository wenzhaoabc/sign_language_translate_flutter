import 'package:flutter/material.dart';

class WordTagWidget extends StatefulWidget {
  const WordTagWidget(this.tag, this.color, {Key? key}) : super(key: key);
  final String tag;
  final Color color;

  @override
  State<WordTagWidget> createState() => _WordTagWidgetState();
}

class _WordTagWidgetState extends State<WordTagWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      margin: const EdgeInsets.only(right: 4.0),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2.0),
      ),
      height: 16.0,
      alignment: Alignment.center,
      child: Text(
        widget.tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          height: 1.1,
        ),
      ),
    );
  }
}
