import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('关于我们'),
        ),
        body: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Image.asset(
                    'images/chat_logo.jpg',
                    width: 50,
                    height: 50,
                  )
                ],
              ),
            )
          ],
        ));
  }
}
