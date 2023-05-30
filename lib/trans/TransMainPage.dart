import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/toolkit/voice_to_text.dart';
import 'package:sign_language/trans/TransResultPage.dart';
import 'package:sign_language/trans/camera_page.dart';

class TransMainPage extends StatefulWidget {
  const TransMainPage({Key? key}) : super(key: key);

  @override
  State<TransMainPage> createState() => _TransMainPageState();
}

class _TransMainPageState extends State<TransMainPage> {
  static const bg_img_url = 'assets/images/trans_bg.jpg';
  static const img_trans_camera = 'assets/images/trans_camera.png';
  static const img_video_trans = 'assets/images/trans_video.png';
  static const img_image_trans = 'assets/images/trans_image.png';
  static const img_bothway_talk = 'assets/images/trans_bothway.png';
  static const img_selection_gallery = 'assets/images/trans_gallery.png';
  static const img_selection_camera = 'assets/images/trans_camera_green.png';

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    double fontSize = Provider.of<AppProvider>(context).normalFontSize - 5;
    bool inLargeFont = Provider.of<AppProvider>(context).inLargeFont;

    return Scaffold(
      body: Column(
        children: [
          // 顶部
          Stack(
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.white30,
                        Colors.transparent,
                      ]).createShader(bounds);
                },
                child: Image.asset(bg_img_url, fit: BoxFit.fitWidth),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: const Center(
                    child: Text('无障碍交流', style: TextStyle(fontSize: 20))),
              ),
              Neumorphic(
                margin: const EdgeInsets.only(top: 130, left: 30, right: 30),
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                style: const NeumorphicStyle(
                    color: Colors.white70, depth: 5, intensity: 0.7),
                child: inLargeFont
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                child: Column(
                                  children: [
                                    Image.asset(img_trans_camera,
                                        width: 40,
                                        height: 50,
                                        fit: BoxFit.fitWidth),
                                    const SizedBox(height: 5),
                                    Text(
                                      '实时手语',
                                      style: TextStyle(fontSize: fontSize),
                                    )
                                  ],
                                ),
                                onTap: () async {
                                  var permitCamera =
                                  await Permission.camera.request();
                                  if (permitCamera == PermissionStatus.granted) {
                                    final cameras = await availableCameras();
                                    Navigator.of(context, rootNavigator: true).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CameraPage(cameras: cameras)));
                                    debugPrint("点击实时翻译");
                                  }
                                },
                              ),
                              GestureDetector(
                                child: Column(
                                  children: [
                                    Image.asset(img_video_trans,
                                        width: 43,
                                        height: 50,
                                        fit: BoxFit.fitWidth),
                                    const SizedBox(height: 5),
                                    Text(
                                      '手语视频',
                                      style: TextStyle(fontSize: fontSize),
                                    )
                                  ],
                                ),
                                onTap: () async {
                                  var res = await await _showCustomModalBottomSheet(
                                      context, null);

                                  if (res == 0) {
                                    // 选择相册
                                    ImagePickers.pickerPaths(
                                        galleryMode: GalleryMode.video,
                                        selectCount: 1)
                                        .then((value) {
                                      if (value.isNotEmpty) {
                                        var video = value[0];
                                        if (video.path != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => TransResultPage(
                                                  mediaPath: video.path!,
                                                  mediaType: 'video'),
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  } else if (res == 1) {
                                    // 相机拍摄
                                    ImagePickers.openCamera(
                                      cameraMimeType: CameraMimeType.video,
                                      videoRecordMaxSecond: 15,
                                    ).then((value) {
                                      if (value != null) {
                                        if (value.path != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => TransResultPage(
                                                  mediaPath: value.path!,
                                                  mediaType: 'video'),
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                child: Column(
                                  children: [
                                    Image.asset(img_image_trans,
                                        width: 42,
                                        height: 50,
                                        fit: BoxFit.fitWidth),
                                    const SizedBox(height: 5),
                                    Text(
                                      '手语图片',
                                      style: TextStyle(fontSize: fontSize),
                                    )
                                  ],
                                ),
                                onTap: () async {
                                  var res = await await _showCustomModalBottomSheet(
                                      context, null);

                                  if (res == 0) {
                                    // 选择相册
                                    ImagePickers.pickerPaths(
                                        galleryMode: GalleryMode.image,
                                        selectCount: 1,
                                        showGif: false,
                                        showCamera: true)
                                        .then((value) {
                                      if (value.isNotEmpty) {
                                        var image = value[0];
                                        if (image.path != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => TransResultPage(
                                                  mediaPath: image.path!,
                                                  mediaType: 'image'),
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  } else if (res == 1) {
                                    // 相机拍摄
                                    ImagePickers.openCamera(
                                      cameraMimeType: CameraMimeType.photo,
                                    ).then((value) {
                                      if (value != null) {
                                        if (value.path != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => TransResultPage(
                                                  mediaPath: value.path!,
                                                  mediaType: 'image'),
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  }
                                },
                              ),
                              GestureDetector(
                                child: Column(
                                  children: [
                                    Image.asset(img_bothway_talk,
                                        width: 40,
                                        height: 50,
                                        fit: BoxFit.fitWidth),
                                    const SizedBox(height: 5),
                                    Text(
                                      '双向对话',
                                      style: TextStyle(fontSize: fontSize),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => const VoiceText()),
                                  );
                                  debugPrint("点击双向对话");
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(img_trans_camera,
                                    width: 40,
                                    height: 50,
                                    fit: BoxFit.fitWidth),
                                const SizedBox(height: 5),
                                Text(
                                  '实时手语',
                                  style: TextStyle(fontSize: fontSize),
                                )
                              ],
                            ),
                            onTap: () async {
                              var permitCamera =
                                  await Permission.camera.request();
                              if (permitCamera == PermissionStatus.granted) {
                                final cameras = await availableCameras();
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CameraPage(cameras: cameras)));
                                debugPrint("点击实时翻译");
                              }
                            },
                          ),
                          GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(img_video_trans,
                                    width: 43,
                                    height: 50,
                                    fit: BoxFit.fitWidth),
                                const SizedBox(height: 5),
                                Text(
                                  '手语视频',
                                  style: TextStyle(fontSize: fontSize),
                                )
                              ],
                            ),
                            onTap: () async {
                              var res = await await _showCustomModalBottomSheet(
                                  context, null);

                              if (res == 0) {
                                // 选择相册
                                ImagePickers.pickerPaths(
                                        galleryMode: GalleryMode.video,
                                        selectCount: 1)
                                    .then((value) {
                                  if (value.isNotEmpty) {
                                    var video = value[0];
                                    if (video.path != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TransResultPage(
                                              mediaPath: video.path!,
                                              mediaType: 'video'),
                                        ),
                                      );
                                    }
                                  }
                                });
                              } else if (res == 1) {
                                // 相机拍摄
                                ImagePickers.openCamera(
                                  cameraMimeType: CameraMimeType.video,
                                  videoRecordMaxSecond: 15,
                                ).then((value) {
                                  if (value != null) {
                                    if (value.path != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TransResultPage(
                                              mediaPath: value.path!,
                                              mediaType: 'video'),
                                        ),
                                      );
                                    }
                                  }
                                });
                              }
                            },
                          ),
                          GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(img_image_trans,
                                    width: 42,
                                    height: 50,
                                    fit: BoxFit.fitWidth),
                                const SizedBox(height: 5),
                                Text(
                                  '手语图片',
                                  style: TextStyle(fontSize: fontSize),
                                )
                              ],
                            ),
                            onTap: () async {
                              var res = await await _showCustomModalBottomSheet(
                                  context, null);

                              if (res == 0) {
                                // 选择相册
                                ImagePickers.pickerPaths(
                                        galleryMode: GalleryMode.image,
                                        selectCount: 1,
                                        showGif: false,
                                        showCamera: true)
                                    .then((value) {
                                  if (value.isNotEmpty) {
                                    var image = value[0];
                                    if (image.path != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TransResultPage(
                                              mediaPath: image.path!,
                                              mediaType: 'image'),
                                        ),
                                      );
                                    }
                                  }
                                });
                              } else if (res == 1) {
                                // 相机拍摄
                                ImagePickers.openCamera(
                                  cameraMimeType: CameraMimeType.photo,
                                ).then((value) {
                                  if (value != null) {
                                    if (value.path != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TransResultPage(
                                              mediaPath: value.path!,
                                              mediaType: 'image'),
                                        ),
                                      );
                                    }
                                  }
                                });
                              }
                            },
                          ),
                          GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(img_bothway_talk,
                                    width: 40,
                                    height: 50,
                                    fit: BoxFit.fitWidth),
                                const SizedBox(height: 5),
                                Text(
                                  '双向对话',
                                  style: TextStyle(fontSize: fontSize),
                                )
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const VoiceText()),
                              );
                              debugPrint("点击双向对话");
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
          // 使用说明
          Expanded(
              child: Stepper(
                  controlsBuilder: (a, b) {
                    return const SizedBox(width: 0);
                  },
                  currentStep: _currentStep,
                  onStepTapped: (index) => setState(() {
                        _currentStep = index;
                      }),
                  steps: List.generate(4, (index) => _buildUsage(index)))),
        ],
      ),
    );
  }

  final List<Map<String, String>> _usageContent = [
    {
      'title': '实时手语',
      'description':
          '手持相机对准手语手势，实现实时手语翻译，支持手部检测，摄像头切换',
      'image': 'assets/images/trans_camera_desc.png'
    },
    {
      'title': '视频翻译',
      'description': '上传已有或录制手语手势动作视频，完成手语翻译',
      'image': 'assets/images/trans_video_desc.png'
    },
    {
      'title': '图片翻译',
      'description': '上传已有或拍摄手势图片，实现静态手势翻译',
      'image': 'assets/images/trans_image_desc.png'
    },
    {
      'title': '双向对话',
      'description': '手语，文字，语音自由转换，为聋哑人士提供更编辑的交流渠道',
      'image': 'assets/images/trans_both_desc.png'
    },
  ];

  Step _buildUsage(int index) {
    var usage = _usageContent[index];
    double fontSize = Provider.of<AppProvider>(context).normalFontSize - 5;
    return Step(
      state: StepState.editing,
      isActive: _currentStep == index,
      title: Text(usage['title']!, style: TextStyle(fontSize: fontSize + 1)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(usage['description']!, style: TextStyle(fontSize: fontSize)),
          const SizedBox(height: 10),
          Image.asset(
            usage['image']!,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }

  Future<Future<int?>> _showCustomModalBottomSheet(
      context, List<String>? options) async {
    return showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: 180,
          child: Column(children: [
            SizedBox(
              height: 50,
              child: Stack(
                textDirection: TextDirection.rtl,
                children: [
                  const Center(
                    child: Text(
                      '选择来源',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // return;
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: Row(
                children: [
                  GestureDetector(
                    child: Column(children: [
                      Image.asset(img_selection_gallery,
                          width: 60, height: 60, fit: BoxFit.cover),
                      const Text('相册')
                    ]),
                    onTap: () {
                      Navigator.of(context).pop(0);
                    },
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                      child: Column(children: [
                        Image.asset(img_selection_camera,
                            width: 60, height: 60, fit: BoxFit.cover),
                        const Text('相机')
                      ]),
                      onTap: () => Navigator.of(context).pop(1)),
                ],
              ),
            )),
          ]),
        );
      },
    );
  }
}
