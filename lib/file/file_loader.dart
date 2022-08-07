import 'dart:io';
import 'dart:typed_data';

class FileLoader {
  //  저장소 경로
  late String storagePath;

  // 재생 위해 선택된 파일
  String selectedFile = '-1';

  // 파일 이름 저장할 리스트
  List<String> fileList = <String>[];

  List<String> loadFiles() {
    List<String> files = <String>[];

    var dir = Directory(storagePath).listSync();
    for (var file in dir) {
      // 확장자 검사
      if (checkExtWav(file.path)) {
        files.add(getFilenameFromPath(file.path));
      }
    }

    return files;
  }

  bool checkExtWav(String fileName) {
    if (fileName.substring(fileName.length - 3) == "wav") {
      return true;
    } else {
      return false;
    }
  }

  String getFilenameFromPath(String filePath) {
    int idx = filePath.lastIndexOf('/') + 1;
    return filePath.substring(idx);
  }

  deleteFiles() {
    var dir = Directory(storagePath).listSync();
    for (var file in dir) {
      if (checkExtWav(file.path)) {
        file.delete();
      }
    }
  }

  Future<Uint8List> readFile(String filePath) async {
    print(filePath);
    Uint8List data = File(filePath).readAsBytesSync();
    return data;
  }
}