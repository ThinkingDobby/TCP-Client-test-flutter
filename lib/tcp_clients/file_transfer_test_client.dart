import 'dart:typed_data';

import 'package:tcp_client_test/tcp_clients/basic_test_client.dart';
import 'package:tcp_client_test/util/util.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(int type, Uint8List data) async{
    Uint8List header = Uint8List.fromList([type] + Util.convertInt2Bytes(data.length, Endian.big, 4));
    // clntSocket.add(header + data);
    clntSocket.add(data);
    stopClnt();
  }
}