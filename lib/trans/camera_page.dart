import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sign_language/net/httpapi.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String _transText = '';
  bool _visiable = false;

  @override
  void initState() {
    _transText = '翻译文本将在这里显示...';
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initializeControllerFuture = _cameraController?.initialize();
    setState(() {});
  }

  // 上传视频流
  Future<void> sendCameraStream() async {
    final _dio = Dio();
    _cameraController?.startImageStream((image) {
      _dio.post(HttpApi.baiduImgRecognise, data: {'image': image});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.text_fields),
        onPressed: () {
          setState(() {
            _visiable = !_visiable;
          });
        },
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// 相机画面
          FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.width /
                        MediaQuery.of(context).size.height,
                    child: CameraPreview(_cameraController!),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),

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
                    padding: const EdgeInsets.all(10),
                    scrollDirection: Axis.vertical,
                    child: Text(
                      _transText,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: _transText.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
