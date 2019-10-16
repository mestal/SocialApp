// import 'dart:async';
// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:flutter/material.dart';
// import 'package:falci/popular_screen/popular_screen.dart';
// import 'package:falci/liked_screen/liked_screen.dart';
// import 'package:falci/upcoming_screen/upcoming_screen.dart';

// // import 'package:falci/Injector.dart';
// import 'package:falci/data/db_path.dart';
// // import 'package:falci/data/models/Movie.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:falci/main.dart';
// import 'package:falci/AuthSingleton.dart';

// class HomePage extends StatefulWidget {

//   @override
//   State<StatefulWidget> createState() => new HomeStatePage();
// }

// class HomeStatePage extends State<HomePage> {
//   int _page = 0;
//   Future<Directory> _documentsDirectory;

//   void _getDocumentDirectory() {
//     setState(() {
//       _documentsDirectory = getApplicationDocumentsDirectory();
//     });
//   }

//   void _onBottomBarTapped(int indexClicked) {
//     setState((){
//       _page = indexClicked;
//     });
//   }

//   Widget _loadPage(BuildContext context, AsyncSnapshot<Directory> snapshot) {
//     Widget widget = new Container(width: 0.0, height: 0.0);
//     if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
//       switch (_page) {
//         case 0:
//           widget = new PopularScreen();
//           break;
//         case 1:
//           widget = new UpcomingScreen();
//           break;
//         case 2:
//           widget = new LikedScreen();
//           break;
//       }
//     }
//     return widget;
//   }

//   @override
//   Widget build(BuildContext context) {
//     _getDocumentDirectory();

//     _logOut() async{
//       await AuthSingleton.instance.signOut();
//         Navigator.push(context, MaterialPageRoute(
//           builder: (context) => MyHomePage(authenticated: false)
//         ));
//     }

//     return new Scaffold(
//       appBar: new AppBar(
//         title: new Text("Falcı"),
//         automaticallyImplyLeading: false,
//         elevation: 2.0,
//                 actions: <Widget>[
//           Builder(builder: (BuildContext context) {
//             return FlatButton(
//               child: const Text('Sign out'),
//               textColor: Theme.of(context).buttonColor,
//               onPressed: () async {
//                 if (AuthSingleton.instance.auth.currentUser() == null) {
//                   Scaffold.of(context).showSnackBar(SnackBar(
//                     content: const Text('No one has signed in.'),
//                   ));
//                   return;
//                 }
//                 _logOut();

//               },
//             );
//           })
//         ],
//       ),
//       body: new FutureBuilder(
//           builder: _loadPage,
//           future: _documentsDirectory.then((directory) async {
//             String path = join(directory.path, "movies.db");
//             if (!await new Directory(dirname(path)).exists()) {
//               try {
//                 await new Directory(dirname(path)).create(recursive: true);
//               } catch (e) {
//                 print(e);
//               }
//             }
//             new DbPath().path = path; 
//           }),
//       ),
//       bottomNavigationBar: new BottomNavigationBar(
//           currentIndex: _page,
//           onTap: _onBottomBarTapped,
//           type: BottomNavigationBarType.fixed,
//           items: [
//             new BottomNavigationBarItem(
//                 icon: new Icon(Icons.new_releases),
//                 title: new Text("Ana Sayfa"), //
//             ),
//             new BottomNavigationBarItem(
//                 icon: new Icon(Icons.update),
//                 title: new Text("Fallarım")
//             ),
//             new BottomNavigationBarItem(
//                 icon: new Icon(Icons.favorite),
//                 title: new Text("Profilim")
//             ),
//           ]
//       ),
//     );
//   }
// }
