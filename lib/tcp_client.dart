import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tcp_client_test/main.dart';

class TCPClient extends StatefulWidget {

  @override
  State createState() => _TCPClientState();
}

class _TCPClientState extends State<TCPClient> {

  String _receivedData = "temp";
  final TextEditingController _fileNameController = TextEditingController(text: "hello");

  late BasicTestClient client;

  // 재생 위한 객체 저장
  final audioPlayer = AssetsAudioPlayer();

  // 상태 저장
  bool _isPlaying = false;

  //  저장소 경로
  late String _storagePath;

  // 재생 위해 선택된 파일
  String _selectedFile = '-1';

  // 파일 이름 저장할 리스트
  List<String> _fileList = <String>[];

  @override
  void initState() {
    super.initState();
    client = BasicTestClient();
    initializer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TCP Client Test")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget> [
              ElevatedButton(onPressed: () async {
                await Navigator.pushNamed(context, RECORDER_PAGE);
                setState((){
                  _fileList = loadFiles();
                });
              }, child: const Text("녹음기"))
            ],
          ),
          const SizedBox(height: 16),
          Text(_receivedData),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _fileNameController,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              ElevatedButton(onPressed: startCon, child: const Text("시작")),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: stopCon, child: const Text("중지")),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: sendData, child: const Text("전송"))
            ],
          ),
          const SizedBox(height: 32),
          // 파일 리스트
          Expanded(
              flex: 1,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _fileList.length,
                itemBuilder: (context, i) => _setListItemBuilder(context, i),
              )),
          // 재생 관련
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 32),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_fileList.isNotEmpty) {
                          // print("test: $_isPlaying, $_selectedFile");
                          if (!_isPlaying) {
                            // 재생 중이 아니면 재생
                            startPlaying();
                          } else {
                            // 재생 중이면 재생 중지
                            stopPlaying();
                          }

                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        }
                      },
                      child: Text(_isPlaying ? "재생 중지" : "음성 재생"))),
              Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 32),
                  child: ElevatedButton(
                      onPressed: () async {
                        // 녹음한 파일 모두 삭제
                        await deleteFiles();
                        setState(() {
                          _fileList = loadFiles();
                        });
                      },
                      style:
                      ElevatedButton.styleFrom(primary: Colors.redAccent),
                      child: const Text("전체 삭제")))
            ],
          )
        ]
      )
    );
  }

  void initializer() async {
    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _storagePath = docsDir.path;
    setState(() {
      // 파일 리스트 초기화
      _fileList = loadFiles();
    });
    if (_fileList.isNotEmpty) {
      _selectedFile = _fileList[0];
    }
  }

  void startCon() async {
    await client.sendRequest();
    client.clntSocket.listen((List<int> event) {
      setState(() {
        _receivedData = utf8.decode(event);
      });
    });
  }

  void sendData() async {
    String fileName = _fileNameController.text;
    client.sendMessage(fileName);
  }

  void stopCon() {
    client.stopClnt();
  }

  List<String> loadFiles() {
    List<String> files = <String>[];

    var dir = Directory(_storagePath).listSync();
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

  RadioListTile _setListItemBuilder(BuildContext context, int i) {
    return RadioListTile(
        title: Text(_fileList[i]),
        value: _fileList[i],
        groupValue: _selectedFile,
        onChanged: (val) {
          setState(() {
            _selectedFile = _fileList[i];
          });
        });
  }

  Future<void> startPlaying() async {
    // 재생
    audioPlayer.open(
      Audio.file('$_storagePath/$_selectedFile'),
      autoStart: true,
      showNotification: true,
    );
    // print("filePathForPlaying $_storagePath/$_selectedFile");
    audioPlayer.playlistAudioFinished.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> stopPlaying() async {
    // 재생 중지
    audioPlayer.stop();
  }

  deleteFiles() {
    var dir = Directory(_storagePath).listSync();
    for (var file in dir) {
      if (checkExtWav(file.path)) {
        file.delete();
      }
    }
  }
}

class BasicTestClient {
  String _host = "192.168.35.69";
  int _port = 10001;

  late Socket clntSocket;

  void setServAddr(String host, int port) {
    _host = host;
    _port = port;
  }

  Future<void> sendRequest() async {
    clntSocket = await Socket.connect(_host, _port);
    // print("Connected");
  }

  void sendMessage(String data) async{
    // 임시 코드 - "hello" 전달
    clntSocket.add(utf8.encode(data));
  }

  void stopClnt() {
    clntSocket.close();
    // print("Disconnected");
  }
}