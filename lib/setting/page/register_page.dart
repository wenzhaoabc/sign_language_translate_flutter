import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/trans/TransPage.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';
import 'package:sign_language/utils/ToastUtil.dart';
import 'package:sign_language/res/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const img_selection_gallery = 'assets/images/trans_gallery.png';
  static const img_selection_camera = 'assets/images/trans_camera_green.png';
  String _avatarPath = '';

  Uint8List? imageBytes;
  String? username;
  String? phone;
  String? password;
  final ImagePicker picker = ImagePicker();

  void handleUsername(String name) {
    if (!name.isEmptyOrNull) {
      username = name;
    }
  }

  void handlePhone(String phone) {
    this.phone = phone;
  }

  void handlePassword(String pwd) {
    password = pwd;
  }

  void _register(BuildContext context) async {
    if (username.isEmptyOrNull ||
        phone.isEmptyOrNull ||
        password.isEmptyOrNull) {
      MyToast.showToast(msg: '输入信息无效', type: 'warning');
      return;
    }
    if (!phone.validatePhone()) {
      MyToast.showToast(msg: '手机号不正确', type: 'error');
    }
    if (_avatarPath.length < 1) {
      MyToast.showToast(msg: '请选择头像', type: 'warning');
    }

    Map<String, dynamic> data = Map();
    data['avatar'] = await MultipartFile.fromFile(_avatarPath);
    data['phone'] = phone;
    data['password'] = password;
    data['username'] = username;
    FormData formData = FormData.fromMap(data);
    dio.post('/register-form', data: formData).then((value) {
      var res = ResponseBase<User>.fromJson(value.data);
      if (res.code == 200) {
        setValue(Constant.user, res.data.toString());
        User u = res.data!;
        MyToast.showToast(msg: '注册成功', type: 'success');
        Provider.of<AppProvider>(context, listen: false).setUser(u);
        _backLastPage();
      } else {
        MyToast.showToast(msg: (res.msg) ?? '注册失败');
      }
    }) /*.catchError((res) => Future.microtask(() => debugPrint(res.toString())))*/;
  }

  void _backLastPage() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // var bgColor = inDark() ? Colours.dark_app_main : Colours.app_main;

    var deviceWidth = MediaQuery.of(context).size.width;

    return Container(
        decoration: PageBgStyles.DeepWheelBimgDecoration,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // backgroundColor: bgColor,
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 注册字样
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40, left: 20),
                    child: const Text(
                      'Register',
                      style:
                          TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 4,
                    color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20, top: 10),
                  )
                ],
              ),
              Expanded(
                child: SizedBox(
                  width: deviceWidth > 500 ? 500 : deviceWidth,
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      color: Colours.d_bg,
                    ),
                    margin: const EdgeInsets.only(
                        left: 40, right: 40, top: 40, bottom: 80),
                    padding:
                        const EdgeInsets.only(top: 30, left: 30, right: 30),
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          _getAvatarCircle(),
                          const SizedBox(height: 20),
                          _getTagInput('昵称', '请输入昵称', handleUsername),
                          const SizedBox(height: 25),
                          _getTagInput('手机号', '请输入手机号', handlePhone),
                          const SizedBox(height: 25),
                          _getTagInput('密码', '请输入密码', handlePassword),
                          const SizedBox(height: 25),
                          _getRegisterBtn()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _getAvatarCircle() {
    return InkWell(
      child: Neumorphic(
        style: const NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
          depth: 2,
        ),
        child: SizedBox(
          width: 150,
          height: 150,
          child: (_avatarPath.isEmpty)
              ? const Icon(Icons.tag_faces_sharp, color: Colors.grey, size: 130)
              // ? const Icon(Icons.tag_faces_sharp, color: Colours.most_bg, size: 130)
              : Image.file(File(_avatarPath), fit: BoxFit.cover),
        ),
      ),
      // showModalBottomSheet(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return _buildBottomSheetWidget(context);
      //   },
      // );
      onTap: () async {
        var res = await await _showCustomModalBottomSheet(context, null);
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
                // TODO
                setState(() {
                  _avatarPath = image.path!;
                });
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
                // TODO
                setState(() {
                  _avatarPath = value.path!;
                });
              }
            }
          });
        }
      },
    );
  }

  Widget _getTagInput(String tag, String hintText, Function(String) function) {
    var textColor = Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag, style: TextStyle(color: textColor, fontSize: 16)),
        TextField(
          onChanged: function,
          style: const TextStyle(fontSize: 16),
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            hintText: hintText,
          ),
        )
      ],
    );
  }

  Widget _getRegisterBtn() {
    return SizedBox(
      width: double.infinity,
      child: NeumorphicButton(
        style: const NeumorphicStyle(depth: 3, intensity: 0.8),
        pressed: true,
        onPressed: () => _register(context),
        child: const Text(
          '注册',
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomSheetWidget(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          _buildItem(
              '相机',
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.grey,
              ), function: () async {
            var status = await Permission.camera.request();
            debugPrint("permission camera is requesting...");
            if (status == PermissionStatus.granted) {
              debugPrint("permission camera is granted");
              final img = await picker.pickImage(source: ImageSource.camera);
              if (img != null) {
                setState(() async {
                  imageBytes = await img.readAsBytes();
                });
              }
            }
          }),
          const Divider(),
          _buildItem(
              '相册',
              const Icon(
                Icons.camera,
                color: Colors.green,
              ), function: () async {
            // var status = await Permission.storage.request();
            var status = await Permission.photos.shouldShowRequestRationale;
            debugPrint("storage permission is requesting...");
            debugPrint("photos permission status = ${status.toString()}");
            if (status == true) {
              debugPrint("storage permission is granted");
              final img = await picker.pickImage(source: ImageSource.gallery);
              if (img != null) {
                setState(() async {
                  imageBytes = await img.readAsBytes();
                });
              }
            }
          }),
          Container(
            color: Colors.grey[300],
            height: 8,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: const Text('取消'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(String title, Icon icon, {required Function function}) {
    //添加点击事件
    return InkWell(
      //点击回调
      onTap: () async {
        //关闭弹框
        Navigator.of(context).pop();
        //外部回调
        await function();
      },
      child: SizedBox(
        height: 50,
        //左右排开的线性布局
        child: Row(
          //所有的子Widget 水平方向居中
          mainAxisAlignment: MainAxisAlignment.center,
          //所有的子Widget 竖直方向居中
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [icon, const SizedBox(width: 10), Text(title)],
        ),
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
