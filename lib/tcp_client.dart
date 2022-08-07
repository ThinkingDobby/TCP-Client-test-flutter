import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tcp_client_test/main.dart';
import 'package:tcp_client_test/file/file_loader.dart';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:tcp_client_test/tcp_clients/file_transfer_test_client.dart';

class TCPClient extends StatefulWidget {

  @override
  State createState() => _TCPClientState();
}

class _TCPClientState extends State<TCPClient> {
  String _receivedData = "temp";
  final TextEditingController _fileNameController = TextEditingController(text: "hello");

  late FileTransferTestClient _client;

  // 재생 위한 객체 저장
  final _audioPlayer = AssetsAudioPlayer();

  // 상태 저장
  bool _isPlaying = false;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  @override
  void initState() {
    super.initState();
    _client = FileTransferTestClient();
    _initializer();
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
                  _fl.fileList = _fl.loadFiles();
                });
                if (_fl.fileList.isNotEmpty) {
                  _fl.selectedFile = _fl.fileList[0];
                }
              }, child: const Text("녹음기"))
            ],
          ),
          const SizedBox(height: 16),
          Text(_receivedData),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(border:OutlineInputBorder()),
              controller: _fileNameController,
            )
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              ElevatedButton(onPressed: _startCon, child: const Text("시작")),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _stopCon, child: const Text("중지")),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _sendData, child: const Text("전송"))
            ],
          ),
          const SizedBox(height: 32),
          // 파일 리스트
          Expanded(
              flex: 1,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _fl.fileList.length,
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
                        if (_fl.fileList.isNotEmpty) {
                          // print("test: $_isPlaying, ${_fl.selectedFile}");
                          if (!_isPlaying) {
                            // 재생 중이 아니면 재생
                            _startPlaying();
                          } else {
                            // 재생 중이면 재생 중지
                            _stopPlaying();
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
                        await _fl.deleteFiles();
                        setState(() {
                          _fl.fileList = _fl.loadFiles();
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

  void _initializer() async {
    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = docsDir.path;
    setState(() {
      // 파일 리스트 초기화
      _fl.fileList = _fl.loadFiles();
    });
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }
  }

  void _startCon() async {
    await _client.sendRequest();
    _client.clntSocket.listen((List<int> event) {
      setState(() {
        _receivedData = utf8.decode(event);
      });
    });
  }

  void _sendData() async {
    String fileName = _fileNameController.text;
    try {
      Uint8List data = await _fl.readFile("${_fl.storagePath}/$fileName");
      _client.sendFile(data);
    } on FileSystemException {
      print("File not exists: $fileName");
    }
  }

  void _stopCon() {
    _client.stopClnt();
  }

  RadioListTile _setListItemBuilder(BuildContext context, int i) {
    return RadioListTile(
        title: Text(_fl.fileList[i]),
        value: _fl.fileList[i],
        groupValue: _fl.selectedFile,
        onChanged: (val) {
          setState(() {
            _fl.selectedFile = _fl.fileList[i];
          });
        });
  }

  Future<void> _startPlaying() async {
    // 재생
    _audioPlayer.open(
      Audio.file('${_fl.storagePath}/${_fl.selectedFile}'),
      autoStart: true,
      showNotification: true,
    );
    // print("filePathForPlaying ${_fl.storagePath}/${_fl.selectedFile}");
    _audioPlayer.playlistAudioFinished.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _stopPlaying() async {
    // 재생 중지
    _audioPlayer.stop();
  }
}