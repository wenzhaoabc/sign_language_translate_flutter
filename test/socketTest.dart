import 'package:socket_io_client/socket_io_client.dart';

void main() {

  Socket socket = io("ws://127.0.0.1:5002");
  socket.onConnect((_) {
    print("object");
    socket.emit('message', "test");
  });
}
