import 'package:flutter/material.dart';

import 'package:tcp_client_test/tcp_client.dart';
import 'package:tcp_client_test/recorder.dart';

void main() => runApp(TCPClientTest());

const String ROOT_PAGE = '/';
const String RECORDER_PAGE = '/recorder';

class TCPClientTest extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TCP Client Test',
        debugShowCheckedModeBanner: false,
        initialRoute: ROOT_PAGE,
        routes: {
          ROOT_PAGE: (context) => TCPClient(),
          RECORDER_PAGE: (context) => Recorder()
        }
    );
  }
}
