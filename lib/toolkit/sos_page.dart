import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/res/styles.dart';
import 'package:sign_language/toolkit/add_sms_page.dart';
import 'package:sign_language/toolkit/add_sos_page.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({Key? key}) : super(key: key);

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool _repeat = true;
  bool _voicer = true;

  @override
  void initState() {
    _voicer = getBoolAsync(Constant.sosVoicer);
    _repeat = getBoolAsync(Constant.sosRepeat);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = Provider.of<AppProvider>(context).normalFontSize;

    return Container(
        decoration: PageBgStyles.BeHappyBimgDecoration,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('紧急呼救'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: InkWell(
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          body: Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                /*Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.autorenew_rounded,
                        color: Colors.green,
                        size: fontSize,
                      ),
                    ),
                    Text(
                      '重复播报',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    const Expanded(child: SizedBox()),
                    NeumorphicSwitch(
                      height: 25,
                      value: _repeat,
                      onChanged: (bool value) {
                        _repeat = value;
                        Provider.of<AppProvider>(context, listen: false)
                            .setPhoneIsRepeat(value);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.woman_outlined,
                        color: Colors.green,
                        size: fontSize,
                      ),
                    ),
                    Text(
                      '女性音色',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    const Expanded(child: SizedBox()),
                    NeumorphicSwitch(
                      height: 25,
                      value: _voicer,
                      onChanged: (bool value) {
                        _voicer = value;
                        setValue(Constant.sosVoicer, _voicer);
                        setState(() {});
                      },
                    ),
                  ],
                ),*/
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.phonelink_ring_rounded,
                        color: Colors.green,
                        size: fontSize,
                      ),
                    ),
                    Text(
                      '险情感知',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    const Expanded(child: SizedBox()),
                    NeumorphicSwitch(
                      height: 25,
                      value: Provider.of<AppProvider>(context, listen: false)
                          .detectSensor,
                      onChanged: (bool value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .setDetectSensor(value);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Divider(height: 10),
                GestureDetector(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.sms_failed,
                          color: Colors.green,
                          size: fontSize,
                        ),
                      ),
                      Text(
                        '添加求救短信',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      const Expanded(child: SizedBox()),
                      Icon(Icons.add_circle_outline, size: fontSize + 5),
                      SizedBox(width: 10)
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MySlidePageRoute(page: const AddSMSPage()));
                  },
                ),
                Divider(height: 10),
                GestureDetector(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.phonelink_ring_rounded,
                          color: Colors.green,
                          size: fontSize,
                        ),
                      ),
                      Text(
                        '添加紧急呼救',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      const Expanded(child: SizedBox()),
                      Icon(Icons.phone, size: fontSize + 5),
                      SizedBox(width: 10)
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MySlidePageRoute(page: const AddSOS()));
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: 30, right: 30),
            child: IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MySlidePageRoute(page: const AddSOS()));
              },
              icon: const Icon(
                Icons.add_circle_outlined,
                size: 60,
                color: Colors.blue,
                // weight: 100,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
        ));
  }
}
