import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/toolkit/NewsDetailPage.dart';
import 'package:sign_language/utils/DateTimeFormat.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({Key? key}) : super(key: key);

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late List<NewsItem> _newsItemList = [];

  @override
  void initState() {
    _getNewsItemList();
    super.initState();
  }

  void _getNewsItemList() {
    try {
      dio.get('/news-list').then((value) {
        ResponseBase<List<NewsItem>> res = ResponseBase.fromJson(value.data);
        setState(() {
          _newsItemList = res.data!;
        });
      });
    } catch (e) {
      toast('网络错误');
    }
//     var t = NewsItem(
//         0,
//         '你好',
//         '🙌 无障碍服务',
//         """
//         <h1 style="text-align: center;">文明办关于提高社会无障碍服务保障的通知</h1>
// <p style="text-align: center;"><span style="font-size: 14px;">社会主义核心价值观文明办公室</span></p>
// <p style="text-align: center;"><span style="font-size: 14px;">2023年5月18日</span></p>
// <p style="text-align: left;"><span style="font-size: 16px;">各区县：</span></p>
// <p style="text-align: left;"><span style="font-size: 16px;">为切实加强我县残障人士的生活质量，现对各场所无障碍服务做出如下倡议：</span></p>
// <p style="text-align: left;"><span style="font-size: 16px;"><img src="https://s2.loli.net/2023/05/18/oG6LuTybQtK4EP9.png"></span></p>
// <p style="text-align: left;"><span style="font-size: 16px;">请严格落实以上规定内容。</span></p>
// <p style="text-align: right;"><span style="font-size: 16px;">县委文明办公室</span></p>
//         """,
//         'https://s2.loli.net/2023/05/04/jlOSp5LQRzYWX3d.jpg',
//         '2023-05-16 18:32:45');
//     _newsItemList.add(t);
//     _newsItemList.add(t);
//     _newsItemList.add(t);
//     _newsItemList.add(t);
//     _newsItemList.add(t);
//     _newsItemList.add(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('无障碍资讯'),
        elevation: 0,
        leading: InkWell(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/news_list_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return _getOneNewsBlock(_newsItemList[index]);
            },
            itemCount: _newsItemList.length),
      ),
    );
  }

  Widget _getOneNewsBlock(NewsItem item) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      width: deviceWidth,
      height: 250,
      child: Neumorphic(
          margin: EdgeInsets.only(left: 10, right: 10, top: 30),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          style: NeumorphicStyle(color: Colors.white),
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 15, bottom: 10),
                      child: Text(
                        item.author,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Text(
                        RelativeDateFormat.format(DateTime.parse(item.created)),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                Image(
                  image: NetworkImage(item.image),
                  fit: BoxFit.cover,
                  width: deviceWidth,
                  height: 130,
                ),
                Container(
                  margin: EdgeInsets.only(left: 15, top: 10),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => {
              Navigator.push(context,
                  MySlidePageRoute(page: NewsDetailPage(newsItem: item)))
            },
          )),
    );
  }
}
