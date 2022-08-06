import 'dart:typed_data';

import 'package:tcp_client_test/tcp_clients/basic_test_client.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(Uint8List data) async{
    clntSocket.write(data);
  }
}