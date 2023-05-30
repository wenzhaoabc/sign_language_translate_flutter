import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/toolkit/xfyy/utils/xf_socket.dart';
import 'package:sign_language/widgets/InputDialog.dart';

import 'package:sign_language/widgets/VoiceAnimationWidget.dart';

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
  var _fastReplyText = [
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

  ///
  bool _textIsNotEmpty = false;

  // final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        setState(() {
          _textIsNotEmpty = true;
        });
      } else {
        setState(() {
          _textIsNotEmpty = false;
        });
      }
    });
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
  void dispose() {
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

  late double _fontSize;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fontSize = Provider.of<AppProvider>(context).normalFontSize;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // VoiceAnimation(voiceNum: voiceNum),
              const SizedBox(height: 80),
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
              const SizedBox(height: 20),
              RotatedBox(quarterTurns: 2, child: _chatOther()),
              const SizedBox(height: 20),
              const Divider(height: 5, color: Colors.green),
              const SizedBox(height: 20),

              _chatOther(),
              const SizedBox(height: 20),
              _chatSelf(),
            ],
          ),

          // Divider(thickness: 3,color: Colors.grey),
          Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                    color: const Color(0xFFfffef9),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                            onPressed: () {
                              ImagePickers.openCamera(
                                      cameraMimeType: CameraMimeType.video,
                                      videoRecordMaxSecond: 15)
                                  .then((value) async {
                                if (value != null && value.path != null) {
                                  Map<String, dynamic> data = Map();
                                  data['file'] =
                                      await MultipartFile.fromFile(value.path!);
                                  FormData formData = FormData.fromMap(data);

                                  await dio.post('/trans_video', data: formData,
                                      onSendProgress: (int send, int total) {
                                    EasyLoading.showProgress(send * 1.0 / total,
                                        status: '正在上传',
                                        maskType: EasyLoadingMaskType.clear);
                                  }).then((value) {
                                    ResponseBase<String> res =
                                        ResponseBase.fromJson(value.data);
                                    EasyLoading.dismiss();
                                    EasyLoading.showSuccess('上传成功');
                                    XfSocket.connect(res.data ?? '',
                                        onFilePath: (path) {
                                      _play(path);
                                    });
                                    setState(() {
                                      _selfText = res.data ?? '';
                                    });
                                  });
                                }
                              });
                            },
                            enableFeedback: true,
                            icon: const Icon(Icons.linked_camera_outlined,
                                size: 30)),
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 100.0,
                              minHeight: 50.0,
                            ),
                            child: TextField(
                              controller: textEditingController,
                              cursorColor: Colors.black,
                              maxLines: null,
                              maxLength: 200,
                              focusNode: _focusNode,
                              decoration: const InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 10),
                                  hintText: "输入内容...",
                                  hintStyle: TextStyle(
                                      color: Color(0xFFADB3BA), fontSize: 15),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0))),
                              style: const TextStyle(
                                  color: Color(0xFF03073C), fontSize: 15),
                            ),
                          ),
                        ),
                        _textIsNotEmpty
                            ? TextButton(
                                onPressed: () {
                                  var text = textEditingController.text;
                                  XfSocket.connect(text, onFilePath: (path) {
                                    _play(path);
                                  });
                                  setState(() {
                                    _selfText = text;
                                  });
                                  textEditingController.clear();
                                },
                                child: const Text('发送'))
                            : TextButton(
                                onPressed: () {
                                  if (_focusNode.hasFocus) {
                                    setState(() {
                                      _focusNode.unfocus();
                                    });
                                  }
                                  setState(() {
                                    _fastReply = !_fastReply;
                                  });
                                },
                                child: const Text('快捷短语'))
                      ],
                    )),
                Visibility(
                  visible: _fastReply,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    height: 250,
                    child: ListView.builder(
                      itemCount: _fastReplyText.length + 1,
                      itemBuilder: (BuildContext bc, int index) {
                        if (index == _fastReplyText.length) {
                          return IconButton(
                            onPressed: () async {
                              var res = await showDialog(
                                context: context,
                                builder: (context) => const InputDialog(
                                  title: Text('快捷短语'),
                                  hintText: '请输入新增快捷短语',
                                ),
                              );
                              debugPrint("res = $res");
                              setState(() {
                                if (res.toString().isNotEmpty) {
                                  _fastReplyText.add(res);
                                }
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            selectedIcon: const Icon(
                              Icons.add_circle,
                              color: Colors.blue,
                            ),
                          );
                        } else {
                          return Slidable(
                            startActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                // openThreshold: 0.6,
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext context) {
                                      setState(() {
                                        _fastReplyText
                                            .remove(_fastReplyText[index]);
                                      });
                                    },
                                    // flex: 10,
                                    spacing: 10,
                                    autoClose: true,
                                    // icon: Icons.delete,
                                    label: '删除',
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                  )
                                ]),
                            child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                // height: ,
                                padding: const EdgeInsets.only(
                                    left: 20, bottom: 10, top: 10),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black12, width: 1))),
                                child: GestureDetector(
                                  onTap: () {
                                    textEditingController.text =
                                        _fastReplyText[index];
                                  },
                                  child: Text(
                                    _fastReplyText[index],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                )),
                          );
                        }
                      },
                    ),
                  ),
                ),
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
        const Padding(
            padding: EdgeInsets.only(left: 18),
            child: CircleAvatar(
              backgroundColor: Colors.lightBlue,
              child: Icon(
                Icons.mic_none_rounded,
                color: Colors.white,
              ),
            )),
        _chatTypeText(text.isEmpty ? "【对方文本】" : text)
      ],
    );
  }

  /// 己方消息
  Widget _chatSelf() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chatTypeText(_selfText.isEmpty ? "【己方文本】" : _selfText),
        const Padding(
          padding: EdgeInsets.only(right: 18),
          child: CircleAvatar(
            // foregroundColor: Colors.white,
            backgroundColor: Colors.green,
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
    // double deviceWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          constraints: const BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: const Color.fromARGB(0xba, 69, 183, 135),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          child: Text(
            text,
            softWrap: true,
            style: TextStyle(fontSize: _fontSize - 4),
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
