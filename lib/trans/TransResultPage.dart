import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/widgets/InputDialog.dart';

class TransResultPage extends StatefulWidget {
  const TransResultPage({
    Key? key,
    required this.mediaPath,
    required this.mediaType,
  }) : super(key: key);
  final String mediaPath;
  final String mediaType;

  @override
  State<TransResultPage> createState() => _TransResultPageState();
}

class _TransResultPageState extends State<TransResultPage> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  String _translatedText = '';

  void _handleVideo() {
    String videoUrl =
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    videoPlayerController = VideoPlayerController.file(File(widget.mediaPath))
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
  }

  void _getTransResult() async {
    if (widget.mediaType == 'video') {
      _handleVideo();

      Map<String, dynamic> data = Map();
      data['file'] = await MultipartFile.fromFile(widget.mediaPath);
      FormData formData = FormData.fromMap(data);

      await dio.post('/trans_video', data: formData,
          onSendProgress: (int send, int total) {
        EasyLoading.showProgress(send * 1.0 / total,
            status: '正在上传', maskType: EasyLoadingMaskType.clear);
      }).then((value) {
        ResponseBase<String> res = ResponseBase.fromJson(value.data);
        EasyLoading.dismiss();
        EasyLoading.showSuccess('上传成功');
        setState(() {
          _translatedText = (res.data) ?? '';
        });
      }).catchError(() => EasyLoading.dismiss());
    } else {
      Map<String, dynamic> data = Map();
      data['file'] = await MultipartFile.fromFile(widget.mediaPath);
      FormData formData = FormData.fromMap(data);
      EasyLoading.showProgress(0.3, status: '正在上传');
      await dio.post('/trans_image', data: formData,
          onSendProgress: (int sended, int total) {
        EasyLoading.showProgress(sended * 1.0 / total,
            status: '正在上传', maskType: EasyLoadingMaskType.clear);
      }).then((value) {
        ResponseBase<String> res = ResponseBase.fromJson(value.data);
        EasyLoading.dismiss();
        EasyLoading.showSuccess('上传成功');
        setState(() {
          _translatedText = (res.data) ?? '';
        });
      }).catchError(() => EasyLoading.dismiss());
    }
  }

  @override
  void initState() {
    super.initState();
    _getTransResult();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.mediaType == 'video') {
      _customVideoPlayerController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = Provider.of<AppProvider>(context).normalFontSize;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('手语识别结果', style: TextStyle(fontSize: fontSize)),
        leading: InkWell(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            width: width,
            height: height / 2,
            child: _getDisplayContainer(),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('手势动作转译文本 : ', style: TextStyle(fontSize: fontSize)),
                SizedBox(height: 10),
                Text(
                  _translatedText,
                  style: TextStyle(fontSize: fontSize - 3, fontFamily: 'KaiTi'),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            child: TextButton(
                onPressed: () async {
                  var res = await showDialog(
                    context: context,
                    builder: (context) => const InputDialog(
                      title: Text('反馈意见'),
                      hintText: '请输入正确释义',
                    ),
                  );
                  if (res.toString().isNotEmpty) {
                    toast('感谢您的反馈');
                  }
                },
                child: Text('错误反馈')),
          ),
        ],
      ),
    );
    return Center(child: Text(widget.mediaPath + widget.mediaType));
  }

  Widget _getDisplayContainer() {
    if (widget.mediaType == 'image') {
      return Image.file(File(widget.mediaPath));
    } else {
      return SafeArea(
          child: CustomVideoPlayer(
        customVideoPlayerController: _customVideoPlayerController,
      ));
    }
  }
}
