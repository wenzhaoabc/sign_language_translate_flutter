import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/toolkit/xfyy/utils/xf_socket.dart';
import 'package:sign_language/utils/PhoneStateUtils.dart';
import 'package:sign_language/utils/PhoneUtils.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class SOSListWidget extends StatefulWidget {
  const SOSListWidget({Key? key}) : super(key: key);

  @override
  State<SOSListWidget> createState() => _SOSListWidgetState();
}

class _SOSListWidgetState extends State<SOSListWidget> {
  List<SOSItem> SosItemList = [];

  void handleDelete(int index) async {
    showConfirmDialogCustom(context,
        title: "确定要删除《${SosItemList[index].title}》吗？",
        dialogType: DialogType.DELETE, onAccept: (BuildContext context) {
      Provider.of<AppProvider>(context, listen: false)
          .deleteSosItem(SosItemList[index].title);
    });
  }

  // 初始化紧急呼救数据列表
  void initSosList() {
    SosItemList = Provider.of<AppProvider>(context, listen: false).sosItemList;
    return;
  }

  void handleEdit(int index) {
    // var sosItem = SosItemList.elementAt(index);
    // var res = await PhoneUtils.createShortCut(
    //     sosItem.title, sosItem.to, sosItem.content);
    // var res = false;
    // if (res == true) {
    //   MyToast.showToast(msg: '创建成功');
    // } else {
    //   MyToast.showToast(msg: '创建失败');
    // }
    setValue(Constant.sosPhone, SosItemList[index].to);
    setValue(Constant.sosContent, SosItemList[index].content);
  }

  final FlutterSoundPlayer playerModule = FlutterSoundPlayer();

  initPlay() async {
    await playerModule.closePlayer();
    await playerModule.openPlayer();
    await playerModule
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  void makeSOSPhoneCall(String title, String to, String content) async {
    var phonePermission = await Permission.phone.request();
    var storagePermission = await Permission.storage.request();
    // await Permission.audio.request();
    if (phonePermission == PermissionStatus.granted &&
        storagePermission == PermissionStatus.granted) {
      // var res = await PhoneUtils.makePhoneCall(title, to, content);
      PhoneUtils.makePhoneCallWhileAudio(to, content);
      // if (res) {
      //   debugPrint("flutter : 拨打成功");
      // } else {
      //   debugPrint("flutter : 拨打失败");
      // }
    } else {
      debugPrint("flutter : 权限申请失败");
    }
  }

  void _play(String path) async {
    await playerModule.startPlayer(fromURI: path);
  }

  void makeSOSPhoneCall2(String title, String to, String content) async {
    initPlay();
    var repeat = Provider.of<AppProvider>(context, listen: false).phoneIsRepeat;
    if (repeat) {
      content = "$context。$context。$context。";
    }
    var phonePermission = await Permission.phone.request();
    if (phonePermission == PermissionStatus.granted) {
      XfSocket.connect(content, onFilePath: (path) {
        PhoneUtils.makePhoneCall2(to).then((value) {
          debugPrint("res = $value");
          PhoneState.phoneStateStream.listen((event) {
            debugPrint("event = $event");
            switch (event) {
              // case PhoneStateStatus.
              // _play(path);
              case PhoneStateStatus.CALL_STARTED:
                {
                  _play(path);
                  break;
                }
              case PhoneStateStatus.CALL_ENDED:
                {
                  playerModule.stopPlayer();
                  break;
                }
              default:
                break;
            }
          });
        });
        // _play(path);
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   initSosList();
  // }

  @override
  Widget build(BuildContext context) {
    initSosList();
    return Container(
      // margin: const EdgeInsets.only(bottom: 20),
      height: 300,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: SosItemList.length,
        itemBuilder: (context, index) => _getSOSItem(SosItemList[index], index),
      ),
    );
  }

  Widget _getSOSItem(SOSItem sosItem, int index) {
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
            icon: Icons.safety_check_rounded,
            label: '设为紧急项',
          ),
        ],
      ),
      child: GestureDetector(
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          title: Text(
            sosItem.title,
            style:
                Provider.of<AppProvider>(context, listen: false).sosTextStyle,
          ),
          subtitle: Text('tel : ${sosItem.to}'),
          trailing: InkWell(
            onTap: () {
              // makeSOSPhoneCall(sosItem.title, sosItem.to, sosItem.content);
              // makeSOSPhoneCall2(sosItem.title, sosItem.to, sosItem.content);
              showInDialog(
                context,
                title: Center(child: Text(sosItem.title)),
                builder: (context) {
                  return Container(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('呼叫号码 : ${sosItem.to}',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          Text('内容 : ${sosItem.content}',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black))
                        ],
                      ));
                },
              );
            },
            child: const Icon(
              Icons.info_outline,
              size: 20,
              color: Colors.redAccent,
            ),
          ),
        ),
        onTap: () {
          debugPrint("点击通话");
          // toast('value');
          // makeSOSPhoneCall2(sosItem.title, sosItem.to, sosItem.content);
          makeSOSPhoneCall(sosItem.title, sosItem.to, sosItem.content);
        },
      ),
    );
  }
}
