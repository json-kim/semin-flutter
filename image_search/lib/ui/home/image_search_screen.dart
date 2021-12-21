import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_search/data/pixabay_api.dart';
import 'package:image_search/model/photo.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({Key? key}) : super(key: key);

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  StreamController<List<Photo>> streamController =
      StreamController<List<Photo>>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PixabayApi _api = PixabayApi();

  Future<void> _searchImage(String query) async {
    final photos = await _api.fetchPhotos(query);

    streamController.add(photos);
  }

  @override
  void initState() {
    _searchImage('apple');
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
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
                final query = value ?? '';
                _searchImage(query);
              },
            ),
          ),
        ),
        // 리스트 출력
        StreamBuilder<List<Photo>>(
          stream: streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Error !!');
            }
            if (!snapshot.hasData) {
              return const Text('No Data Error !!');
            }
            return _buildPhotos(context, snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildPhotos(BuildContext context, List<Photo> photos) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: photos.length,
        itemBuilder: (context, idx) {
          return ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              photos[idx].webformatURL,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
