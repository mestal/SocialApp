import 'package:falci/base/screen_view.dart';
import 'package:falci/data/db_helper.dart';
import 'package:falci/Injector.dart';
import 'package:falci/data/network/network_data.dart';


abstract class ScreenPresenter<T extends ScreenView> {
  T _view;
  Injector _injector;
  DbHelper _dbHelper;
  NetworkData _networkData;
  String _tag;

  ScreenPresenter(this._view, this._tag) {
    _injector = new Injector();
    _dbHelper = _injector.dbHelper;
    _networkData = _injector.networkData;
  }

  void loadMovies() {
    _dbHelper.getMovies(_tag).then((list){
      if (list.length > 0 && list != null) {
        _view.onMoviesLoaded(list);
      }
    });
  }

  void loadNews() {
    // _dbHelper.getMovies(_tag).then((list){
    //   if (list.length > 0 && list != null) {
    //     _view.onMoviesLoaded(list);
    //   }
    // });
  }

  String get tag => _tag;

  NetworkData get networkData => _networkData;

  DbHelper get dbHelper => _dbHelper;

  T get view => _view;


}