import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/widgets/LearnItemWidget.dart';
import 'package:sign_language/res/constant.dart';

class MyLoveWord extends StatefulWidget {
  const MyLoveWord({Key? key}) : super(key: key);

  @override
  State<MyLoveWord> createState() => _MyLoveWordState();
}

class _MyLoveWordState extends State<MyLoveWord> {
  List<WordItemInfo>? _wordList;

  @override
  void initState() {
    _getMyLoves();
    super.initState();
  }

  void _getMyLoves() {
    dio.get('/my_loves').then((value) {
      ResponseBase<List<WordItemInfo>> res = ResponseBase.fromJson(value.data);
      _wordList = res.data!;
      setState(() {});
      // debugPrint(value.data.toString());
    }).catchError((err) => Fluttertoast.showToast(msg: '请求失败'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: PageBgStyles.PageBimgDecoration,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            // backgroundColor: Color.fromARGB(255, 219, 230, 232),
            backgroundColor: Colors.transparent,
            leading: Neumorphic(
              style: const NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 3,
                  lightSource: LightSource.topLeft,
                  intensity: 0.75,
                  surfaceIntensity: 0.1,
                  color: Color.fromARGB(0xff, 219, 230, 232)),
              margin:
                  const EdgeInsets.only(left: 30, top: 5, bottom: 5, right: 5),
              child: IconButton(
                iconSize: 25,
                color: const Color.fromARGB(0xff, 255, 255, 255),
                icon: const Icon(Icons.arrow_back_sharp,color: Colors.blueAccent,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            leadingWidth: 80,
            actions: [
              Neumorphic(
                style: const NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: 3,
                    lightSource: LightSource.topLeft,
                    intensity: 0.75,
                    surfaceIntensity: 0.1,
                    color: Color.fromARGB(0xff, 219, 230, 232)),
                margin: const EdgeInsets.only(
                    left: 5, top: 5, bottom: 5, right: 30),
                child: IconButton(
                  iconSize: 25,
                  color: const Color.fromARGB(0xff, 255, 255, 255),
                  icon: const Icon(Icons.menu,color: Colors.blueAccent,),
                  onPressed: () {
                    // Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          // body: _getLearnList(),
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
            Text('暂未有收藏'),
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
