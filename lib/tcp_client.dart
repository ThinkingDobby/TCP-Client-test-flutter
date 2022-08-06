import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tcp_client_test/main.dart';
import 'file/file_loader.dart';

import 'package:assets_audio_player/assets_audio_player.dart';

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

  var fl = FileLoader();

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
                  fl.fileList = fl.loadFiles();
                });
                if (fl.fileList.isNotEmpty) {
                  fl.selectedFile = fl.fileList[0];
                }
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
                itemCount: fl.fileList.length,
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
                        if (fl.fileList.isNotEmpty) {
                          // print("test: $_isPlaying, ${fl.selectedFile}");
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
                        await fl.deleteFiles();
                        setState(() {
                          fl.fileList = fl.loadFiles();
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
    fl.storagePath = docsDir.path;
    setState(() {
      // 파일 리스트 초기화
      fl.fileList = fl.loadFiles();
    });
    if (fl.fileList.isNotEmpty) {
      fl.selectedFile = fl.fileList[0];
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

  RadioListTile _setListItemBuilder(BuildContext context, int i) {
    return RadioListTile(
        title: Text(fl.fileList[i]),
        value: fl.fileList[i],
        groupValue: fl.selectedFile,
        onChanged: (val) {
          setState(() {
            fl.selectedFile = fl.fileList[i];
          });
        });
  }

  Future<void> startPlaying() async {
    // 재생
    audioPlayer.open(
      Audio.file('${fl.storagePath}/${fl.selectedFile}'),
      autoStart: true,
      showNotification: true,
    );
    // print("filePathForPlaying ${fl.storagePath}/${fl.selectedFile}");
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