import 'dart:convert';
import 'dart:io';

class BasicTestClient {
  String _host = "192.168.35.69";  // x1
  // String _host = "192.168.26.33";  // x1 - hotspot
  // String _host = "192.168.35.25"; // mac

  int _port = 10001;

  late Socket clntSocket;

  void setServAddr(String host, int port) {
    _host = host;
    _port = port;
  }

  Future<void> sendRequest() async {
    clntSocket = await Socket.connect(_host, _port);
    // print("Connected");
  }

  void sendMessage(String data) async{
    clntSocket.add(utf8.encode(data));
  }

  void stopClnt() {
    clntSocket.close();
    // print("Disconnected");
  }
}