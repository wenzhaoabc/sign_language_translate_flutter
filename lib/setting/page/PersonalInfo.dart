import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/utils/ToastUtil.dart';
import 'package:sign_language/res/constant.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({Key? key}) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  User? _user;

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  void _logOut() async {
    dio.post('/logout').then((value) {
      MyToast.showToast(msg: '已退出登录', type: 'success');
    });
    Provider.of<AppProvider>(context, listen: false).setUser(null);
    await clearSharedPref();
  }

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() {
    var userStr = getStringAsync(Constant.user);
    _user = User.fromJson(jsonDecode(userStr));
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).primaryColor;
    Color btnColor = isInDark() ? Colors.white : Colors.green;
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(Constant.bg_img_url),
            // image: AssetImage("images/R_C.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('我的'),
            centerTitle: true,
            // backgroundColor:
            //     isInDark() ? Colours.dark_app_main : Colours.app_main,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 80,
            leading: Neumorphic(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: const NeumorphicBoxShape.circle(),
                  depth: 3,
                  lightSource: LightSource.topLeft,
                  intensity: 0.75,
                  color: bgColor),
              margin:
                  const EdgeInsets.only(left: 30, top: 5, bottom: 5, right: 5),
              child: IconButton(
                iconSize: 25,
                // color: isInDark() ? Colors.green : btnColor,
                color: Colors.blueAccent,
                icon: const Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          body: SizedBox(
            width: 400,
            height: 600,
            child: Neumorphic(
                margin: const EdgeInsets.only(
                    top: 40, left: 20, right: 20, bottom: 40),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Neumorphic(
                      style: const NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 2,
                      ),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: (_user == null)
                            ? const Icon(Icons.tag_faces_sharp,
                                color: Colors.grey, size: 130)
                            : Image.network(_user!.avatar, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Text((_user?.username) ?? '用户名',
                    //     style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 40, right: 20, top: 20),
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.green, size: 30),
                              const SizedBox(width: 15),
                              Text((_user?.username) ?? '用户名',
                                  style: const TextStyle(fontSize: 20))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: Colors.green, size: 30),
                              const SizedBox(width: 15),
                              Text((_user?.phone) ?? 'xxxxxx',
                                  style: const TextStyle(fontSize: 20))
                            ],
                          ),
                          const SizedBox(height: 40),
                          _getLogoutBtn()
                        ],
                      ),
                    ),
                  ],
                )),
          ),
          backgroundColor: Colors.transparent,
        ));
  }

  Widget _getLogoutBtn() {
    return SizedBox(
      width: double.infinity,
      child: NeumorphicButton(
        style: const NeumorphicStyle(depth: 3, intensity: 0.8),
        pressed: true,
        onPressed: () {
          _logOut();
          Navigator.of(context).pop();
        },
        child: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 20,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
