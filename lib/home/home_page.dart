import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/setting/page/setting_page.dart';
import 'package:sign_language/study/StudyPage.dart';
import 'package:sign_language/toolkit/toolkit_page.dart';
import 'package:sign_language/trans/TransPage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Widget> _pageList;
  late List<Widget> _bottomIcons;
  int _page = 0;
  final PageController _pageController = PageController();
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    _pageList = [
      const TransPage(),
      const StudyPage(),
      const ToolkitPage(),
      const SettingPage()
    ];
    _bottomIcons = const [
      Icon(Icons.home, size: 30),
      Icon(Icons.storage, size: 30),
      Icon(Icons.handyman, size: 30),
      Icon(Icons.settings, size: 30),
    ];
  }

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  @override
  Widget build(BuildContext context) {
    var res = Scaffold(
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        items: _bottomIcons,
        onTap: (index) {
          setState(() {
            _page = index;
          });
          _pageController.animateToPage(_page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        },
        backgroundColor: isInDark() ? Colours.dark_bottomBar_bg : Colors.white,
        buttonBackgroundColor:
            isInDark() ? Colours.dark_bottomBar_bbg : Colors.white,
        color: isInDark() ? Colours.dark_app_main : Colours.app_main,
        animationDuration: const Duration(milliseconds: 300),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _pageList,
        onPageChanged: (value) {
          setState(() {
            _page = value;
          });
        },
      ),
    );
    return res;
    // return ChangeNotifierProvider(
    //   create: (_) => AppProvider(),
    //   child: res,
    // );
  }
}
