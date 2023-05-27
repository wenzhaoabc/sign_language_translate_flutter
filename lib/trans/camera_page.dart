import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/toolkit/xfyy/utils/xf_socket.dart';
import 'package:sign_language/utils/AudioUtil.dart';
import 'package:sign_language/utils/ToastUtil.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yuvtransform/yuvtransform.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String _transText = '';
  bool _visitable = false;
  bool _startUpVideo = false;
  bool _text2Audio = false;
  bool _withHand = true;
  String _newTranslated = "";

  late IO.Socket socket;

  int currentCameraIndex = 0;

  StreamSocket streamSocket = StreamSocket();

  @override
  void initState() {
    super.initState();
    startSocketChannel();
    _transText = '文本 : ';
    _cameraController = CameraController(
        widget.cameras[currentCameraIndex % widget.cameras.length],
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420);
    _initializeControllerFuture = _cameraController?.initialize();
    initPlay();
  }

  @override
  void dispose() {
    if (_startUpVideo) {
      _cameraController?.stopImageStream();
    }
    _cameraController?.dispose();
    socket.destroy();
    super.dispose();
  }

  final FlutterSoundPlayer playerModule = FlutterSoundPlayer();

  void _play(String path) async {
    await playerModule.startPlayer(fromURI: path);
  }

  initPlay() async {
    await playerModule.closePlayer();
    await playerModule.openPlayer();
    await playerModule
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  void sendCameraStream() {
    int _imgIndex = 0;
    int _imgIndex2 = 0;
    if (socket.disconnected) {
      EasyLoading.showError('网络未连接');
      return;
    }
    _cameraController?.startImageStream((CameraImage image) async {
      _imgIndex = (_imgIndex + 1) % 5;
      _imgIndex2 = (_imgIndex2 + 1) % 60;
      if (_imgIndex == 0) {
        Future.microtask(() async {
          Yuvtransform.yuvTransform(image).then((res) {
            socket.emit('video', res);
            // debugPrint("self-def res-length ${res.length}");
          });
        });
      }
      if (_imgIndex2 == 0) {
        Future.microtask(() async {
          dio.get('/trans_text').then((value) {
            ResponseBase<String> text = ResponseBase.fromJson(value.data);
            var temp = '';
            if (text.data != null) {
              temp = text.data.toString();
            }
            debugPrint("self-def $temp");
            if (temp.isNotEmpty && temp != _newTranslated) {
              if (_text2Audio) {
                XfSocket.connect(temp, onFilePath: (path) {
                  _play(path);
                });
              }
              setState(() {
                _newTranslated = temp;
                _transText += _newTranslated;
              });
            } else {
              EasyLoading.showInfo('正在推理...');
            }
          });
        });
      }
      if (_imgIndex2 % 40 == 0) {
        EasyLoading.showInfo('正在推理...');
      } else {}
    });
  }

  void startSocketChannel() {
    socket = IO.io(
        Constant.baseURL,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableReconnection() // disable auto-connection
            .build());
    socket.on('connect', (data) => debugPrint('self-def socket 连接开始'));
    socket.on('hand', (data) {
      data = data as bool;
      setState(() {
        _withHand = data;
      });
    });
    socket.onDisconnect((_) => debugPrint('disconnect'));
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            /// 相机画面
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: width / height,
                    child: CameraPreview(_cameraController!),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),

            /// 底部弹窗
            AnimatedOpacity(
              opacity: _visitable ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 200,
                  child: Neumorphic(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      scrollDirection: Axis.vertical,
                      child: Text(
                        _transText ?? '翻译文本',
                        maxLines: 10,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color:
                              _transText.isEmpty ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 右下角按钮
            Positioned(
              right: 10,
              bottom: 20,
              child: RoteFloatingButton(
                iconSize: 56,
                iconList: [
                  Icon(Icons.help_outline, color: Colors.grey),
                  Icon(Icons.handshake,
                      color: _startUpVideo ? Colors.blue : Colors.grey),
                  Icon(Icons.cameraswitch, color: Colors.grey),
                  Icon(Icons.text_fields,
                      color: _visitable ? Colors.blue : Colors.grey),
                  Icon(Icons.multitrack_audio,
                      color: _text2Audio ? Colors.blue : Colors.grey),
                  Icon(Icons.keyboard_backspace, color: Colors.grey)
                ],
                clickCallback: (int index) async {
                  debugPrint("点击了$index");
                  if (index == 0) {
                    debugPrint("索引为0");

                    ///
                    ///
                  } else if (index == 1) {
                    try {
                      if (socket.disconnected) {
                        startSocketChannel();
                      }
                    } catch (e) {
                      startSocketChannel();
                    }

                    if (_startUpVideo == false) {
                      try {
                        sendCameraStream();
                        setState(() {
                          _startUpVideo = !_startUpVideo;
                        });
                        MyToast.showToast(msg: '翻译开始');
                      } catch (e) {
                        MyToast.showToast(msg: '网络连接失败');
                      }
                    } else {
                      try {
                        setState(() {
                          _startUpVideo = !_startUpVideo;
                        });
                        _cameraController?.stopImageStream();
                        MyToast.showToast(msg: '翻译暂停');
                      } catch (e) {
                        debugPrint("图片流暂停失败");
                      }
                    }

                    ///
                    ///
                  } else if (index == 2) {
                    try {
                      _cameraController?.stopImageStream();
                      currentCameraIndex++;
                      _cameraController = CameraController(
                          widget.cameras[
                              currentCameraIndex % widget.cameras.length],
                          ResolutionPreset.low,
                          enableAudio: false,
                          imageFormatGroup: ImageFormatGroup.yuv420);
                      await _cameraController?.initialize();
                      setState(() {});
                      debugPrint(" --  -- 摄像头反转");
                    } catch (e) {
                      debugPrint("反转摄像头失败");
                    }

                    ///
                    ///
                  } else if (index == 3) {
                    setState(() {
                      _visitable = !_visitable;
                    });

                    ///
                    ///
                  } else if (index == 4) {
                    setState(() {
                      _text2Audio = !_text2Audio;
                    });
                    debugPrint("转语音");

                    ///
                    ///
                  } else if (index == 5) {
                    try {
                      // _cameraController?.hasListeners;
                      _cameraController?.stopImageStream();
                      _cameraController?.dispose();
                      socket.close();
                      socket?.dispose();
                    } catch (e) {
                      debugPrint("停止视频 - $e");
                      // Navigator.pop(context);
                    }
                    // dispose();
                    Navigator.pop(context);
                  } else {}
                },
              ),
            ),

            /// 手部提示
            Positioned(
              top: 40,
              // offstage: _startUpVideo,
              child: AnimatedOpacity(
                  opacity: _startUpVideo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.waving_hand,
                    color: _withHand ? Colors.green : Colors.grey,
                    size: 40,
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
