import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_search/model/album.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Album? _album;

  Future<void> init() async {
    Album album = await fetchAlbum();

    setState(() {
      _album = album;
    });
  }

  // 오래 걸리는 처리
  Future<Album> fetchAlbum() async {
    // await [Future가 리턴되는 코드]
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Album.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  // 스테이트풀 위젯이 생성될 때, 맨 처음 한번만 수행
  @override
  void initState() {
    // init 비동기 함수에서 앨범을 가져오고 setState를 사용하여 반영한다.
    init();
    // Future 를 리턴하는 메서드를 수행하고 나서 실행되는 메서드를 then 을 사용하여 구현한다.
    // fetchAlbum().then((album) {
    //   setState(() {
    //     _album = album;
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 스크린'),
      ),
      body: Center(
        child: _album == null
            ? const CircularProgressIndicator()
            : Text(
                '${_album?.id}: ${_album.toString()}',
                style: const TextStyle(fontSize: 30),
              ),
      ),
    );
  }
}
