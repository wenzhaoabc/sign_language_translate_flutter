import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/study/GestureSpecification.dart';
import 'package:sign_language/study/SignGame.dart';
import 'package:sign_language/study/StudyPage.dart';
import 'package:sign_language/study/WordDetailPage.dart';
import 'package:sign_language/toolkit/NewsDetailPage.dart';
import 'package:sign_language/toolkit/NewsPage.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';

class StudyMainPage extends StatefulWidget {
  const StudyMainPage({Key? key}) : super(key: key);

  @override
  State<StudyMainPage> createState() => _StudyMainPageState();
}

class _StudyMainPageState extends State<StudyMainPage> {
  final _swiperImages = [
    // 'https://s2.loli.net/2023/05/28/3kBwP7jxSitLZ8n.png',
    // 'https://s2.loli.net/2023/05/28/lQ6Ww81yBgdjEsN.png',
    // 'https://s2.loli.net/2023/05/28/2JWRquXnUpj3Hfo.png'
    'https://s2.loli.net/2023/05/29/qTLPH4VAu8Ux2G3.png',
    'https://s2.loli.net/2023/05/29/HUm3CejiWkBO8wp.png',
    'https://s2.loli.net/2023/05/29/UCO1TNVbHAMypKd.png',
    'https://s2.loli.net/2023/05/29/Eq8rJDLdp4g3wty.jpg',
  ];

  final _iconImages = [
    'https://s2.loli.net/2023/05/28/BpQqz9Jgxer1dYl.png',
    'https://s2.loli.net/2023/05/28/N3AhgXJbeoaCtWU.png',
    'https://s2.loli.net/2023/05/28/XDrsgHMGCPYuaz6.png',
    'https://s2.loli.net/2023/05/28/XBSxNmlKjeRsnTQ.png'
  ];

  final _newsScrollText = [
    '【财政部】将加大投入社会无障碍服务基础设施建设',
    '【人民日报】看不见的背起了走不动的',
    '【光明网】从盲人按摩看残障人士的社会发展问题',
  ];

  List<WordItemInfo> _usefulWord = [
    WordItemInfo(
        'https://musicstyle.oss-cn-shanghai.aliyuncs.com/files/237c5a111c434c2cbdfb3326d6307017/感谢.jpg',
        '感谢',
        description: '一手（或双手）伸拇指，向前弯动两下，面带笑容。',
        tags: '日常用语',
        notes: '无'),
    WordItemInfo(
        'https://musicstyle.oss-cn-shanghai.aliyuncs.com/files/4a3526e0f92341c6aef3d95fc0533fca/再见.jpg',
        '再见',
        description: '一手上举，掌心向外，左右摆动几下，面带笑容。（可根据实际表示再见的动作）',
        tags: '日常用语',
        notes: '无')
  ];

  List<NewsItem> _recommendNews = [];

  void _getInitData() async {
    if (mounted) {
      dio.get('/news-recommend').then((value) {
        ResponseBase<List<NewsItem>> _news = ResponseBase.fromJson(value.data);
        if (mounted) {
          setState(() {
            _recommendNews = _news.data!;
          });
        }
      });
      dio.get('/sign-recommend?count=2').then((value) {
        ResponseBase<List<WordItemInfo>> _words =
            ResponseBase.fromJson(value.data);
        if (mounted) {
          setState(() {
            _usefulWord = _words.data!;
          });
        }
      });
    }
  }

  @override
  void initState() {
    _getInitData();
    super.initState();
  }

  // 新闻文本滚动条
  // GlobalKey _newScrollKey = new GlobalKey();
  // ScrollController _newsScrollController ;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double fontSize = Provider.of<AppProvider>(context).normalFontSize;
    bool inLargeFont = Provider.of<AppProvider>(context).inLargeFont;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 轮播图，
            Stack(
              children: [
                SizedBox(
                  width: deviceWidth,
                  height: 230,
                  child: Swiper(
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.white,
                                Colors.white,
                                Colors.white12,
                                Colors.transparent,
                              ]).createShader(bounds);
                        },
                        child: Image.network(_swiperImages[index],
                            fit: BoxFit.fill),
                      );
                    },
                    autoplay: true,
                    // scale: 0.9,
                    // viewportFraction: 0.95,
                    duration: 1000,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: const Center(
                      child: Text('手语学习社区', style: TextStyle(fontSize: 20))),
                ),
                Neumorphic(
                  margin: const EdgeInsets.only(top: 170, left: 30, right: 30),
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                  style: NeumorphicStyle(
                    color: Colors.white70,
                    depth: 5,
                    intensity: 0.7,
                    boxShape: NeumorphicBoxShape.roundRect(
                      const BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  child: inLargeFont
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Image.network(_iconImages[0],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.fill),
                                      const SizedBox(height: 8),
                                      Text('手语词表',
                                          style:
                                              TextStyle(fontSize: fontSize - 5))
                                    ],
                                  ),
                                  onTap: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .push(MyBottomSlidePageRoute(
                                              page: const StudyPage())),
                                ),
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Image.network(_iconImages[1],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.fill),
                                      const SizedBox(height: 8),
                                      Text('新闻资讯',
                                          style:
                                              TextStyle(fontSize: fontSize - 5))
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MyBottomSlidePageRoute(
                                            page: const NewsListPage()));
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Image.network(_iconImages[2],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.fill),
                                      const SizedBox(height: 8),
                                      Text('手语挑战',
                                          style:
                                              TextStyle(fontSize: fontSize - 5))
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MyBottomSlidePageRoute(
                                            page: const SignGamePage()));
                                  },
                                ),
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Image.network(_iconImages[3],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.fill),
                                      const SizedBox(height: 8),
                                      Text('手势说明',
                                          style:
                                              TextStyle(fontSize: fontSize - 5))
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MyBottomSlidePageRoute(
                                            page: GestureSpecificationPage()));
                                  },
                                ),
                              ],
                            )
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              child: Column(
                                children: [
                                  Image.network(_iconImages[0],
                                      width: 45, height: 45, fit: BoxFit.fill),
                                  const SizedBox(height: 8),
                                  Text('手语词表',
                                      style: TextStyle(fontSize: fontSize - 5))
                                ],
                              ),
                              onTap: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .push(MyBottomSlidePageRoute(
                                          page: const StudyPage())),
                            ),
                            GestureDetector(
                              child: Column(
                                children: [
                                  Image.network(_iconImages[1],
                                      width: 45, height: 45, fit: BoxFit.fill),
                                  const SizedBox(height: 8),
                                  Text('新闻资讯',
                                      style: TextStyle(fontSize: fontSize - 5))
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                    MyBottomSlidePageRoute(
                                        page: const NewsListPage()));
                              },
                            ),
                            GestureDetector(
                              child: Column(
                                children: [
                                  Image.network(_iconImages[2],
                                      width: 45, height: 45, fit: BoxFit.fill),
                                  const SizedBox(height: 8),
                                  Text('手语挑战',
                                      style: TextStyle(fontSize: fontSize - 5))
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                    MyBottomSlidePageRoute(
                                        page: const SignGamePage()));
                              },
                            ),
                            GestureDetector(
                              child: Column(
                                children: [
                                  Image.network(_iconImages[3],
                                      width: 45, height: 45, fit: BoxFit.fill),
                                  const SizedBox(height: 8),
                                  Text('手势说明',
                                      style: TextStyle(fontSize: fontSize - 5))
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                    MyBottomSlidePageRoute(
                                        page: GestureSpecificationPage()));
                              },
                            ),
                          ],
                        ),
                )
              ],
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                height: 0.3,
                color: Colors.grey),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Image.network(
                      'https://s2.loli.net/2023/05/28/FRYec8yENwbZH3h.png',
                      width: 20,
                      fit: BoxFit.fitWidth),
                  Container(
                    height: 20,
                    width: deviceWidth - 80,
                    child: Swiper(
                      itemCount: _newsScrollText.length,
                      scrollDirection: Axis.vertical,
                      itemHeight: 20,
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(_newsScrollText[index], softWrap: false);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: deviceWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('推荐阅读',
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.start),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                              _recommendNews.isNotEmpty
                                  ? _recommendNews[0].image
                                  : _swiperImages[0],
                              width: 100,
                              height: 60,
                              fit: BoxFit.fill),
                          SizedBox(width: 5),
                          Expanded(
                              child: Text(
                            _recommendNews.isNotEmpty
                                ? _recommendNews[0].title
                                : _newsScrollText[0],
                            style: TextStyle(fontSize: fontSize - 5),
                          ))
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MySlidePageRoute(
                          page: NewsDetailPage(newsItem: _recommendNews[0])));
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                              _recommendNews.isNotEmpty
                                  ? _recommendNews[1].image
                                  : _swiperImages[1],
                              width: 100,
                              height: 60,
                              fit: BoxFit.fill),
                          SizedBox(width: 5),
                          Expanded(
                              child: Text(
                            _recommendNews.isNotEmpty
                                ? _recommendNews[1].title
                                : _newsScrollText[1],
                            style: TextStyle(fontSize: fontSize - 5),
                          ))
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MySlidePageRoute(
                          page: NewsDetailPage(
                        newsItem: _recommendNews[1],
                      )));
                    },
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: deviceWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('高频手语',
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.start),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(_usefulWord[0].img!,
                              width: 100, height: 60, fit: BoxFit.fill),
                          SizedBox(width: 5),
                          Expanded(
                              child: Text(
                            '${_usefulWord[0].word}\n${_usefulWord[0].description!.substring(0, _usefulWord[0].description!.length > 22 ? 22 : _usefulWord[0].description!.length)}',
                            style: TextStyle(fontSize: fontSize - 5),
                          ))
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MyBottomSlidePageRoute(
                          page: WordDetailPage(_usefulWord[0])));
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(_usefulWord[1].img!,
                              width: 100, height: 60, fit: BoxFit.fill),
                          SizedBox(width: 5),
                          Expanded(
                              child: Text(
                            '${_usefulWord[1].word}\n${_usefulWord[1].description!.substring(0, _usefulWord[1].description!.length > 21 ? 21 : _usefulWord[1].description!.length)}',
                            style: TextStyle(fontSize: fontSize - 5),
                          ))
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MyBottomSlidePageRoute(
                          page: WordDetailPage(_usefulWord[1])));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 55)
          ],
        ),
      ),
    );
  }
}
