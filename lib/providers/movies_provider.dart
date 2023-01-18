import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = '265af7d46626b510e606804fdca435de';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> searchMoviesList = [];

  int _popularPage = 0;
  int _searchPage = 0;

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionsStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionsStreamController.stream;

  Map<int, List<Cast>> movieCast = {};

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

// Para que el argumento sea opcional y si no tiene ningun valor sera igual a 1 [int page = 1]
  Future<String> _getJsonData(String endPoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endPoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;
    // Para notificar cambios a los widgets que esten esuchando
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    // Await the http get response, then decode the json-formatted response.
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [...popularMovies, ...popularResponse.results];
    // Para notificar cambios a los widgets que esten esuchando
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    // Mapea los datos para que no se vuelva a realizar la petición una vez ya hecha
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    movieCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final url = Uri.https(_baseUrl, '3/search/movie',
          {'api_key': _apiKey, 'language': _language, 'query': query});

      final response = await http.get(url);
      final searchResponse = SearchResponse.fromJson(response.body);

      return searchResponse.results;
    } catch (error) {
      final List<Movie> list = [];
      return list;
    }
  }

  getSearchMovies(String query) async {
    _searchPage++;

    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
      'page': _searchPage
    });
    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    final popularResponse = SearchResponse.fromJson(response.body);

    searchMoviesList = [...popularResponse.results];
    // Para notificar cambios a los widgets que esten esuchando

    notifyListeners();
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionsStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
