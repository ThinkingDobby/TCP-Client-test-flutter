import 'dart:typed_data';

import 'package:tcp_client_test/tcp_clients/basic_test_client.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(Uint8List data) async{
    // 파일 크기 먼저 전달
    clntSocket.write(data.length);

    // 오류 해결 필요
    await Future.delayed(Duration(seconds: 1));
    clntSocket.add(data);
    stopClnt();
  }
}