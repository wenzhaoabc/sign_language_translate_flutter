import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/utils/PhoneUtils.dart';
import 'package:sign_language/utils/ToastUtil.dart';

class SMSListWidget extends StatefulWidget {
  const SMSListWidget({Key? key}) : super(key: key);

  @override
  State<SMSListWidget> createState() => _SMSListWidgetState();
}

class _SMSListWidgetState extends State<SMSListWidget> {
  @override
  Widget build(BuildContext context) {
    var smsItemList = Provider.of<AppProvider>(context).smsList;
    var fontSize = Provider.of<AppProvider>(context).normalFontSize;

    return Container(
      height: smsItemList.length * 100,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: smsItemList.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            startActionPane: ActionPane(motion: ScrollMotion(), children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  Provider.of<AppProvider>(context, listen: false)
                      .deleteSMSItem(smsItemList[index].title);
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
              )
            ]),
            child: GestureDetector(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                title: Text(smsItemList[index].title,
                    style: TextStyle(fontSize: fontSize - 2)),
                subtitle: Text('sms : ${smsItemList[index].to}'),
                trailing: GestureDetector(
                  child: Icon(
                    Icons.info_outline,
                    size: fontSize,
                    color: Colors.red,
                  ),
                  onTap: () {
                    var smsItem = smsItemList[index];
                    showInDialog(
                      context,
                      title: Center(child: Text(smsItem.title)),
                      builder: (context) {
                        return Container(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '发送号码 : ${smsItem.to}',
                                style: TextStyle(
                                    fontSize: fontSize - 5, color: Colors.grey),
                              ),
                              Text(
                                '内容 : ${smsItem.content}',
                                style: TextStyle(
                                    fontSize: fontSize - 3,
                                    color: Colors.black),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              onTap: () async {
                // TODO 发送短信
                SMSItem current = smsItemList[index];
                var res = await PhoneUtils.sendSOSMessage(
                    current.to, current.content);
                if (res == true) {
                  MyToast.showToast(msg: '发送成功', type: 'success');
                } else {
                  MyToast.showToast(msg: '发送失败', type: 'error');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
