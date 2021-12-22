import 'dart:convert';

import 'package:http/http.dart' as http;

import 'movie.dart';

class TheMovieDBApi {
  Future<List<Movie>> fetchMoviesWithPage(int page) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/upcoming?api_key=a64533e7ece6c72731da47c9c8bc691f&language=ko-KR&page=$page'));

    if (response.statusCode == 200) {
      return Movie.listToMovies(jsonDecode(response.body)['results']);
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<int> getTotalPage() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/upcoming?api_key=a64533e7ece6c72731da47c9c8bc691f&language=ko-KR'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total_pages'] as int;
    } else {
      throw Exception('Failed to load total_pages');
    }
  }
}
