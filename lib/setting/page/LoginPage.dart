import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/utils/HideKeybUtils.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // bool inDark() {
  //   return Theme.of(context).primaryColor == Colours.dark_app_main;
  // }

  void popToLast() {
    Navigator.pop(context);
  }

  String? _userName;
  String? _password;

  @override
  Widget build(BuildContext context) {
    // var mainColor = inDark() ? Colours.dark_app_main : Colours.app_main;
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(Constant.bg_img_url),
            // image: AssetImage("images/R_C.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // backgroundColor: mainColor,
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40, left: 20),
                    child: const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 4,
                    color: Colors.black,
                    margin: const EdgeInsets.only(left: 20, top: 10),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      color: Colours.d_bg,
                    ),
                    margin: const EdgeInsets.only(
                        left: 40, right: 40, top: 40, bottom: 80),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '用户名',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Neumorphic(
                          style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                              const BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            depth: -3,
                            intensity: 1,
                          ),
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          child: TextField(
                            // focusNode: focusNode1,
                            onChanged: (String txt) {
                              /// 输入用户名
                              setState(() {
                                _userName = txt;
                              });
                            },
                            // scrollPadding: EdgeInsets.only(left: 30),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 16),
                              border: InputBorder.none,
                              hintText: 'username...',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          '密码',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Neumorphic(
                          style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                              const BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            depth: -3,
                            intensity: 1,
                          ),
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          child: TextField(
                            obscureText: true,
                            onChanged: (String txt) {
                              /// 输入密码
                              setState(() {
                                _password = txt;
                              });
                            },
                            // scrollPadding: EdgeInsets.only(left: 30),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 16),
                              border: InputBorder.none,
                              hintText: 'password...',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: NeumorphicButton(
                                style: const NeumorphicStyle(
                                  depth: 3,
                                  intensity: 0.8,
                                ),
                                // padding: EdgeInsets.only(top: 5,bottom: 5),
                                pressed: true,
                                child: const Text(
                                  '登录',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blueAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  /// 登录

                                  // 验证手机号
                                  if (_password == null ||
                                      _userName == null ||
                                      _password!.isEmpty ||
                                      _userName!.isEmpty) {
                                    Fluttertoast.showToast(msg: '用户名，密码不可为空');
                                    return;
                                  }
                                  HideKeybUtils.hideKeyShowUnfocus();
                                  // 验证手机号
                                  RegExp exp = RegExp(r'^1[35678]\d{9}$');
                                  bool usernameMatched =
                                      exp.hasMatch(_userName ?? '');
                                  // 验证密码
                                  bool passwordMatched =
                                      _password!.length > 8 &&
                                          _password!.length < 16;

                                  debugPrint("usernameMatched ；$usernameMatched； passwordMatched : $passwordMatched ");
                                  if (usernameMatched && passwordMatched) {
                                    var postData = {
                                      'phone': _userName,
                                      'password': _password
                                    };
                                    var response = await dio.post('/login',
                                        data: postData);
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '登陆成功');
                                      ResponseBase<User> res =
                                          ResponseBase.fromJson(
                                              jsonDecode(response.toString()));
                                      if (res.data != null) {
                                        setValue(
                                            Constant.user, res.data.toString());
                                      }
                                      // 返回设置页面
                                      // Navigator.pop(context);
                                      popToLast();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: jsonDecode(
                                              response.data.toString())['msg']);
                                    }
                                  } else {
                                    MyToast.showToast(msg: "用户名或密码错误");
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          // backgroundColor: Colors.transparent,
        ));
  }
}
