import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sign_language/toolkit/add_sos_page.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({Key? key}) : super(key: key);

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool _repeat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('紧急呼救'),
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
                    Icons.repeat,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const Text(
                  '重复播报',
                  style: TextStyle(fontSize: 20),
                ),
                const Expanded(child: SizedBox()),
                NeumorphicSwitch(
                  height: 20,
                  value: _repeat,
                  onChanged: (bool value) {
                    _repeat = value;
                    if (_repeat) {}
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
                    size: 20,
                  ),
                ),
                const Text(
                  '语音外放',
                  style: TextStyle(fontSize: 20),
                ),
                const Expanded(child: SizedBox()),
                NeumorphicSwitch(
                  height: 20,
                  value: _repeat,
                  onChanged: (bool value) {
                    _repeat = value;
                    if (_repeat) {}
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
          Navigator.of(context).push(MySlidePageRoute(page: const AddSOS()));
        },
        icon: const Icon(
          Icons.add_circle_outlined,
          size: 40,
          color: Colors.blue,
        ),
      ),
    );
  }
}
