import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';

// extension ThemeModeExtension on ThemeMode {
//   String get value => <String>['system', 'light', 'dark'][index];
// }

class ThemeProvider {
  bool _largeFont = false;

  // void syncTheme() {
  //   final String theme = getStringAsync(Constant.theme) ?? '';
  //   if (theme.isNotEmpty && theme != ThemeMode.system.value) {
  //     notifyListeners();
  //   }
  // }
  //
  // void setTheme(ThemeMode themeMode) {
  //   setValue(Constant.theme, themeMode.value);
  //   notifyListeners();
  // }
  //
  // void setFontSize(bool largeFont) {
  //   setValue(Constant.largeFont, largeFont);
  //   _largeFont = largeFont;
  //   debugPrint("_largeFont = $_largeFont");
  //   notifyListeners();
  // }

  ThemeMode getThemeMode() {
    final String theme = getStringAsync(Constant.theme) ?? '';
    switch (theme) {
      case Constant.dark:
        return ThemeMode.dark;
      case Constant.light:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static ThemeData getTheme({bool isDarkMode = false}) {
    debugPrint("getTheme : ---- ");
    return ThemeData(
      primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      // Tab指示器颜色
      indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkMode ? Colours.app_main : Colours.dark_app_main,
      ),
      // 页面背景色
      scaffoldBackgroundColor:
          isDarkMode ? Colours.dark_bg_color : Colours.app_main,
      // Material背景色
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      // 文字选择色
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colours.app_main.withAlpha(70),
        selectionHandleColor: Colours.app_main,
        cursorColor: Colours.app_main,
      ),
      // 文本颜色
      textTheme: TextTheme(
        headlineMedium: isDarkMode ? TextStyles.textDark : TextStyles.text,
        titleMedium: isDarkMode ? TextStyles.textDark : TextStyles.text,
        bodyMedium: isDarkMode ? TextStyles.textDark : TextStyles.text,
        titleSmall:
            isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
      ),
      // 文本大小
      // primaryTextTheme: TextTheme(
      //   headlineMedium: _largeFont ? TextStyles.largeText : TextStyles.text,
      //   titleMedium: _largeFont ? TextStyles.largeText : TextStyles.text,
      //   bodyMedium: _largeFont ? TextStyles.largeText : TextStyles.text,
      //   titleSmall: _largeFont ? TextStyles.largeText : TextStyles.text,
      // ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: isDarkMode ? Colours.dark_bg_color : Colours.app_main,
        titleTextStyle:
            isDarkMode ? TextStyles.dark_appBarTitle : TextStyles.appBarTitle,
        systemOverlayStyle:
            isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,
          space: 0.6,
          thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      visualDensity: VisualDensity.standard,
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            secondary: isDarkMode ? Colours.dark_app_main : Colours.app_main,
            error: isDarkMode ? Colours.dark_red : Colours.red,
          )
          .copyWith(background: Colours.app_main),
    );
  }
}
