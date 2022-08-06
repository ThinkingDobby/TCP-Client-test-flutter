import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class TCPClient extends StatefulWidget {

  @override
  State createState() => _TCPClientState();
}

class _TCPClientState extends State<TCPClient> {
  String _receivedData = "temp";

  late BasicTestClient client;

  @override
  void initState() {
    super.initState();
    client = BasicTestClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TCP Client Test")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(_receivedData),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              ElevatedButton(onPressed: startCon, child: const Text("시작")),
              ElevatedButton(onPressed: stopCon, child: const Text("중지")),
              ElevatedButton(onPressed: sendData, child: const Text("전송"))
            ],
          )
        ]
      )
    );
  }

  void startCon() async {
    await client.sendRequest();
  }

  void sendData() async {
    client.sendMessage("hello");
  }

  void stopCon() {
    client.stopClnt();
  }
}

class BasicTestClient {
  String _host = "192.168.35.69";
  int _port = 10001;

  late Socket clntSocket;

  void setServAddr(String host, int port) {
    _host = host;
    _port = port;
  }

  Future<void> sendRequest() async {
    clntSocket = await Socket.connect(_host, _port);
    print("Connected");
    clntSocket.listen((List<int> event) {
      // 임시
      print(utf8.decode(event));
    });
  }

  void sendMessage(String data) async{
    // 임시 코드 - "hello" 전달
    clntSocket.add(utf8.encode(data));
  }

  void stopClnt() {
    clntSocket.close();
    print("Disconnected");
  }
}