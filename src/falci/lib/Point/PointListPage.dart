import 'package:falci/AuthSingleton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falci/main.dart';
import 'package:falci/ColorLoader.dart';

class PointListPage extends StatefulWidget {
  //PointListPage({Key key, this.title}) : super(key: key);

  //final String title;

  @override
  _PointListPageState createState() => _PointListPageState();

}

class _PointListPageState extends State<PointListPage> {
  FirebaseUser user;
  List<IAPItem> _items = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    String msg = await FlutterInappPurchase.consumeAllItems;
    print('consumeAllItems: $msg');
    //await _getProducts();
  }

  Future<Null> _buyProduct(IAPItem item) async {
    try {
      PurchasedItem purchased = await FlutterInappPurchase.buyProduct(item.productId);
      print(purchased);
      
      var point = item.productId.substring(0, item.productId.indexOf('_'));
      var point2 = int.parse(point);
      var newPoint = await FireStoreHelper.dbHelper.increasePoint(AuthSingleton.instance.userModel.userId, point2);

      AuthSingleton.instance.userModel.point = newPoint;
      final container = AppComponent.of(context);
      container.updateUserPoint(newPoint: newPoint);

      String msg = await FlutterInappPurchase.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (error) {
      print('$error');
    }
  }

  @override
  Widget build(BuildContext context) {

    Future<List<PointModel>> getAllPoints() async
    {
      var pointList = new List<PointModel>();

      List<IAPItem> items;
      try {
        items = await FlutterInappPurchase.getProducts(["1_puan", "10_puan", "20_puan", "50_puan"]);
      }
      catch(ex)
      {
        items = await FlutterInappPurchase.getProducts(["1_puan", "10_puan", "20_puan", "50_puan"]);
        //throw ex;
      }
      
      _items = [];
      for (var item in items) {
        print('${item.toString()}');
        this._items.add(item);
      }

      //await _getProducts();

      await Future.wait(
        _items.map((product) async
          {
            var newPoint = new PointModel(id: product.productId, name: product.title);
            pointList.add(newPoint);
          }
        )
      );

      return pointList;
    }

    Widget GetCard(BuildContext context, PointModel point) {
      return Card(
        child: Container(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            children: <Widget>[
              //Text(createDate.toString()),
              Text(point.name.toString()),
              Text(point.id.toString()),
              FlatButton(
                child: Text("Seç"),
                onPressed: () {
                  var selectedItem = _items.firstWhere((a) =>
                    a.productId == point.id
                  );

                  _buyProduct(selectedItem);
                  // PagerSingleton.instance.newFal.fortuneTellerUserId = falci.falciId;
                  // PagerSingleton.instance.newFal.pointSpent = falci.coffeePriceAsPoint;
                  //gotoDetailAndSubmit();
                }
              ),
            ],
          )
        )
      );
    }


    return new Scaffold(
      appBar: 
        new MyAppBar(
          title: FlatButton(
            child: new Text("Falcı"),
            onPressed: () {
              PagerSingleton.instance.router.navigateTo(context, "/home");
            },
          ),// new Text("Falcı"),
        ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: 

            new FutureBuilder(
              future: getAllPoints(),
               builder: (BuildContext context, AsyncSnapshot<List<PointModel>> snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error123: ${snapshot.error}');
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Container(
                              child: Center(child: 
                                ColorLoader(
                                    radius: 20.0,
                                    dotRadius: 5.0,
                                  ),
                                  //ColorLoader2(),
                                )
                              );
                          default:
                            return new ListView(
                              children: snapshot.data
                                .map((PointModel newPoint) {
                                  return GetCard(context, newPoint);
                              }).toList(),
                            );
                        }
                      },
            )
            ),
          )
    );
  }
}