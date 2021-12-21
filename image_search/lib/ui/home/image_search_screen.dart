import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_search/model/album.dart';
import 'package:image_search/model/photo.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({Key? key}) : super(key: key);

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  String _query = 'apple';
  List<Photo> _photos = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future<List<Photo>> fetchPhotos(String query) async {
    final response = await http.get(Uri.parse(
        'https://pixabay.com/api/?key=24806114-c007510d8db60c6c4666be055&q=$query&image_type=photo&pretty=true&per_page=100'));

    if (response.statusCode == 200) {
      return Photo.listToPhotos(jsonDecode(response.body)['hits']);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<void> searchImage() async {
    _photos = await fetchPhotos(_query);

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
        title: const Text('이미지 검색'),
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
