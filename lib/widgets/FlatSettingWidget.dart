import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';

class FlatSettingItem extends StatelessWidget {
  const FlatSettingItem(
      {Key? key, required this.handleOnTap, required this.title})
      : super(key: key);

  final void Function() handleOnTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colours.app_main;
    double deviceWidth = MediaQuery.of(context).size.width;
    bool isInDark = Theme.of(context).primaryColor == Colours.app_main;
    Color testColor = isInDark ? Colors.black : Colors.white;
    Color iconColor = isInDark ? Colors.blueAccent : Colors.blueAccent;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      child: InkWell(
        onTap: handleOnTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: Provider.of<AppProvider>(context).textStyle),
            const Expanded(child: SizedBox()),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: iconColor,
            )
          ],
        ),
      ),
    );
  }
}
