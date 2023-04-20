import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/utils/PhoneStateUtils.dart';
import 'package:sign_language/utils/PhoneUtils.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class SOSListWidget extends StatefulWidget {
  const SOSListWidget({Key? key}) : super(key: key);

  @override
  State<SOSListWidget> createState() => _SOSListWidgetState();
}

class _SOSListWidgetState extends State<SOSListWidget> {
  List<SOSItem> sosList = [
    SOSItem(
        '家中失火报警',
        '消防救援中心您好，我是一名聋哑人士，该音频为提前录制，我家中厨房失火，火势过大无法控制，我家在花园路幸福小区1单元6栋9号，请速来救援',
        '18105022730'),
    SOSItem(
        '户外涉险',
        '消防救援中心您好，我是一名聋哑人士，该音频为提前录制，我家中厨房失火，火势过大无法控制，我家在花园路幸福小区1单元6栋9号，请速来救援',
        '18105022730'),
    SOSItem(
        '迷路报警',
        '消防救援中心您好，我是一名聋哑人士，该音频为提前录制，我家中厨房失火，火势过大无法控制，我家在花园路幸福小区1单元6栋9号，请速来救援',
        '18105022730'),
  ];

  final PhoneStateListener _phoneStateListener = PhoneStateListener();
  late FlutterTts flutterTts;
  bool isCalling = false;

  void handleDelete(int index) {
    showConfirmDialogCustom(context,
        title: "确定要删除《${sosList[index].title}》吗？",
        dialogType: DialogType.DELETE, onAccept: (BuildContext context) {
      sosList.removeAt(index);
      setState(() {});
    });
  }

  void handleEdit(int index) {
    // Navigator.of(context).push(MySlidePageRoute(page: page))
  }

  void makeSOSPhoneCall(String to, String content) async {
    var phonePermission = await Permission.phone.request();
    if (phonePermission == PermissionStatus.granted) {
      var res = await PhoneUtils.makePhoneCall(to, content);
      if (res) {
        debugPrint("flutter : 拨打成功");
      } else {
        debugPrint("flutter : 拨打失败");
      }
    } else {
      debugPrint("flutter : 权限申请失败");
    }
  }

  void makeSOSPhoneCallV1(String to, String content) async {
    var audioPer = await Permission.audio.request();
    await Permission.speech.request();
    if (true) {
      isCalling = true;
      var status = await Permission.phone.request();
      if (status == PermissionStatus.granted) {
        var res = await PhoneUtils.makePhoneCall(to, content);
        if (res) {
          debugPrint("拨打成功");
          if (!isCalling) {
            return;
          }
          _phoneStateListener.phoneStateStream.listen((dynamic state) async {
            debugPrint("Phone State : $state");
            if (state == "offhook" || state == "connected") {
              debugPrint("通话建立");
              await initTTS(content);
            }
            if (state == "disconnected") {
              debugPrint("通话已挂断停止");
              await flutterTts.stop();
            }
          }).onDone(() {
            flutterTts.stop();
          });
        } else {
          debugPrint("发生异常");
        }
      }
    } else {
      MyToast.showToast(msg: '音频权限申请失败');
    }
  }

  Future<void> initTTS(String content) async {
    flutterTts = FlutterTts();
    await flutterTts.awaitSpeakCompletion(true);
    flutterTts.setSpeechRate(1.2); // 设置语速
    flutterTts.setPitch(1.0); // 设置音调
    flutterTts.setVolume(0.2); // 设置音量
    flutterTts.setLanguage("zh-CN");
    flutterTts.setCompletionHandler(() {
      play(content);
    });
    flutterTts.speak(content);
  }

  void play(String content) async {
    await flutterTts.speak(content);
  }


  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 400,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            sosList.length,
            (index) => _getSOSItem(sosList[index % 3], index),
          ),
        ),
      ),
    );
  }

  Widget _getSOSItem(SOSItem sosItem, int index) {
    bool isInDark = Theme.of(context).primaryColor == Colours.app_main;
    Color textColor = isInDark ? Colors.black : Colors.white;
    return Slidable(
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        // dragDismissible: false,

        // All actions are defined in the children parameter.
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              handleDelete(index);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              handleEdit(index);
            },
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.home,
            label: '添加到桌面快捷方式',
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10, right: 10),
        title: Text(
          sosItem.title,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
        subtitle: Text('tel : ${sosItem.to}'),
        trailing: InkWell(
          onTap: () {
            makeSOSPhoneCall(sosItem.to, sosItem.content);
          },
          child: const Icon(
            Icons.call_outlined,
            size: 20,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
