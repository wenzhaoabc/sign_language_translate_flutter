import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
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
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  void _dataCheckWord() async {
    dio.get(
      '/data-check-word?word-id=${widget.currentWord.id ?? 0}',
    );
  }

  @override
  void initState() {
    _getIsLoved();
    _dataCheckWord();
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
    }).catchError((err) {
      Fluttertoast.showToast(msg: '网络错误', textColor: Colours.red);
    });
  }

  void _handleVideo(int value) {
    if (value == 0) {
      _customVideoPlayerController.dispose();
    } else {
      String videoUrl =
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
      videoPlayerController =
          VideoPlayerController.network(widget.currentWord.video ?? videoUrl)
            ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
      );
    }
    setState(() {
      _selectedIndex = value;
    });
  }

  late double fontSize;

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).primaryColor;
    Color btnColor = isInDark() ? Colors.white : Colors.green;
    fontSize = Provider.of<AppProvider>(context).normalFontSize;

    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(Constant.bg_img_url),
            // image: AssetImage("images/R_C.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          // backgroundColor: bgColor,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            // backgroundColor: bgColor,
            backgroundColor: Colors.transparent,
            leading: Neumorphic(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: const NeumorphicBoxShape.circle(),
                  depth: 3,
                  lightSource: LightSource.topLeft,
                  intensity: 0.75,
                  color: bgColor),
              margin: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
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
                margin: const EdgeInsets.only(
                    left: 5, top: 5, bottom: 5, right: 10),
                child: IconButton(
                  iconSize: 25,
                  color: Colors.red,
                  icon: Icon(isLoved
                      ? Icons.favorite
                      : Icons.favorite_border_outlined),
                  onPressed: () {
                    // 添加收藏
                    addMyLove();
                  },
                ),
              ),
            ],
          ),
          body: _getOneWordCard(widget.currentWord),
          backgroundColor: Colors.transparent,
        ));
  }

  var _selectedIndex = 0;

  Widget _getOneWordCard(WordItemInfo wordItemInfo) {
    // double deviceWidth = MediaQuery.of(context).size.width;
    // double deviceHeight = MediaQuery.of(context).size.height;
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(
            const BorderRadius.all(Radius.circular(10))),
        depth: 4,
        intensity: 0.8,
        color: Colors.white12,
      ),
      margin: const EdgeInsets.only(top: 30, left: 40, right: 40, bottom: 40),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Center(
                child: Neumorphic(
                  // margin: const EdgeInsets.only(left: 60, right: 60, top: 20),
                  style: const NeumorphicStyle(
                      color: Colours.app_main, depth: 0, intensity: 0),
                  child: NeumorphicToggle(
                      height: 30,
                      width: 100,
                      selectedIndex: _selectedIndex,
                      padding: EdgeInsets.all(5),
                      // displayForegroundOnlyIfSelected: true,
                      children: [
                        ToggleElement(
                          background: const Center(
                              child: Text("图片",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500))),
                          foreground: const Center(
                              child: Text("图片",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700))),
                        ),
                        ToggleElement(
                          background: const Center(
                              child: Text("视频",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500))),
                          foreground: const Center(
                              child: Text("视频",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700))),
                        ),
                      ],
                      thumb: Neumorphic(
                          style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                            const BorderRadius.all(Radius.circular(12))),
                      )),
                      onChanged: _handleVideo),
                ),
              ),
            ),
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
                // TODO 视频
                child: _getImgOrVideo(wordItemInfo)
                // Image.network(
                //   wordItemInfo.img!,
                //   fit: BoxFit.cover,
                // ),
                ),
            Neumorphic(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(10),
              child: Text(
                wordItemInfo.word,
                style: TextStyle(fontSize: fontSize),
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
                      style: TextStyle(fontSize: fontSize - 4),
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
                    style: TextStyle(fontSize: fontSize - 4),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getImgOrVideo(WordItemInfo wordItemInfo) {
    if (_selectedIndex == 0) {
      return Image.network(
        wordItemInfo.img!,
        fit: BoxFit.cover,
      );
    } else {
      return SafeArea(
          child: CustomVideoPlayer(
        customVideoPlayerController: _customVideoPlayerController,
      ));
    }
  }
}
