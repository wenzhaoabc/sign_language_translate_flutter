import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// 手势说明页面
class GestureSpecificationPage extends StatefulWidget {
  const GestureSpecificationPage({Key? key}) : super(key: key);

  @override
  State<GestureSpecificationPage> createState() =>
      _GestureSpecificationPageState();
}

class _GestureSpecificationPageState extends State<GestureSpecificationPage> {
  final List<Tab> myTabs = [
    Tab(text: '手指字母'),
    Tab(text: '手势图解'),
    Tab(text: '手位朝向'),
  ];

  List<String> _tabViewContent = ['', '', ''];

  void _readHtmlContent() async {
    var fingerAlpha =
        await rootBundle.loadString('assets/html/finger_alphabet.txt');
    var signDesc = await rootBundle.loadString('assets/html/sign_desc.html');
    var signDirection =
        await rootBundle.loadString('assets/html/sign_direction.txt');
    setState(() {
      _tabViewContent[0] = fingerAlpha;
      _tabViewContent[1] = signDesc;
      _tabViewContent[2] = signDirection;
    });
  }

  @override
  void initState() {
    _readHtmlContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('手势说明'),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: DefaultTabController(
        length: myTabs.length,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: TabBar(
                tabs: myTabs,
                isScrollable: true,
                indicatorColor: Colors.blue,
              ),
            ),
            Expanded(
                child: TabBarView(
                    children: myTabs
                        .map((e) => SingleChildScrollView(
                            child:
                                Html(data: _tabViewContent[myTabs.indexOf(e)])))
                        .toList()))
          ],
        ),
      ),
    );
  }
}
