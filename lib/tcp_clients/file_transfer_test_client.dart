import 'dart:typed_data';

import 'package:tcp_client_test/tcp_clients/basic_test_client.dart';
import 'package:tcp_client_test/util/util.dart';

import 'package:fftea/impl.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(int type, Uint8List data) async {
    if (type == 1 || type == 2) {
      Uint8List header = Uint8List.fromList(
          [type] + Util.convertInt2Bytes(data.length, Endian.big, 4));
      clntSocket.add(header + data);
      await stopClnt();
    } else if (type == 3){
      var f32Data = data.buffer.asFloat32List();
      // 고속 푸리에 변환 함수 단순 적용
      var fft = FFT(f32Data.length);
      var fData = fft.realFft(f32Data);
      // print(fData.buffer.asUint8List());

      var i8Data = fData.buffer.asUint8List();
      Uint8List header = Uint8List.fromList(
          [type] + Util.convertInt2Bytes(i8Data.length, Endian.big, 4));
      clntSocket.add(header + i8Data);
      stopClnt();
    }
  }
}