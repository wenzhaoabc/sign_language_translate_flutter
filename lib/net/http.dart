import 'package:dio/dio.dart';
import 'package:sign_language/res/constant.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: Constant.baseURL,
    connectTimeout: Duration(milliseconds: 5000),
  ),
);
