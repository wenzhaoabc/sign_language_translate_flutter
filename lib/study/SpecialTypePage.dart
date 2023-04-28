import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/widgets/LearnItemWidget.dart';
import 'package:sign_language/res/constant.dart';

class SpecialTypePage extends StatefulWidget {
  const SpecialTypePage({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  State<SpecialTypePage> createState() => _SpecialTypePageState();
}

class _SpecialTypePageState extends State<SpecialTypePage> {
  List<WordItemInfo>? _wordList;

  final _wordType = ['交通工具', '亲属', '天气', '动植物', '民族', '节气', '政党', '手语生成'];

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  @override
  void initState() {
    _getWordListByType(_wordType[widget.index]);
    super.initState();
  }

  void _getWordListByType(String type) {
    dio.get('/word_list?type=$type').then((value) {
      _wordList = ResponseBase<List<WordItemInfo>>.fromJson(value.data).data;
      setState(() {});
    }).catchError((res) => Fluttertoast.showToast(msg: '查询失败'));
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
            centerTitle: true,
            elevation: 0,
            // backgroundColor:
            //     isInDark() ? Colours.dark_app_main : Colours.app_main,
            backgroundColor: Colors.transparent,
            leading: Neumorphic(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 3,
                  lightSource: LightSource.topLeft,
                  intensity: 0.75,
                  surfaceIntensity: 0.1,
                  color: isInDark() ? Colours.dark_app_main : Colours.app_main),
              margin:
                  const EdgeInsets.only(left: 30, top: 5, bottom: 5, right: 5),
              child: IconButton(
                iconSize: 25,
                color: Colors.green,
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
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: 3,
                    lightSource: LightSource.topLeft,
                    intensity: 0.75,
                    surfaceIntensity: 0.1,
                    color:
                        isInDark() ? Colours.dark_app_main : Colours.app_main),
                margin: const EdgeInsets.only(
                    left: 5, top: 5, bottom: 5, right: 30),
                child: IconButton(
                  iconSize: 25,
                  color: isInDark() ? Colors.redAccent : Colors.blue,
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          body: _getLearnList(),
          backgroundColor: Colors.transparent,
        ));
  }

  Widget _getLearnList() {
    var itemCount = (_wordList?.length) ?? 0;
    if (itemCount == 0) {
      return Center(
        child: Column(
          children: const [
            Icon(Icons.error_outline, size: 50),
            Text('查询无果'),
          ],
        ),
      );
    }
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
