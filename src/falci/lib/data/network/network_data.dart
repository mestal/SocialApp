import 'package:falci/data/network/network_util.dart';
import 'dart:async';
import 'package:falci/data/models/Movie.dart';

class NetworkData {
  NetworkUtil _networkUtil;
  final String apiKey = "c95a0ddfae79f68451f7ca9d6edb7056";

  NetworkData() {
    _networkUtil = new NetworkUtil();
  }
  
  Future<List<Movie>> fetchPopularMovies() =>
    _networkUtil.request("https://api.themoviedb.org/3/movie/popular?"
        "api_key=$apiKey&language=en-US&page=1")
      .then((dynamic res) {
      List data = res['results'];
      return data.map((obj) => new Movie.map(obj)).toList();
    });

  Future<List<Movie>> fetchUpcomingMovies() =>
    _networkUtil.request("https://api.themoviedb.org/3/movie/upcoming?"
        "api_key=$apiKey&language=en-US&page=1")
        .then((dynamic res) {
      List data = res['results'];
      List<Movie> movies =  data.map((obj) {
        try {
          return new Movie.map(obj);
        } catch (ex) {
          return null;
        }
      }).toList();
      movies.removeWhere((movie) => movie == null);
      return movies;
    });

}