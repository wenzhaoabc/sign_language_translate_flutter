// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nb_net/flutter_net.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/home/home_page.dart';

import 'package:sign_language/setting/provider/ThemeProvider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/toolkit/chat/provider/auth_interceptor.dart';
import 'package:sign_language/toolkit/chat/provider/constants.dart';

import 'net/http.dart';
import 'toolkit/chat/chat_bindings.dart';
import 'toolkit/chat/chat_page.dart';

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

  NetOptions.instance
      .setBaseUrl(baseUrl)
      .addHeaders({
        // 'Authorization': 'Bearer aiApiKey',
        "Content-Type": "application/json"
      })
      .addInterceptor(AuthInterceptor())
      .setConnectTimeout(const Duration(milliseconds: 20000))
      .create();
  await GetStorage.init();
  GetStorage().write(StoreKey.API, aiApiKey);

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
    // EasyLoading.init();
    return GetMaterialApp(
      title: '手语翻译',
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      theme: theme ?? themeProvider.getTheme(),
      darkTheme: themeProvider.getTheme(isDarkMode: true),
      // home: home ?? const Home(),
      navigatorKey: navigatorKey,
      initialRoute: '/main',
      getPages: [
        GetPage(
          name: '/main',
          page: () => const Home(),
          // binding: ImageBinding(),
        ),
        GetPage(
          name: '/chat',
          page: () => ChatPage(),
          binding: ChatBinding(),
        ),
      ],
      builder: EasyLoading.init()/*(BuildContext context, Widget? child) {
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
      }*/,
      // restorationScopeId: 'app',
    );
  }
}
