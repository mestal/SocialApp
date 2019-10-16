import 'package:falci/data/FireStoreHelper.dart' as prefix0;
import 'package:falci/data/FirestoreHelper.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:falci/routes.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //TODO delete signout
  //await AuthSingleton.instance.signOut();
  await AuthSingleton.instance.SetUser(null);

  runApp(new AppComponent(HomeScreen()));
}

class AppComponent extends StatefulWidget {
  final Widget child;

  static AppComponentState of(BuildContext context) {
    return(context.inheritFromWidgetOfExactType(InheritedStateContainer) as InheritedStateContainer).data;
  }

  AppComponent(@required this.child);
  

  @override
  State createState() {
    return new AppComponentState();
  }
}

class AppComponentState extends State<AppComponent> {
  
  final FirebaseMessaging messaging = FirebaseMessaging();
  int userPoint;// = AuthSingleton.instance.userModel.point; 
  int unreadMessageCount;

  @override
  void initState() {
    super.initState();
    if(AuthSingleton.instance.userModel != null)
    {
      userPoint = AuthSingleton.instance.userModel.point;
      unreadMessageCount = AuthSingleton.instance.unreadMessageCount;
    }
  }

  void updateUserPoint({newPoint})
  {
    if(userPoint != newPoint)
    {
      userPoint = newPoint;
      setState(() {
        userPoint = newPoint; 
      });
    }
  }

  void updateUnreadMessageCount({newMessageCount})
  {
    if(unreadMessageCount != newMessageCount)
    {
      unreadMessageCount = newMessageCount;
      setState(() {
        unreadMessageCount = newMessageCount; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    messaging.getToken().then((token)
    {
      print('user messaging token: ' + token);
      AuthSingleton.instance.userMessagingToken = token;
      var userModel = AuthSingleton.instance.userModel;
      if(userModel != null && userModel.messagingToken != token)
      {
        userModel.messagingToken = token;
        FireStoreHelper.dbHelper.updateMessagingToken(userModel.userId, token);
      }
    });

    messaging.configure(
      onMessage: (Map<String, dynamic> message) {
          //print('on message $message');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text('Deneme'),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Kapat"),
                    onPressed: () {
                      //Navigator.of(context).pop();
                    },
                  )
                ]
              );
            }
          );
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );

    messaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true)
    );

    return InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class InheritedStateContainer extends InheritedWidget {
  final AppComponentState data;
  InheritedStateContainer({
    Key key,
     @required this.data,
     @required Widget child
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}

class HomeScreen extends StatefulWidget {

  HomeScreen();

  @override
  State createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();




  }

  HomeScreenState() {
    final router = new Router();
    Routes.configureRoutes(router);
    PagerSingleton.instance.router = router;
  }

  @override
  Widget build(BuildContext context) {

    final app = new MaterialApp(
      title: 'Falcı',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: PagerSingleton.instance.router.generator,
    );
    print("initial route = ${app.initialRoute}");
    return app;
  }
}

class MyAppBar extends AppBar
{
  MyAppBar({Key key, Widget title, bool automaticallyImplyLeading = true}) : 
  super(
    key: key, 
    title: title, 
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: <Widget>[
          Builder(builder: (BuildContext context) {
            final container = AppComponent.of(context);
            var userPoint = container.userPoint;
            var unreadMessageCount = container.unreadMessageCount;

            return 
              Row(children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Puan:' + userPoint.toString()),
                ),
                SizedBox(
                  width: 20
                ,),
                //Align(
                  //alignment: Alignment.centerRight,
                  //child: 
                  IconButton(
                    icon: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Icon(Icons.email, size: 22.0,),
                        
                        unreadMessageCount != null && unreadMessageCount > 0 ?
                          Positioned(
                            child: Text(unreadMessageCount.toString()),
                            top: -5,
                            right: -5
                          ) : Container()
                      ],
                    ),
                    onPressed: () {
                      PagerSingleton.instance.router.navigateTo(context, "/messages");
                    },
                  )
                  
                    
                //)
                ,
                new PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuItem> menuItemList = new List<PopupMenuItem>();
                    menuItemList.add(new PopupMenuItem(
                      child: ListTile(
                          title: Text("Fallarım"),
                          onTap: () {
                            PagerSingleton.instance.router.navigateTo(context, "/user/fals");
                          }
                        )
                    ));
                    menuItemList.add(new PopupMenuItem(
                      child: ListTile(
                          title: Text("Puan satın al"),
                          onTap: () {
                            PagerSingleton.instance.router.navigateTo(context, "/pointlist");
                          }
                        )
                    ));
                    menuItemList.add(new PopupMenuItem(
                      child: ListTile(
                          title: Text("Çıkış"),
                          onTap: () async {
                            if (AuthSingleton.instance.auth.currentUser() == null) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: const Text('No one has signed in.'),
                              ));
                              return;
                            }
                            await AuthSingleton.instance.signOut();
                            PagerSingleton.instance.router.navigateTo(context, "/");
                          },
                        )
                    ));
                    return menuItemList;
                  },
                )
                // FlatButton(
                //   child: const Text('Çıkış'),
                //   textColor:  Colors.white,// Theme.of(context).buttonColor,
                //   onPressed: () async {
                //     if (AuthSingleton.instance.auth.currentUser() == null) {
                //       Scaffold.of(context).showSnackBar(SnackBar(
                //         content: const Text('No one has signed in.'),
                //       ));
                //       return;
                //     }
                //     await AuthSingleton.instance.signOut();
                //     PagerSingleton.instance.router.navigateTo(context, "/");
                //   },
                // )
              ],)
              ;
          })
        ],);
}