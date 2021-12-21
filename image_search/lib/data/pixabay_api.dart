import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_search/model/photo.dart';

/// 픽사베이 사진 검색 api 클래스
class PixabayApi {
  Future<List<Photo>> fetchPhotos(String query) async {
    final response = await http.get(Uri.parse(
        'https://pixabay.com/api/?key=24806114-c007510d8db60c6c4666be055&q=$query&image_type=photo&pretty=true&per_page=100'));

    if (response.statusCode == 200) {
      List jsonList = jsonDecode(response.body)['hits'];
      return jsonList.map((e) => Photo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }
}
