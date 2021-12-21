import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_search/data/pixabay_api.dart';
import 'package:image_search/model/album.dart';
import 'package:image_search/model/photo.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _query = 'apple';
  List<Photo> _photos = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PixabayApi _api = PixabayApi();

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

  Future<void> searchImage() async {
    _photos = await _api.fetchPhotos(_query);

    setState(() {});
  }

  @override
  void initState() {
    searchImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 스크린'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // 입력 텍스트 폼
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(),
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: IconButton(
                  icon: const Text('검색'),
                  onPressed: () {
                    final currentState = _formKey.currentState;
                    if (!(currentState?.validate() ?? false)) {
                      return;
                    }

                    currentState?.save();
                    searchImage();
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '값을 입력해주세요';
                }
                return null;
              },
              onSaved: (value) {
                _query = value ?? '';
              },
            ),
          ),
        ),
        // 리스트 출력
        _buildPhotos(context, _photos),
      ],
    );
  }

  Widget _buildPhotos(BuildContext context, List<Photo> photos) {
    return Expanded(
      child: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, idx) {
          return ListTile(
            leading: Image.network(photos[idx].previewURL),
            title: Text(photos[idx].tags),
          );
        },
      ),
    );
  }
}
