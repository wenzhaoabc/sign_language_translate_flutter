import 'dart:core';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/study/SerachPage.dart';
import 'package:sign_language/study/SpecialTypePage.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/widgets/LearnItemWidget.dart';
import 'package:sign_language/res/constant.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({Key? key}) : super(key: key);

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  List<WordItemInfo>? _wordList;

  final _signTypesIcon = [
    Icons.local_airport,
    Icons.family_restroom,
    Icons.wb_sunny_rounded,
    Icons.nature,
    Icons.flag_circle_outlined,
    Icons.filter_vintage,
    // Icons.handyman,
    Icons.people_outline,
    // Icons.sign_language_outlined,
    Icons.account_balance_rounded,
    // SvgPicture.asset('assets/icons/local_airport.svg')
    // SvgPicture.asset('assets/icons/people_outline.svg'),
    // SvgPicture.asset('assets/icons/sunny.svg'),
    // SvgPicture.asset('assets/icons/animation.svg'),
    // SvgPicture.asset('assets/icons/flag_circle_outlined.svg'),
    // SvgPicture.asset('assets/icons/calendar_view_day.svg'),
    // SvgPicture.asset('assets/icons/handyman.svg'),
    // SvgPicture.asset('assets/icons/sign_language_outlined.svg')
  ];

  final _signTypesTitle = ['交通工具', '亲属称谓', '天气', '动植物', '民族', '节气', '政党', '地名'];

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  @override
  void initState() {
    _getWordItemList();
    super.initState();
  }

  void _getWordItemList() {
    dio.get('/word_list').then((value) {
      ResponseBase<List<WordItemInfo>> res = ResponseBase.fromJson(value.data);
      _wordList = res.data!;
      setState(() {});
    }).catchError((o) {
      debugPrint('Error$o');
    });
  }

  // 页面跳转动画
  void _routeToPage(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

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
            title: const Text(
              '学习社区',
            ),
            // elevation: 0,
            actions: [
              Neumorphic(
                style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: const NeumorphicBoxShape.circle(),
                    depth: 3,
                    intensity: 0.75,
                    color: isInDark() ? Colours.dark_btn_bg : Colours.d_bg),
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  iconSize: 25,
                  icon: const Icon(
                    Icons.search_outlined,
                    color: Colors.blueAccent,
                    // color: isInDark() ? Colours.dark_btn_icon : Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SearchPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Neumorphic(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(15),
                style: const NeumorphicStyle(depth: 2, color: Colours.d_bg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                          4,
                          (index) => _getGridItem(_signTypesIcon[index],
                              _signTypesTitle[index], index)),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                          4,
                          (index) => _getGridItem(_signTypesIcon[index + 4],
                              _signTypesTitle[index + 4], index + 4)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: _getLearnList(),
              )
            ],
          ),
          backgroundColor: Colors.transparent,
        ));
  }

  Widget _getGridItem(IconData icon, String title, int index) {
    List<Color> _bgColors = const [
      Color(0xff5c2223),
      Color(0xffaeade7),
      Color(0xffec9026),
      Color(0xff15d939),
      Color(0xff37d4cb),
      Color(0xfff9c116),
      Color(0xff5d3d21),
      Color(0xff4e8ffd)
    ];
    return InkWell(
      child: Column(
        children: [
          NeumorphicButton(
            pressed: true,
            onPressed: () {
              _routeToPage(SpecialTypePage(index: index));
            },
            style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(
                    const BorderRadius.all(Radius.circular(10))),
                depth: 2,
                // color: Colours.er_bg,
                color: Colours.item_bg),
            child: Icon(icon,
                size: 35, color: _bgColors[index % _bgColors.length]),
          ),
          Text(title,
              style: TextStyle(
                  fontSize: Provider.of<AppProvider>(context).smallFontSize)),
        ],
      ),
      onTap: () {
        _routeToPage(SpecialTypePage(index: index));
      },
    );
  }

  Widget _getLearnList() {
    var itemCount = (_wordList?.length) ?? 0;
    return ListView.separated(
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return LearnItemWidget(_wordList![index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 0,
          thickness: 0,
        );
      },
    );
  }
}
