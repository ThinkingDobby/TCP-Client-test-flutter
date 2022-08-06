import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// import 'package:get_ip/get_ip.dart';
// import 'package:shared_preferences/shared_preferences.dart';


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
        children: <Widget>[
          Text(_receivedData),
          ElevatedButton(onPressed: sendBtnClicked, child: const Text("전송"))
        ]
      )
    );
  }

  void sendBtnClicked() async {
    await client.sendRequest();
    client.sendData();
  }
}

class BasicTestClient {
  String _host = "192.168.35.69";
  // 192.168.35.25
  // 192.168.1.99
  // 10.0.2.2
  // 127.0.0.1
  int _port = 10001;
  int _bufSize = 1024;

  late Socket clntSocket;

  void setServAddr(String host, int port) {
    _host = host;
    _port = port;
  }

  Future<void> sendRequest() async {
    clntSocket = await Socket.connect(_host, _port);
    print("Connected");
  }

  void sendData() async{
    // 전송할 데이터 입력부
    // while (true) {
    //
    // }

    clntSocket.listen((List<int> event) {
      // 임시
      print(utf8.decode(event));
    });

    // 임시 코드 - "hello" 전달
    clntSocket.add(utf8.encode("hello"));

    // 임시 코드 - 5초 대기
    await Future.delayed(const Duration(seconds: 5));
    stopClnt();
  }

  void stopClnt() {
    clntSocket.close();
    print("Disconnected");
  }
}