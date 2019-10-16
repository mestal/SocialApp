import 'package:falci/base/screen_presenter.dart';
import 'package:falci/base/screen_view.dart';

abstract class PopularScreenView extends ScreenView {

}

class PopularScreenPresenter extends ScreenPresenter<PopularScreenView> {

  PopularScreenPresenter(ScreenView view, String tag) : super(view, tag);

  @override
  void loadMovies() {
    super.loadMovies();

    networkData.fetchPopularMovies().then((list) {
      view.onMoviesLoaded(list);
      // dbHelper.insertMovies(list, tag).then((dynamic) {
      //   print("Db updated with new $tag movies");
      // });
    });

  }

}