import 'package:sign_language/toolkit/chat/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sign_language/toolkit/chat/chat_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sign_language/toolkit/chat/provider/constants.dart';
// import '../../../routes/app_pages.dart';
import 'package:sign_language/toolkit/chat/widgets/chat_widget.dart';
import 'package:sign_language/toolkit/chat/widgets/text_widget.dart';

class ChatPage extends GetView<ChatController>{
  ChatPage({super.key});

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (logic) {
      return Scaffold(
        backgroundColor: const Color(0xFF6750A4),
        // drawer:
        //   IconButton(
        //     onPressed: () async {
        //       Get.toNamed('/main');
        //     },
        //     icon: const Icon(Icons.arrow_back_sharp),
        //   ),
        appBar: AppBar(
          backgroundColor: const Color(0xFF6750A4),
          centerTitle: true,
          title: const Text(
            '智能聊天',
          ),
          // actions: <Widget>[
          //   // IconButton(
          //   //   onPressed: () async {
          //   //     await controller.getModels();
          //   //   },
          //   //   icon: const Icon(Icons.more_vert_rounded),
          //   // ),
          //   IconButton(
          //     onPressed: () async {
          //       // TODO - 翻译
          //       // Get.toNamed(Routes.TRANSLATE);
          //     },
          //     icon: const Icon(Icons.translate),
          //   ),
          //   IconButton(
          //     onPressed: () async {
          //       // TODO - 生成图片
          //       // Get.toNamed(Routes.IMAGE);
          //     },
          //     icon: const Icon(Icons.image),
          //   ),
          // ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                    controller: _listScrollController,
                    itemCount: controller.getChatList.length, //chatList.length,
                    itemBuilder: (context, index) {
                      return ChatWidget(
                        msg: controller
                            .getChatList[index].msg, // chatList[index].msg,
                        chatIndex: controller.getChatList[index]
                            .chatIndex, //chatList[index].chatIndex,
                        shouldAnimate:
                            controller.getChatList.length - 1 == index,
                      );
                    }),
              ),
              if (controller.isTyping)
                SpinKitThreeBounce(
                  color: Get.theme.colorScheme.secondary,
                  size: 18,
                ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  color: Color(0xFF21005D),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          controller: textEditingController,
                          onSubmitted: (value) async {
                            await _sendMessage();
                          },
                          decoration: InputDecoration.collapsed(
                              hintText: "How can I help you",
                              hintStyle: TextStyle(
                                color: Get.theme.colorScheme.onPrimaryContainer,
                              )),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            if (GetStorage()
                                    .read<String>(StoreKey.API)
                                    ?.isEmpty ??
                                true) {
                              showApiDialog();
                            } else {
                              await _sendMessage();
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> _sendMessage() async {
    if (controller.isTyping) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    String msg = textEditingController.text;
    textEditingController.clear();
    focusNode.unfocus();
    controller.addUserMessage(msg: msg);
    await controller.sendMessageAndGetAnswers(msg: msg);
    scrollListToEND();
  }
}
