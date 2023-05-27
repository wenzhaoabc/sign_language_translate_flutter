import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/toolkit/chat_bottom_input.dart';
import 'package:sign_language/toolkit/xfyy/utils/xf_socket.dart';

import 'package:sign_language/widgets/VoiceAnimationWidget.dart';

/// 作者： lixp
/// 创建时间： 2022/6/17 10:21
/// 类介绍：语音转文本
class VoiceText extends StatefulWidget {
  const VoiceText({Key? key}) : super(key: key);

  @override
  _VoiceTextState createState() => _VoiceTextState();
}

class _VoiceTextState extends State<VoiceText> {
  final FlutterSoundRecorder _mRecorder =
      FlutterSoundRecorder(logLevel: Level.debug);

  /// 实时语音听写
  /// 最长支持1分钟即使语音听写
  /// 超出1分钟请参考语音转写
  Timer? _timer;
  int currentTime = 60;

  XfSocket? xfSocket;

  /// 识别文本
  String text = "";

  /// 是否在说话
  bool isTalking = false;

  /// 声音大小 0 - 120
  ValueNotifier<double> voiceNum = ValueNotifier<double>(0.0);

  /// 输入控制
  late TextEditingController textEditingController;
  late FocusNode _focusNode;
  final _fastReplyText = [
    '我很抱歉，我听不到你说什么。',
    '请说得慢一点，我听不清楚。',
    '请不要紧张，我可以和你交流。',
    '你好，我是一名聋哑人士，我想和你聊天。',
    '我喜欢音乐，尤其是摇滚乐。你呢？',
    '我喜欢画画，特别是水彩画。',
    '我喜欢旅行，去过很多地方。你有没有去过哪些地方？',
    '我很乐观，因为我相信生活总会好起来的。',
    '我很善良，因为我想为那些需要帮助的人伸出援手。',
    '我喜欢读书，尤其是关于历史和文学的书籍。你呢？',
  ];

  String _selfText = "";

  /// 点击快捷短语
  bool _fastReply = false;

  /// 录音
  final FlutterSoundPlayer playerModule = FlutterSoundPlayer();

  // final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    textEditingController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _fastReply = false;
        });
      } else {
        setState(() {
          _fastReply = false;
        });
      }
    });
    super.initState();

    initRecorder();
    initPlay();
  }

  @override
  void dispose(){
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 初始化播放
  initPlay() async {
    await playerModule.closePlayer();
    await playerModule.openPlayer();
    await playerModule
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  void _play(String path) async {
    await playerModule.startPlayer(fromURI: path);
  }

  /// 初始化录音
  Future<void> initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder.openRecorder();

    // 设置音频音量获取频率
    _mRecorder.setSubscriptionDuration(
      const Duration(milliseconds: 100),
    );
    _mRecorder.onProgress!.listen((event) {
      // 0 - 120
      voiceNum.value = event.decibels ?? 0;
    });

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  StreamSubscription? _mRecordingDataSubscription;

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    voiceNum.value = 0.0;
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
  }

  late double _deviceHeight;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      /*appBar: AppBar(
        centerTitle: true,
        title: const Text('语音识别'),
        elevation: 1,
        leading: InkWell(
          child: Icon(Icons.arrow_back_sharp, color: Colours.dark_btn_icon),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),*/
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /*Container(
            margin: const EdgeInsetsDirectional.only(
                start: 20, end: 20, top: 100, bottom: 50),
            child: Text(
              "识别结果：$text",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),*/
              // VoiceAnimation(voiceNum: voiceNum),
              SizedBox(height: 80),
              RotatedBox(
                  quarterTurns: 2,
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(top: 10),
                    child: const Text(
                      "长按录音",
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
              RotatedBox(
                  quarterTurns: 2,
                  child: Container(
                      margin: const EdgeInsetsDirectional.only(top: 60),
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: isTalking ? Colors.red : Colors.black87,
                              width: 2),
                          // color: Colors.blue,
                          shape: BoxShape.circle),
                      child: GestureDetector(
                        onLongPressStart: (d) {
                          setState(() {
                            isTalking = true;
                          });
                          _timer = Timer.periodic(const Duration(seconds: 1),
                              (timer) {
                            currentTime--;
                            if (currentTime == 0) {
                              _timer?.cancel();
                              // 时间结束
                            }
                          });
                          xfSocket =
                              XfSocket.connectVoice(onTextResult: (text) {
                            setState(() {
                              this.text = text;
                            });
                          });
                          state = 0;
                          startRecord();
                        },
                        child: Icon(
                          Icons.keyboard_voice_rounded,
                          color: isTalking ? Colors.red : Colors.black87,
                          size: 60,
                        ),
                        onLongPressEnd: (d) {
                          _timer?.cancel();
                          state = 2;
                          setState(() {
                            isTalking = false;
                          });
                          stopRecorder();
                        },
                      ))),
              RotatedBox(quarterTurns: 2, child: _chatSelf()),
              // _chatOther(),
              SizedBox(height: 20),
              RotatedBox(quarterTurns: 2, child: _chatOther()),
              SizedBox(height: 20),
              Divider(height: 5, color: Colors.green),
              SizedBox(height: 20),

              _chatSelf(),
              SizedBox(height: 20),
              _chatOther(),

            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                        constraints: BoxConstraints(
                          maxHeight: 100.0,
                          minHeight: 50.0,
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xFFF5F6FF),
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        child: TextField(
                          controller: textEditingController,
                          cursorColor: Color(0xFF464EB5),
                          maxLines: null,
                          maxLength: 200,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 10.0,
                                bottom: 10.0),
                            hintText: "回复",
                            hintStyle: TextStyle(
                                color: Color(0xFFADB3BA), fontSize: 15),
                          ),
                          style:
                              TextStyle(color: Color(0xFF03073C), fontSize: 15),
                        ),
                      ),
                    ),
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          alignment: Alignment.center,
                          height: 70,
                          child: Text(
                            '短语',
                            style: TextStyle(
                              color: Color(0xFF464EB5),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_focusNode.hasFocus) {
                            setState(() {
                              _focusNode.unfocus();
                            });
                          }
                          setState(() {
                            _fastReply = !_fastReply;
                          });
                        }),
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          alignment: Alignment.center,
                          height: 70,
                          child: Text(
                            '发送',
                            style: TextStyle(
                              color: Color(0xFF464EB5),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onTap: () {
                          var text = textEditingController.text;
                          XfSocket.connect(text, onFilePath: (path) {
                            _play(path);
                          });
                          setState(() {
                            _selfText = text;
                          });
                          textEditingController.clear();
                        }),
                  ],
                ),
                _fastReply
                    ? Container(
                        height: 250,
                        color: Colors.white,
                        margin:
                            EdgeInsets.only(left: 15, right: 15, bottom: 20),
                        // padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                        child: ListView.builder(
                            itemCount: _fastReplyText.length,
                            itemBuilder: (context, index) {
                              return TextButton(
                                onPressed: () {
                                  textEditingController.text =
                                      _fastReplyText[index];
                                },
                                child: Text(_fastReplyText[index]),
                                autofocus: false,
                                style: ButtonStyle(
                                    alignment: Alignment.centerLeft,
                                    textStyle: MaterialStateProperty.all(
                                      TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    )),
                              );
                            }),
                      )
                    : Container(),
                /*Container(
                    child: _fastReply
                        ? Container(
                            child: ListView.builder(
                                itemCount: 2,
                                itemBuilder: (context, int) {
                                  return Text('data');
                                }),
                          )
                        : SizedBox(height: 1))*/
              ],
            ),
          )
        ],
      ),
    );
  }

  //#region 聊天Widget
  ///Widget - 聊天widget
  ///对方消息
  Widget _chatOther() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 18),
            child: CircleAvatar(
              child: Icon(
                Icons.mic_none_rounded,
                color: Colors.white,
              ),
            )),
        _chatTypeText(text.isEmpty ? "说点什么..." : text)
      ],
    );
  }

  /// 己方消息
  Widget _chatSelf() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chatTypeText(_selfText.isEmpty ? "说你想说..." : _selfText),
        Padding(
          padding: EdgeInsets.only(right: 18),
          child: CircleAvatar(
            child: Icon(
              Icons.text_fields,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _chatTypeText(String text) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: 5, right: 5),
          constraints: BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          child: Text(
            text,
            softWrap: true,
          ),
        ),
        // Positioned(
        //   top: 25,
        //   left: 10,
        //   child: CustomPaint(
        //     size: Size(20, 30),
        //     painter: TrianglePainter(),
        //   ),
        // ),
      ],
    );
  }

  /// 底部输入框

  ///
  //#endregion

  //#region 发送音频
  /// 0 :第一帧音频
  /// 1 :中间的音频
  /// 2 :最后一帧音频，最后一帧必须要发送
  int state = 0;

  Future<void> startRecord() async {
    var recordingDataController = StreamController<FoodData>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (state == 0) {
        xfSocket?.sendVoice(buffer.data!, state: state);
        state = 1;
      } else if (state == 1) {
        xfSocket?.sendVoice(buffer.data!, state: state);
      } else if (state == 2) {
        xfSocket?.sendVoice(buffer.data!, state: state);
        state = -1;
      }
    });
    await _mRecorder.startRecorder(
      // toFile: "filePath",
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
    );
  }
//#endregion
}
