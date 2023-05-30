import 'package:flutter/material.dart';
import 'package:sign_language/res/constant.dart';

import 'colours.dart';
import 'dimens.dart';

class TextStyles {
  static const TextStyle textSize12 = TextStyle(
    fontSize: Dimens.font_sp12,
  );
  static const TextStyle textSize16 = TextStyle(
    fontSize: Dimens.font_sp16,
  );
  static const TextStyle textBold14 =
      TextStyle(fontSize: Dimens.font_sp14, fontWeight: FontWeight.bold);
  static const TextStyle textBold16 =
      TextStyle(fontSize: Dimens.font_sp16, fontWeight: FontWeight.bold);
  static const TextStyle textBold18 =
      TextStyle(fontSize: Dimens.font_sp18, fontWeight: FontWeight.bold);
  static const TextStyle textBold24 =
      TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold);
  static const TextStyle textBold26 =
      TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold);

  static const TextStyle textGray14 = TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colours.text_gray,
  );
  static const TextStyle textDarkGray14 = TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colours.dark_text_gray,
  );

  static const TextStyle textWhite14 = TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colors.white,
  );

  static const TextStyle text = TextStyle(
      fontSize: Dimens.font_sp14,
      color: Colours.text,
      // https://github.com/flutter/flutter/issues/40248
      textBaseline: TextBaseline.alphabetic);

  static const TextStyle largeText = TextStyle(
      fontSize: 20, color: Colours.text, textBaseline: TextBaseline.alphabetic);
  static const TextStyle textDark = TextStyle(
      fontSize: Dimens.font_sp14,
      color: Colours.dark_text,
      textBaseline: TextBaseline.alphabetic);

  static const TextStyle textGray12 = TextStyle(
      fontSize: Dimens.font_sp12,
      color: Colours.text_gray,
      fontWeight: FontWeight.normal);
  static const TextStyle textDarkGray12 = TextStyle(
      fontSize: Dimens.font_sp12,
      color: Colours.dark_text_gray,
      fontWeight: FontWeight.normal);

  static const TextStyle textHint14 = TextStyle(
      fontSize: Dimens.font_sp14, color: Colours.dark_unselected_item_color);

  static const TextStyle userName = TextStyle(
    color: Colors.blueAccent,
    fontSize: 20,
  );

  static const TextStyle appBarTitle =
      TextStyle(fontSize: 20, color: Colours.text);
  static const TextStyle dark_appBarTitle =
      TextStyle(fontSize: 20, color: Colours.dark_text);


}

class PageBgStyles{
  // 页面背景
  static const PageBimgDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage(Constant.bg_img_assets),
      fit: BoxFit.cover,
      opacity: 0.3,
    ),
  );

  static const PageBallonDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/bg_img_ballot_up_down.png'),
      fit: BoxFit.cover,
      opacity: 0.3,
    ),
  );

  static const BeHappyBimgDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/news_list_bg.jpg'),
      fit: BoxFit.cover,
      opacity: 0.2,
    ),
  );

  // 鲸鱼背景图
  static const DeepWheelBimgDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/bg_deep_wheel.jpg'),
      fit: BoxFit.cover,
      opacity: 0.5,
    ),
  );
}
