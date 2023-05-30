import 'package:flutter/material.dart';

// 页面切换动画
class MySlidePageRoute extends PageRouteBuilder {
  final Widget page;

  MySlidePageRoute({required this.page})
      : super(
          // 设置过渡时间为 500 毫秒
          transitionDuration: const Duration(milliseconds: 200),
          // 构造页面过渡动画
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          // 构造路由过渡动画
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            // 设置左右滑动过渡
            position:
                Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        );
}

class MyBottomSlidePageRoute extends PageRouteBuilder {
  final Widget page;

  MyBottomSlidePageRoute({required this.page})
      : super(
          // 设置过渡时间为 500 毫秒
          transitionDuration: const Duration(milliseconds: 200),
          // 构造页面过渡动画
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          // 构造路由过渡动画
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            // 设置左右滑动过渡
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
