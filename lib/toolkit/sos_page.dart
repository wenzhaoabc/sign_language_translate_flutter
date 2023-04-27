import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/toolkit/add_sos_page.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';
import 'package:sign_language/res/constant.dart';

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
            centerTitle: true,
            title: const Text('紧急呼救'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.autorenew_rounded,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    const Text(
                      '重复播报',
                      style: TextStyle(fontSize: 25),
                    ),
                    const Expanded(child: SizedBox()),
                    NeumorphicSwitch(
                      height: 25,
                      value: _repeat,
                      onChanged: (bool value) {
                        _repeat = value;
                        setValue(Constant.sosRepeat, _repeat);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.speaker_phone_outlined,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    const Text(
                      '语音外放',
                      style: TextStyle(fontSize: 25),
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
                ),
              ],
            ),
          ),
          floatingActionButton: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MySlidePageRoute(page: const AddSOS()));
            },
            icon: const Icon(
              Icons.add_circle_outlined,
              size: 50,
              color: Colors.blue,
              // weight: 100,
            ),
          ),
          backgroundColor: Colors.transparent,
        ));
  }
}
