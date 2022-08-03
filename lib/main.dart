import 'package:flutter/material.dart';
import 'tcp_client.dart';

void main() => runApp(TCPClientTest());

const String ROOT_PAGE = '/';

class TCPClientTest extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TCP Client Test',
        debugShowCheckedModeBanner: false,
        initialRoute: ROOT_PAGE,
        routes: {
          ROOT_PAGE: (context) => TCPClient()
        }
    );
  }
}
