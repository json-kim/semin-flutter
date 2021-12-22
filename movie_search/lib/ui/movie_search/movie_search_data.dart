import 'package:movie_search/model/movie.dart';
import 'package:movie_search/model/the_movie_db_api.dart';

class MovieSearchData {
  final TheMovieDBApi _movieDBApi = TheMovieDBApi();
  List<Movie> _loadedMovies = [];
  List<Movie> get movies => [..._loadedMovies];
  bool isLoading = false;

  Future<void> initMovieData() async {
    int totalPage = await _movieDBApi.getTotalPage();

    _loadedMovies = await getAllMovies(totalPage);
  }

  Future<List<Movie>> getAllMovies(int totalPage) async {
    List<Movie> movies = [];
    for (int i = 0; i < 5; i++) {
      final moviesOfPage = await _movieDBApi.fetchMoviesWithPage(i + 1);
      movies.addAll(moviesOfPage);
    }
    return movies;
  }

  List<Movie> getMoviesWithQuery(String query) {
    return _loadedMovies.where((e) => e.title.contains(query)).toList();
  }
}
