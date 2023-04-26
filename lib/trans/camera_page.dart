import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

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
  bool _visiable = false;
  bool _startUpVideo = false;

  late IO.Socket socket;

  int currentCameraIndex = 0;

  StreamSocket streamSocket = StreamSocket();

  @override
  void initState() {
    super.initState();
    _transText = '翻译文本将在这里显示...';
    _cameraController = CameraController(
        widget.cameras[currentCameraIndex % widget.cameras.length],
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420);
    _initializeControllerFuture = _cameraController?.initialize();
    startSocketChannel();
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
    _cameraController?.startImageStream((CameraImage image) async {
      // debugPrint("self-def image.format.groupName ${image.format.group.name}");
      //
      // debugPrint("self-def image.format.raw ${image.format.raw}");
      // debugPrint("self-def width ${image.width}");
      // debugPrint("self-def height ${image.height}");
      // debugPrint(
      //     "self-def image.planes.first.bytesPerPixel ${image.planes.first.bytesPerPixel}");
      // debugPrint(
      //     "self-def image.planes.first.bytesPerRow ${image.planes.first.bytesPerRow}");
      //
      // debugPrint("self-def planes ${image.planes.length}");
      // debugPrint("self-def planes[0] ${image.planes.first.bytes.length}");
      // debugPrint("self-def planes[1] ${image.planes[1].bytes.length}");
      // debugPrint("self-def planes[1] ${image.planes[1].bytes.toList()}");
      // debugPrint("self-def planes[2] ${image.planes[2].bytes.length}");
      // debugPrint("self-def planes[2] ${image.planes[2].bytes.toList()}");

      Future.microtask(() async {
        Yuvtransform.yuvTransform(image).then((res) {
          debugPrint(
              "${res[0]},${res[1]},${res[2]},${res[res.length - 1]},${res[res.length - 2]}");
          socket.emit('video', res);
          debugPrint("self-def res-length ${res.length}");
        });
      });
      // _cameraController?.stopImageStream();
    });
  }

  void startSocketChannel() {
    socket = IO.io(
        'http://100.78.174.234:5002',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.connect();
    // socket.on("trans", (data) {
    //   _transText += data.toString();
    //   debugPrint("self-def trans $data");
    //   setState(() {});
    // });
    socket.on('trans', (data) {
      streamSocket.addResponse(data);
      debugPrint("self-def trans $data");
    });
    socket.onDisconnect((_) => print('disconnect'));
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
              opacity: _visiable ? 1.0 : 0.0,
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
                      child: /*Text(
                      _transText,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color:
                        _transText.isEmpty ? Colors.grey : Colors.black,
                      ),
                    )*/
                          StreamBuilder(
                        stream: streamSocket.getResponse,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          return Text(
                            (snapshot.data) ?? '翻译文本',
                            maxLines: 10,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: _transText.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          );
                        },
                      ),
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
                iconList: const [
                  Icon(Icons.help_outline),
                  Icon(Icons.handshake),
                  Icon(Icons.cameraswitch),
                  Icon(Icons.text_fields),
                  Icon(Icons.multitrack_audio),
                  Icon(Icons.keyboard_backspace)
                ],
                clickCallback: (int index) async {
                  debugPrint("点击了$index");
                  if (index == 0) {
                    debugPrint("点击反转摄像头");
                  } else if (index == 1) {
                    try {
                      sendCameraStream();
                    } catch (e) {
                      debugPrint("开始视频 $e");
                    }
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
                  } else if (index == 3) {
                    _visiable = !_visiable;
                    setState(() {});
                  } else if (index == 4) {
                    debugPrint("转语音");
                  } else if (index == 5) {
                    try {
                      _cameraController?.stopImageStream();
                    } catch (e) {
                      debugPrint("停止视频 - $e");
                    }
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
