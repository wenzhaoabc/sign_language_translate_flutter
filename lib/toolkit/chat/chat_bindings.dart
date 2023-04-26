import 'package:sign_language/toolkit/chat/repository/chat_repo.dart';
import 'package:sign_language/toolkit/chat/chat_controller.dart';
import 'package:get/get.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(repository: ChatRepository()));
  }
}
