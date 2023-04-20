import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class WordDetailPage extends StatefulWidget {
  const WordDetailPage(
    this.currentWord, {
    Key? key,
  }) : super(key: key);

  final WordItemInfo currentWord;

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  bool isLoved = false;

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  @override
  void initState() {
    _getIsLoved();
    super.initState();
  }

  // 添加收藏
  void addMyLove() {
    var userInfo = getStringAsync(Constant.user);
    if (userInfo.isEmptyOrNull) {
      Fluttertoast.showToast(msg: '请先登录');
      return;
    }
    if (isLoved) {
      dio
          .delete('/cancel_love?word_id=${widget.currentWord.id}')
          .then((value) => _changeLoved('已取消收藏', 'success'))
          .catchError((err) => _changeLoved('网络错误', 'error'));
    } else {
      dio
          .post('/love', data: {"word_id": widget.currentWord.id})
          .then((value) => _changeLoved('收藏成功', 'success', isLovedValue: true))
          .catchError((msg) => _changeLoved('网络错误', 'error'));
    }
  }

  void _changeLoved(String msg, String type, {bool isLovedValue = false}) {
    MyToast.showToast(msg: msg, type: type);
    if (isLoved != isLovedValue) {
      setState(() {
        isLoved = isLovedValue;
      });
    }
  }

  // 获取当前词条是否被收藏
  void _getIsLoved() {
    var userInfo = getStringAsync(Constant.user);
    if (userInfo.isEmptyOrNull) {
      return;
    }
    debugPrint("查看收藏");
    dio.get('/is_loved?id=${widget.currentWord.id}').then((value) {
      debugPrint(value.data.toString());
      // var res = ResponseBase.fromJson(value.data);
      // isLoved = res.data!;
      // debugPrint("res.data = ${res.data}");
      // Fluttertoast.showToast(msg: (res.msg) ?? '收藏失败');
    }).catchError((err) {
      Fluttertoast.showToast(msg: '网络错误', textColor: Colours.red);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).primaryColor;
    Color btnColor = isInDark() ? Colors.white : Colors.green;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: bgColor,
        leading: Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 3,
              lightSource: LightSource.topLeft,
              intensity: 0.75,
              color: bgColor),
          margin: const EdgeInsets.only(left: 30, top: 5, bottom: 5, right: 5),
          child: IconButton(
            iconSize: 25,
            color: isInDark() ? Colors.green : btnColor,
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        leadingWidth: 80,
        actions: [
          Neumorphic(
            style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: const NeumorphicBoxShape.circle(),
                depth: 3,
                lightSource: LightSource.topLeft,
                intensity: 0.75,
                surfaceIntensity: 0.1,
                color: bgColor),
            margin:
                const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 30),
            child: IconButton(
              iconSize: 25,
              color: Colors.red,
              icon: Icon(
                  isLoved ? Icons.favorite : Icons.favorite_border_outlined),
              onPressed: () {
                // 添加收藏
                addMyLove();
              },
            ),
          ),
        ],
      ),
      body: _getOneWordCard(widget.currentWord),
    );
  }

  Widget _getOneWordCard(WordItemInfo wordItemInfo) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(
            const BorderRadius.all(Radius.circular(10))),
        depth: 4,
        intensity: 0.8,
        color: isInDark() ? Colours.dark_bg_color : Colours.app_main,
      ),
      margin: const EdgeInsets.only(top: 30, left: 40, right: 40, bottom: 40),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                depth: -5,
                intensity: 0,
              ),
              margin: const EdgeInsets.all(30),
              child: Image.network(
                wordItemInfo.img!,
                fit: BoxFit.cover,
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(10),
              child: Text(
                wordItemInfo.word,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Neumorphic(
                margin: const EdgeInsets.only(left: 30, right: 30),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '释义 : ',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      wordItemInfo.notes ?? wordItemInfo.word,
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.only(left: 30, right: 30, top: 30),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '手势要点 : ',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    wordItemInfo.description ?? '无',
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
