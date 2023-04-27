import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_language/trans/camera_page.dart';
import 'package:sign_language/res/constant.dart';

class TransPage extends StatefulWidget {
  const TransPage({Key? key}) : super(key: key);

  @override
  State<TransPage> createState() => _TransPageState();
}

class _TransPageState extends State<TransPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
  }

  Future requestPermission() async {
    var status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  void startVideo() async {
    // 请求权限
    var permitCamera = await requestPermission();
    if (permitCamera) {
      final cameras = await availableCameras();
      // final camera = cameras.first;
      // Navigator.of(context).push(CameraPage(camera: camera));
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CameraPage(cameras: cameras)));
    } else {
      print('无相机权限');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(Constant.first_bg_url),
            // image: AssetImage("images/R_C.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text('翻译'),
            // backgroundColor: Colors.transparent,
            backgroundColor: Color.fromARGB(0x10, 0, 0, 0),
          ),
          body: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: _CameraPreview(),
                  ),
                  Center(
                    child: FloatingActionButton.large(
                      onPressed: () => startVideo(),
                      // backgroundColor: Colors.deepPurpleAccent,
                      backgroundColor: Colors.deepPurpleAccent,
                      // foregroundColor: Colors.white,
                      // 阴影范围
                      elevation: 10,
                      // 点击触发时的颜色
                      splashColor: Colors.red,
                      child: const Icon(
                        Icons.videocam_outlined,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Center(
                child: Text(
                  '点击录制，开始翻译',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 150,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Tips：'),
                    Text('1.手持扶稳效果更好'),
                    Text('2.确保手势完全包裹在取景框内')
                  ],
                ),
              ),
            ],
          ),
          // backgroundColor: Colors.transparent,
          backgroundColor: Color.fromARGB(0x11, 0, 0, 0),
        ));
  }

  Widget _CameraPreview() {
    return Container(
        // color: Colors.grey,
        );
  }
}
