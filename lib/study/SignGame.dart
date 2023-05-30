import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';

class SignGamePage extends StatefulWidget {
  const SignGamePage({Key? key}) : super(key: key);

  @override
  State<SignGamePage> createState() => _SignGamePageState();
}

class _SignGamePageState extends State<SignGamePage> {
  static const _WordCont = 10;
  List<WordItemInfo> _words = [
    WordItemInfo(
        'https://musicstyle.oss-cn-shanghai.aliyuncs.com/files/237c5a111c434c2cbdfb3326d6307017/感谢.jpg',
        '感谢',
        description: '一手（或双手）伸拇指，向前弯动两下，面带笑容。',
        tags: '日常用语',
        notes: '无'),
  ];

  // 当前词索引
  int _currentIndex = 0;

  // 当前正确选项
  int _correctSelection = 0;

  // 当前选择项
  int? _currentSeleted;

  // 答对的单词数
  int _correctCount = 0;

  // 当前的四个选项
  List<String> _selections = ['你好', '再见', '背景', '火车'];

  // 答对和答错的列表
  List<int> _correctWords = [];
  List<int> _errorWords = [];

  void _getInitData() async {
    try {
      dio.get('/sign-recommend?count=${_WordCont * 3}').then((value) {
        ResponseBase<List<WordItemInfo>> res =
            ResponseBase.fromJson(value.data);
        setState(() {
          _words = res.data!;
          _generateSelection(0);
        });
      });
    } catch (e) {
      setState(() {
        _words.addAll([
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
        ]);
      });
    }
  }

  void _generateSelection(int index) {
    // Future.delayed(Duration(seconds: 1),(){
    //   _correctSelection = Random().nextInt(4);
    //   _selections[_correctSelection] = _words[index].word;
    //   for (int i = 0; i < 4; i++) {
    //     if (i != _correctSelection) {
    //       _selections[i] = _words[Random().nextInt(30)].word;
    //     }
    //   }
    //   _currentSeleted = null;
    // });
    _correctSelection = Random().nextInt(4);
    _selections[_correctSelection] = _words[index].word;
    for (int i = 0; i < 4; i++) {
      if (i != _correctSelection) {
        _selections[i] = _words[Random().nextInt(_WordCont * 3)].word;
      }
      _currentSeleted = null;
    }
    setState(() {});
  }

  @override
  void initState() {
    _getInitData();

    super.initState();
  }

  late double deviceWidth;
  late double fontSize;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    fontSize = Provider.of<AppProvider>(context).normalFontSize;

    return Scaffold(
      appBar: AppBar(
        // elevation: 0.8,
        // backgroundColor: Color(0Xeee2e1e4),
        leadingWidth: 300,
        leading: Container(
          child: Row(
            children: [
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  )),
              Text('已得分 : ${_correctCount * 10} \n最高分 : 100',
                  style: TextStyle(color: Colors.grey))
            ],
          ),
        ),
        actions: [
          Center(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: RichText(
              text: TextSpan(
                  text: '当前进度 : ',
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                        text: '$_currentIndex',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    TextSpan(text: ' / $_WordCont')
                  ]),
            ),
          ))
        ],
      ),
      body: Container(
        width: deviceWidth,
        margin: EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Column(
          children: [
            Container(
              width: deviceWidth - 80,
              height: (deviceWidth - 80) * 0.8,
              child: Image.network(_words[_currentIndex].img!,
                  width: deviceWidth - 80, fit: BoxFit.fitWidth),
            ),
            SizedBox(height: 10),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                height: 60,
                child: Text(_words[_currentIndex].description!)),
            SizedBox(height: 60),
            Expanded(
                child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) => _getSelection(index)),
              ),
            )),
            SizedBox(height: 60)
          ],
        ),
      ),
    );
  }

  Widget _getSelection(int index) {
    int ascII = 'A'.codeUnitAt(0);
    Color bg_color = Colors.white;
    if (_currentSeleted != null) {
      if (_correctSelection == index) {
        bg_color = Colors.green;
      } else if (_currentSeleted == index &&
          _currentSeleted != _correctSelection) {
        bg_color = Colors.red;
      }
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        height: 60,
        child: GestureDetector(
          child: Neumorphic(
            // pressed: true,
            padding: EdgeInsets.all(15),
            style: NeumorphicStyle(color: bg_color, depth: 1.5, intensity: 2),
            child: Row(
              children: [
                Text(String.fromCharCode(ascII + index),
                    style: TextStyle(fontSize: fontSize, color: Colors.black)),
                SizedBox(width: 15),
                Text(
                  _selections[index],
                  style: TextStyle(fontSize: fontSize, color: Colors.black),
                )
              ],
            ),
          ),
          onTap: () {
            setState(() {
              _currentSeleted = index;
              if (index == _correctSelection) {
                _correctCount += 1;
                _correctWords.add(_words[_currentIndex].id ?? 0);
              } else {
                _errorWords.add(_words[_currentIndex].id ?? 0);
              }
            });
            Future.delayed(Duration(seconds: 1), () {
              _currentIndex += 1;
              if (_currentIndex >= _WordCont) {
                try {
                  dio.post('/data-sign-game',
                      data: {'correct': _correctWords, 'error': _errorWords});
                } catch (e) {
                  debugPrint(e.toString());
                }
                showInDialog(context, elevation: 0.6,
                    builder: (BuildContext context) {
                  return _correctCount == _WordCont
                      ? Container(
                          height: 200,
                          child: Column(
                            children: [
                              Image.asset('assets/images/game_100_marks.gif',
                                  width: 100, fit: BoxFit.fitWidth),
                              SizedBox(height: 10),
                              Text(
                                '恭喜你，全答对了！',
                                style: TextStyle(
                                    fontSize: fontSize - 3,
                                    color: Colors.black),
                              ),
                              SizedBox(height: 10),
                              NeumorphicButton(
                                style: NeumorphicStyle(color: Colors.blue),
                                child: Text('确认'),
                                onPressed: () {
                                  Navigator.of(context)
                                    ..pop()
                                    ..pop();
                                },
                              )
                            ],
                          ),
                        )
                      : Container(
                          color: Colors.white54,
                          height: 200,
                          child: Column(
                            children: [
                              Text('本次得分',
                                  style: TextStyle(fontSize: fontSize)),
                              SizedBox(height: 20),
                              Text('${_correctCount * 10}',
                                  style: TextStyle(
                                      fontSize: fontSize + 5,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 50),
                              NeumorphicButton(
                                style: NeumorphicStyle(color: Colors.blue),
                                child: Text('确认'),
                                onPressed: () {
                                  Navigator.of(context)
                                    ..pop()
                                    ..pop();
                                },
                              )
                            ],
                          ),
                        );
                });
              } else {
                _generateSelection(_currentIndex);
              }
            });

            // Future.delayed(Duration(seconds: 1));
          },
        ));
  }
}
