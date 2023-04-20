import 'dart:io';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/home/home_page.dart';

import 'package:sign_language/setting/provider/ThemeProvider.dart';
import 'package:nb_utils/nb_utils.dart';

import 'net/http.dart';

Future<void> main() async {
  /// 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  /// 临时缓存
  await initialize();
  await clearSharedPref();

  /// 平滑滚动效果
  GestureBinding.instance.resamplingEnabled = true;

  // 注册平台通道
  if (Platform.isAndroid) {}

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key, this.home, this.theme}) {
    initDio();
  }

  final Widget? home;
  final ThemeData? theme;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  void initDio() {
    /// 初始化网络请求配置
    // cookie管理
    dio.interceptors.add(CookieManager(CookieJar()));
  }

  @override
  Widget build(BuildContext context) {
    final Widget app = ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer(builder: (_, ThemeProvider theme, __) {
        return _buildMaterialApp(theme);
      }),
    );
    return app;
  }

  Widget _buildMaterialApp(ThemeProvider themeProvider) {
    return MaterialApp(
      title: '手语翻译',
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      theme: theme ?? themeProvider.getTheme(),
      darkTheme: themeProvider.getTheme(isDarkMode: true),
      home: home ?? const Home(),
      navigatorKey: navigatorKey,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus!.unfocus();
              }
            },
            child: child,
          ),
        );
      },
      restorationScopeId: 'app',
    );
  }
}
