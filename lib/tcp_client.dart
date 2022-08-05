import 'dart:io';
import 'package:flutter/material.dart';

import 'package:get_ip/get_ip.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TCPClient extends StatefulWidget {

  @override
  State createState() => _TCPClientState();
}

class _TCPClientState extends State<TCPClient> {

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class BasicTestClient {
  String host = "127.0.0.1";
  int port = 10001;
  int bufSize = 1024;

  late Socket clntSocket;

  void initSocket() async {
    clntSocket = await Socket.connect(host, port);
  }

}