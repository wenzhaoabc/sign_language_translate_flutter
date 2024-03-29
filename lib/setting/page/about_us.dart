import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:sign_language/provider/AppProvider.dart';
import 'package:sign_language/res/constant.dart';
import 'package:sign_language/setting/page/operate_guide.dart';
import 'package:sign_language/utils/SlidePageUtil.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double fontSize = Provider.of<AppProvider>(context).normalFontSize;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          // image: NetworkImage(Constant.bg_img_url),
          image: AssetImage(Constant.bg_img_assets),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('关于我们'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 30),
                alignment: Alignment.center,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'SignHear',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('版本 : 1.3.0')
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: deviceWidth,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),

                child: Neumorphic(
                  padding: EdgeInsets.all(10),
                  style: NeumorphicStyle(
                    color: Colors.white70,
                    depth: 1
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            child: Text('操作指南',
                                style: TextStyle(fontSize: fontSize - 3)),
                            onPressed: () {
                              Navigator.of(context).push(MySlidePageRoute(page: const OperateGuidePage(index: 0)));
                            },
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.arrow_forward_ios,size: fontSize - 3)
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            child: Text('开源说明',
                                style: TextStyle(fontSize: fontSize - 3)),
                            onPressed: () {
                              Navigator.of(context).push(MySlidePageRoute(page: const OperateGuidePage(index: 1)));
                            },
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.arrow_forward_ios,size: fontSize - 3)
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            child: Text('隐私政策',
                                style: TextStyle(fontSize: fontSize - 3)),
                            onPressed: () {
                              Navigator.of(context).push(MySlidePageRoute(page: const OperateGuidePage(index: 2)));
                            },
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.arrow_forward_ios,size: fontSize - 3)
                        ],
                      )
                    ],
                  ),
                )
              ),
              Expanded(child: Container()),
              _getItem(
                  Icon(
                    Icons.mail,
                    color: Colors.blue,
                    size: 20,
                  ),
                  '反馈邮箱',
                  '2050747@tongji.edu.cn'),
              SizedBox(
                height: 10,
              ),
              _getItem(
                  Icon(
                    Icons.phone,
                    color: Colors.red,
                    size: 20,
                  ),
                  '联系电话',
                  '18816589205'),
              SizedBox(
                height: 10,
              ),
              _getItem(
                  Icon(
                    Icons.location_city_sharp,
                    color: Colors.green,
                    size: 20,
                  ),
                  '联系地址',
                  '上海市嘉定区曹安公路4800号'),
              SizedBox(height: 30)
            ],
          )),
    );
  }

  Widget _getItem(Icon icon, String title, String content) {
    return Container(
      // margin: EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }
}
