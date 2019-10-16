import 'package:flutter/material.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/news_screen/news_screen.dart';
import 'package:falci/FalListScreen.dart';
import 'package:falci/main.dart';
import 'package:falci/my_flutter_app_icons.dart' as CustomIcons;

class HomePage2 extends StatefulWidget {
 @override
  State createState() {
    return new HomePage2State();
  }
}

class HomePage2State extends State<HomePage2> {

  int _page = 0;

  void _onBottomBarTapped(int indexClicked) {
    setState((){
      _page = indexClicked;
    });
  }

  Widget _loadPage(BuildContext context) {
    Widget widget = new Container(width: 0.0, height: 0.0);
      switch (_page) {
        case 0:
          widget = new NewsScreen();
          break;
        case 1:
          widget = new FalListScreen();
          break;
        case 2:
          widget = new NewsScreen();
          break;
      }
    return widget;
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: 
      new MyAppBar(
        title: FlatButton(
          child: new Text("Falcı"),
          onPressed: () {
            PagerSingleton.instance.router.navigateTo(context, "/");
          },
        ),// new Text("Falcı"),
        automaticallyImplyLeading: false
      ),
      floatingActionButton:  

        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              //   FloatingActionButton(
              //       heroTag: null,
              //       onPressed: () {
              //         PagerSingleton.instance.router.navigateTo(context, "/pointlist");
              //       },
              //       materialTapTargetSize: MaterialTapTargetSize.padded,
              //       backgroundColor: Colors.redAccent,
              //       child: const Icon(Icons.add, size: 36.0),
              // ),
              // SizedBox(
              //       height: 16.0,
              // ),
              FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      PagerSingleton.instance.createNewFal();
                      PagerSingleton.instance.router.navigateTo(context, "/newfal");
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(CustomIcons.MyFlutterApp.Custom1, size: 36.0),//Icon(Icons.add, size: 36.0),
                    
              ),
            ],
        ),
        body: _loadPage(context),
      
      // bottomNavigationBar: new BottomNavigationBar(
      //   currentIndex: _page,
      //   onTap: _onBottomBarTapped,
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     new BottomNavigationBarItem(
      //         icon: new Icon(Icons.new_releases),
      //         title: new Text("Ana Sayfa"), //
      //     ),
      //     new BottomNavigationBarItem(
      //         icon: new Icon(Icons.update),
      //         title: new Text("Fallarım")
      //     ),
      //     new BottomNavigationBarItem(
      //         icon: new Icon(Icons.favorite),
      //         title: new Text("Profilim")
      //     ),
      //   ]
      // ),
    );
  }
}