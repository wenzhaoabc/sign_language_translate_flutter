import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sign_language/res/constant.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(Constant.bg_img_url),
          // image: AssetImage("images/R_C.jpg"),
          fit: BoxFit.cover,
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
                margin: EdgeInsets.only(top: 50, bottom: 50),
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
                      '灵动手语',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('版本 : 1.0.0')
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _getItem(
                  Icon(
                    Icons.mail,
                    color: Colors.blue,
                    size: 25,
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
                    size: 25,
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
                    size: 25,
                  ),
                  '联系地址',
                  '上海市嘉定区曹安公路4800号')
            ],
          )),
    );
  }

  Widget _getItem(Icon icon, String title, String content) {
    return Container(
      margin: EdgeInsets.only(left: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              Text(
                title,
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          Text(
            content,
            style: TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }
}
