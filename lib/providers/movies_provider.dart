// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier{
  
  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '13c82a6eff01ea7a661072dcac5d1404';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast={}; 
  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionsStreamController = new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => this._suggestionsStreamController.stream;

  MoviesProvider(){
    this.getOnDisplayMovies();
    this.getPopularMovies();

  }

  Future<String>_getJsonData ( String endpoint, [int page =1]) async{
    final url = Uri.https(_baseUrl, endpoint , {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page'
    });
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
  // Await the http get response, then decode the json-formatted response.
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    final Map<String,dynamic> decodedData = json.decode( jsonData );
    this.onDisplayMovies = nowPlayingResponse.results;

    //notifica a los widgets sobre los eventuales cambios.
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage ++;
    // Await the http get response, then decode the json-formatted response.
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    final Map<String, dynamic> decodedData = json.decode(jsonData);
    this.popularMovies = [...popularMovies, ...popularResponse.results];
    print(popularMovies[0]);
    //notifica a los widgets sobre los eventuales cambios.
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast( int movieId ) async {

    //esta condicion es para que no se repita la condición si vuelvo a entrar a la misma peli
    if(moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson( jsonData );
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies( String query ) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey, 
      'language': _language, 
      'query': query
      });
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

    void getSuggestionsByQuery( String searchTerm ){
    debouncer.value = '';
    debouncer.onValue = ( value ) async {
      final results = await this.searchMovies(value);
      this._suggestionsStreamController.add(results);
    };
    
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) { 
      debouncer.value = searchTerm;
    });
    Future.delayed(Duration( milliseconds: 301 )).then((_) => timer.cancel());
  }
}