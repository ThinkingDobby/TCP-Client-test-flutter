import 'dart:typed_data';

class Util {
  static List<int> convertInt2Bytes(value, Endian order, int bytesSize ) {
    const kMaxBytes = 8;
    var bytes = Uint8List(kMaxBytes)
      ..buffer.asByteData().setInt64(0, value, order);
    List<int> intArray;
    if(order == Endian.big){
      intArray = bytes.sublist(kMaxBytes-bytesSize, kMaxBytes).toList();
    }else{
      intArray = bytes.sublist(0, bytesSize).toList();
    }
    return intArray;
  }
}