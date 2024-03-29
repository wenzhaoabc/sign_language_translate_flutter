import 'dart:convert';

import 'package:sign_language/toolkit/chat/models/chat_bean.dart';
import 'package:sign_language/toolkit/chat/models/model_list.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nb_net/flutter_net.dart';
import 'package:sign_language/toolkit/chat/models/chat_model.dart';
import 'package:sign_language/toolkit/chat/provider/constants.dart';

class ChatRepository {
  Future<ModelList?> getModels() async {
    var result = await get(
      '/models',
      decodeType: ModelList(),//get请求返回结果的类型
    );
    result.when(
        success: (data) {
          return data;
        },
        failure: (String msg, int code) {});
    return null;
  }

  Future<List<ChatBean>> sendMessageGPT({required String message}) async {
    var result = await post('/chat/completions',
        data: jsonEncode({
          "model": aiModel,
          "messages": [
            {
              "role": "user",
              "content": message,
            }
          ]
        }),
        decodeType: ChatModel());//Post 返回结果的类型

    List<ChatBean> chatList = [];

    result.when(success: (model) {
      model.choices?.forEach((element) {
        var content = element.message?.content;
        if (content?.isNotEmpty ?? false) {
          chatList.add(ChatBean(msg: content!, chatIndex: 1));
        }
      });
    }, failure: (msg, __) {
      EasyLoading.showToast(msg);
    });

    return chatList;
  }
}
