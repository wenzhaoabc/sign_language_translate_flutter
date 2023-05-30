import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

class OperateGuidePage extends StatefulWidget {
  const OperateGuidePage({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<OperateGuidePage> createState() => _OperateGuidePageState();
}

class _OperateGuidePageState extends State<OperateGuidePage> {
  String _text = '';

  void _getInitData() async {
    var res =
        await rootBundle.loadString('assets/html/about_us_${widget.index}.txt');
    if (res.isNotEmpty) {
      setState(() {
        _text = res;
      });
    }
  }

  @override
  void initState() {
    _getInitData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.index == 0
              ? '操作指南'
              : widget.index == 1
                  ? '开源组件使用说明'
                  : '隐私政策与用户协议',
        ),
        leading: InkWell(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(child: Html(data: _text)),
    );
  }
}
