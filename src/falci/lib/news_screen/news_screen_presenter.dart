import 'package:falci/base/screen_presenter.dart';
import 'package:falci/base/screen_view.dart';

abstract class NewsScreenView extends ScreenView {

}

class NewsScreenPresenter extends ScreenPresenter<NewsScreenView> {

  NewsScreenPresenter(ScreenView view, String tag) : super(view, tag);

  @override
  void loadNews() {
    super.loadNews();

    networkData.fetchPopularMovies().then((list) {
      view.onMoviesLoaded(list);
      // dbHelper.insertMovies(list, tag).then((dynamic) {
      //   print("Db updated with new $tag movies");
      // });
    });

  }

}