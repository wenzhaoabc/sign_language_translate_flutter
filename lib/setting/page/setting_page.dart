import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/setting/page/LoginPage.dart';
import 'package:sign_language/setting/page/MyLoveWord.dart';
import 'package:sign_language/setting/page/PersonalInfo.dart';
import 'package:sign_language/setting/page/about_us.dart';
import 'package:sign_language/setting/page/register_page.dart';
import 'package:sign_language/setting/provider/ThemeProvider.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';
import 'package:sign_language/utils/ToastUtil.dart';
import 'package:sign_language/res/constant.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _blackMode = false;
  bool _superFontSize = false;
  User? _user;

  @override
  void initState() {
    // setState(() {});
    _getUserInfo();
    _superFontSize = _getFontSize();
    super.initState();
  }

  void _getUserInfo() {
    var userStr = getStringAsync(Constant.user, defaultValue: '');
    if (userStr.runtimeType == " ".runtimeType && userStr.isNotEmpty) {
      _user = User.fromJson(jsonDecode(userStr));
      setState(() {});
    }
  }

  bool _getFontSize() {
    var res = getBoolAsync(Constant.largeFont);
    return res;
  }

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  @override
  Widget build(BuildContext context) {
    // TextTheme textTheme = context.textTheme;
    // debugPrint("textTheme : fontSize : ${textTheme.bodyMedium?.fontSize.size}");
    final fontModel = Provider.of<AppProvider>(context);
    var textStyle = fontModel.textStyle;
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
          // backgroundColor:
          //     isInDark() ? Colours.dark_app_main : Colours.app_main,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text('设置'),
            centerTitle: true,
            // backgroundColor:
            //     isInDark() ? Colours.dark_app_main : Colours.app_main,
            actions: [
              Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 3,
                  lightSource: LightSource.topLeft,
                  intensity: 0.75,
                  surfaceIntensity: 0.1,
                  color: isInDark() ? Colours.dark_app_main : Colours.app_main,
                ),
                margin: const EdgeInsets.only(
                    left: 5, top: 5, bottom: 5, right: 30),
                child: IconButton(
                  iconSize: 30,
                  color: Colors.transparent,
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    if (_user != null) {
                      Navigator.of(context)
                          .push(MySlidePageRoute(page: const PersonalInfo()));
                    } else {
                      MyToast.showToast(msg: '请先登录');
                    }
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Neumorphic(
                style: const NeumorphicStyle(
                  color: Colours.d_bg,
                ),
                margin: const EdgeInsets.all(30),
                child: _generateHeadUser(textStyle: textStyle),
              ),
              Neumorphic(
                style: const NeumorphicStyle(
                  color: Colours.d_bg,
                ),
                margin: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                        ),
                        Text(
                          '我的收藏',
                          style: textStyle,
                        ),
                        const Expanded(child: SizedBox()),
                        NeumorphicButton(
                          style: const NeumorphicStyle(
                              // color:Colors.blueAccent,
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 2,
                              intensity: 0.8),
                          pressed: true,
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            var userStr = getStringAsync(Constant.user);
                            if (userStr.isEmptyOrNull) {
                              MyToast.showToast(msg: '请先登录');
                            } else {
                              Navigator.of(context).push(
                                  MySlidePageRoute(page: const MyLoveWord()));
                            }
                          },
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.all(10),
                    //       child: const Icon(
                    //         Icons.upload_file_outlined,
                    //         color: Colors.blueAccent,
                    //         size: 30,
                    //       ),
                    //     ),
                    //     Container(
                    //       child: const Text(
                    //         '我的录制',
                    //         style: TextStyle(fontSize: 20),
                    //       ),
                    //     ),
                    //     const Expanded(child: SizedBox()),
                    //     NeumorphicButton(
                    //       style: const NeumorphicStyle(
                    //           boxShape: NeumorphicBoxShape.circle(),
                    //           depth: 2,
                    //           intensity: 0.8),
                    //       pressed: true,
                    //       child: const Icon(Icons.arrow_forward,
                    //           color: Colors.blueAccent),
                    //       onPressed: () {
                    //         var userStr = getStringAsync(Constant.user);
                    //         if (userStr.isEmptyOrNull) {
                    //           MyToast.showToast(msg: '请先登录');
                    //         } else {
                    //           Navigator.of(context).push(
                    //               MySlidePageRoute(page: const MyLoveWord()));
                    //         }
                    //       },
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              Neumorphic(
                style: const NeumorphicStyle(
                  color: Colours.d_bg,
                ),
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Row(
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.all(10),
                    //       child: const Icon(
                    //         Icons.sunny,
                    //         color: Colors.black,
                    //         size: 30,
                    //       ),
                    //     ),
                    //     const Text(
                    //       '深色模式',
                    //       style: TextStyle(fontSize: 20),
                    //     ),
                    //     const Expanded(child: SizedBox()),
                    //     NeumorphicSwitch(
                    //       height: 30,
                    //       value: _blackMode,
                    //       onChanged: (bool value) {
                    //         _blackMode = value;
                    //         if (_blackMode) {
                    //           const ThemeMode themeMode = ThemeMode.dark;
                    //           Provider.of<ThemeProvider>(context, listen: false)
                    //               .setTheme(themeMode);
                    //         }
                    //         setState(() {});
                    //       },
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.text_rotate_up,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        Text(
                          '超大字体',
                          // style: TextStyle(fontSize: 20),
                          style: fontModel.textStyle,
                        ),
                        const Expanded(child: SizedBox()),
                        NeumorphicSwitch(
                          height: 30,
                          value: _superFontSize,
                          onChanged: (bool value) {
                            setValue(Constant.largeFont, value);
                            // print(value);
                            _superFontSize = value;
                            fontModel.setFontLarge(value);
                            //context.read<ThemeProvider>().setTheme(themeMode);
                            // Provider.of<ThemeProvider>(context,listen: false).setFontSize(value);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Neumorphic(
                style: const NeumorphicStyle(
                  color: Colours.d_bg,
                ),
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.mail_outline,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                        ),
                         Text(
                          '联系我们',
                          style: textStyle,
                        ),
                        const Expanded(child: SizedBox()),
                        NeumorphicButton(
                          style: const NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 2,
                              intensity: 0.8),
                          pressed: true,
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const ContactUs()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        ));
  }

  Widget _generateHeadUser(
      {TextStyle textStyle = const TextStyle(fontSize: 20)}) {
    if (_user != null) {
      return GestureDetector(
        onTap: () {
          debugPrint('个人中心页面');
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              return const PersonalInfo();
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
          ));
        },
        child: Row(
          children: [
            Neumorphic(
              margin: const EdgeInsets.all(10),
              style: NeumorphicStyle(
                boxShape: const NeumorphicBoxShape.circle(),
                depth: -2,
                intensity: 0.75,
                color: isInDark() ? Colours.dark_app_main : Colours.app_main,
              ),
              child: SizedBox.fromSize(
                size: const Size(50, 50),
                child: CircleAvatar(
                  backgroundImage: NetworkImage((_user?.avatar) ??
                      'https://s2.loli.net/2022/11/05/8j6akmQ9xViINKG.jpg'),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  (_user?.username) ?? '登录/注册',
                  style: textStyle,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // const textStyle = TextStyle(
      //     color: Colors.black,
      //     fontSize: 20,
      //     decoration: TextDecoration.underline);

      return Row(
        children: [
          Neumorphic(
            margin: const EdgeInsets.all(10),
            style: const NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: -2,
                intensity: 0.75),
            child: SizedBox.fromSize(
              size: const Size(50, 50),
              child: const CircleAvatar(
                child: Icon(
                  Icons.perm_identity_outlined,
                  size: 30,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                debugPrint('去登陆');
                Navigator.of(context).push(PageRouteBuilder(
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return const LoginPage();
                  },
                ));
              },
              child: Text('登录', style: textStyle),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: const Text(
              '/',
              style: TextStyles.userName,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MySlidePageRoute(page: const RegisterPage()));
              },
              child: InkWell(
                child: Text('注册', style: textStyle),
                onTap: () {
                  Navigator.push(
                      context, MySlidePageRoute(page: const RegisterPage()));
                },
              ),
            ),
          ),
        ],
      );
    }
  }
}
