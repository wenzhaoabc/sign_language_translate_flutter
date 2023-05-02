import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/utils/PhoneUtils.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class SOSListWidget extends StatefulWidget {
  const SOSListWidget({Key? key}) : super(key: key);

  @override
  State<SOSListWidget> createState() => _SOSListWidgetState();
}

class _SOSListWidgetState extends State<SOSListWidget> {
  final List<SOSItem> SosItemList = [];

  void handleDelete(int index) async {
    showConfirmDialogCustom(context,
        title: "确定要删除《${SosItemList[index].title}》吗？",
        dialogType: DialogType.DELETE, onAccept: (BuildContext context) {
      SosItemList.removeAt(index);
      setState(() {});
    });
    List<String> strList = List.generate(
        SosItemList.length, (index) => SosItemList.elementAt(index).toString());
    await setValue(Constant.sosList, strList);
  }

  // 初始化紧急呼救数据列表
  void initSosList() async {
    var temp = getStringListAsync(Constant.sosList);
    debugPrint("initSosList : temp = $temp");

    List<String>? strList = getStringListAsync(Constant.sosList);
    debugPrint("初始化SosList : $strList");
    if (strList == null || strList.isEmpty) {
      SosItemList.add(SOSItem(
          '抢劫遇险', '110中心你好，我是一名聋哑人士，以下语音为文本合成，我现在顶山公寓室内遭遇抢劫情况，请速来救援', '110'));
      SosItemList.add(SOSItem('车祸遇险',
          '120中心你好，我是一名聋哑人士，以下语音为文本合成，我现在户外遭遇车祸遇险，我的位置是乞灵山山下，请速来救援', '120'));
      SosItemList.add(SOSItem(
          '火灾遇险', '消防中心你好，我是一名聋哑人士，以下语音为文本合成，我现在平顶山公寓室内遭遇火灾情况，请速来救援', '119'));
      SosItemList.add(SOSItem('户外紧急遇险',
          '紧急中心你好，我是一名聋哑人士，以下语音为文本合成，我现在户外遭遇紧急情况，我的位置是乞灵山山顶，请速来救援', '1008611'));
      SosItemList.add(SOSItem(
          '测试项',
          '紧急中心你好，我是一名聋哑人士，以下语音为文本合成，我现在户外遭遇紧急情况，我的位置是乞灵山山顶，请速来救援',
          '18105022730'));
      List<String> strList = List.generate(SosItemList.length,
          (index) => SosItemList.elementAt(index).toString());
      await setValue(Constant.sosList, strList);
      return;
    }
    for (var value in strList) {
      var jsonItem = jsonDecode(value);
      SOSItem item = SOSItem.fromJson(jsonItem);
      SosItemList.add(item);
    }
    setState(() {});
  }

  void handleEdit(int index) async {
    var sosItem = SosItemList.elementAt(index);
    var res = await PhoneUtils.createShortCut(
        sosItem.title, sosItem.to, sosItem.content);
    if (res == true) {
      MyToast.showToast(msg: '创建成功');
    } else {
      MyToast.showToast(msg: '创建失败');
    }
  }

  void makeSOSPhoneCall(String title, String to, String content) async {
    var phonePermission = await Permission.phone.request();
    var storagePermission = await Permission.storage.request();
    await Permission.audio.request();
    if (phonePermission == PermissionStatus.granted &&
        storagePermission == PermissionStatus.granted) {
      var res = await PhoneUtils.makePhoneCall(title, to, content);
      if (res) {
        debugPrint("flutter : 拨打成功");
      } else {
        debugPrint("flutter : 拨打失败");
      }
    } else {
      debugPrint("flutter : 权限申请失败");
    }
  }

  @override
  void initState() {
    initSosList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 400,
      // color:Colors.amber,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            SosItemList.length,
            (index) => _getSOSItem(SosItemList[index], index),
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
            label: '添加到桌面',
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
            makeSOSPhoneCall(sosItem.title, sosItem.to, sosItem.content);
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
