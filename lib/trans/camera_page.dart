import 'dart:async';
import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/system/AudioUtil.dart';
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
  String _newTranslated = "";

  late IO.Socket socket;

  int currentCameraIndex = 0;

  StreamSocket streamSocket = StreamSocket();

  @override
  void initState() {
    super.initState();
    _transText = '文本 : ';
    _cameraController = CameraController(
        widget.cameras[currentCameraIndex % widget.cameras.length],
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420);
    _initializeControllerFuture = _cameraController?.initialize();
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

  void sendCameraStream() {
    int _imgIndex = 0;
    int _imgIndex2 = 0;
    _cameraController?.startImageStream((CameraImage image) async {
      _imgIndex = (_imgIndex + 1) % 7;
      _imgIndex2 = (_imgIndex2 + 1) % 150;
      if (_imgIndex == 0) {
        Future.microtask(() async {
          Yuvtransform.yuvTransform(image).then((res) {
            socket.emit('video', res);
            // debugPrint("self-def res-length ${res.length}");
          });
        });
      } else if (_imgIndex2 == 0) {
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
                AudioUtil.playText(temp);
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
    });
  }

  void startSocketChannel() {
    socket = IO.io(
        'http://47.103.223.106:5002',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableReconnection() // disable auto-connection
            .build());
    socket.on('connect', (data) => debugPrint('self-def socket 连接开始'));
    socket.on('trans', (data) {
      setState(() {
        _transText += data.toString();
      });
      streamSocket.addResponse(data);
      if (_text2Audio) {
        AudioUtil.playText(data.toString());
      }
      debugPrint("self-def trans $data");
    });
    socket.onDisconnect((_) => print('disconnect'));

    socket.connect();
  }

  Uint8List convertYUV420(CameraImage image) {
    var Y = image.planes[0].bytes.toList();
    var U = image.planes[1].bytes.toList();
    // var V = image.planes[2].bytes.toList();
    int bytesPerRow = image.planes.first.bytesPerRow;
    int quotient = (bytesPerRow ~/ 255);
    int remainder = (bytesPerRow % 255);
    var result = List<int>.empty(growable: true);
    // byte1*255*255 + bytes2*255 + byte3 为灰度通道Y的长度
    // quotient*255 + remainder 为图片宽度
    int byte1 = Y.length ~/ (255 * 255);
    int temp = Y.length % (255 * 255);
    int byte2 = temp ~/ 255;
    int byte3 = temp % 255;
    result
      ..add(byte1)
      ..add(byte2)
      ..add(byte3)
      ..add(quotient)
      ..add(remainder)
      ..addAll(Y)
      ..addAll(U);
    // ..addAll(V);
    return Uint8List.fromList(result);
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
                      // child: StreamBuilder(
                      //   stream: streamSocket.getResponse,
                      //   builder: (BuildContext context,
                      //       AsyncSnapshot<String> snapshot) {
                      //     return Text(
                      //       (snapshot.data) ?? '翻译文本',
                      //       maxLines: 10,
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.normal,
                      //         color: _transText.isEmpty
                      //             ? Colors.grey
                      //             : Colors.black,
                      //       ),
                      //     );
                      //   },
                      // ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 20,
              child: RoteFloatingButton(
                iconSize: 56,
                iconList: [
                  Icon(Icons.help_outline),
                  Icon(Icons.handshake,
                      color: _startUpVideo ? Colors.blue : Colors.white),
                  Icon(Icons.cameraswitch),
                  Icon(Icons.text_fields,
                      color: _visitable ? Colors.blue : Colors.white),
                  Icon(Icons.multitrack_audio,
                      color: _text2Audio ? Colors.blue : Colors.white),
                  Icon(Icons.keyboard_backspace)
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
                      _cameraController?.stopImageStream();
                    } catch (e) {
                      debugPrint("停止视频 - $e");
                    }
                    // Navigator.pop(context);
                  } else {}
                },
              ),
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
