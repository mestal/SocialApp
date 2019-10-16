import 'package:falci/AuthSingleton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:falci/ColorLoader.dart';

class NewCoffeeFalSelectFalci extends StatefulWidget {

  PageController pageController;
  NewCoffeeFalSelectFalci({this.pageController});

  @override
  State createState() => new NewCoffeeFalSelectFalciState(pageController: pageController);
}

class NewCoffeeFalSelectFalciState extends State<NewCoffeeFalSelectFalci> {
  PageController pageController;
  NewCoffeeFalSelectFalciState({this.pageController});

  List<FalciModel> falciList = new List<FalciModel>();

  gotoDetailAndSubmit() {
    //controller_0To1.forward(from: 0.0);
    PagerSingleton.instance.router.navigateTo(context, "/newfalsubmit");
    // pageController.animateToPage(
    //   5,
    //   duration: Duration(milliseconds: 800),
    //   curve: Curves.bounceOut,
    // );
  }

  @override
  Widget build(BuildContext context) {

    Future<List<FalciModel>> getAllFalci() async
    {
      var falciList1 = new List<FalciModel>();
      if(AuthSingleton.instance.user == null)
        return falciList1;
        
      var result = await Firestore.instance.collection('Falci').getDocuments();

      await Future.wait(
          result.documents.map((document) async
          {
            var newFalci = FalciModel.map(document.data);
            falciList1.add(newFalci);
          }
        )
      );

      return falciList1;
    }

    return 
      Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Falcı seç'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: 

            new FutureBuilder(
              future: getAllFalci(),
               builder: (BuildContext context, AsyncSnapshot<List<FalciModel>> snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error123: ${snapshot.error}');
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Container(
                              child: Center(
                                child: ColorLoader(
                                  radius: 20.0,
                                  dotRadius: 5.0,
                                ),
                                //ColorLoader2(),
                              )
                            );
                          default:
                            return new ListView(
                              children: snapshot.data
                                .map((FalciModel newFalci) {
                                  return GetCard(context, newFalci);
                              }).toList(),
                            );
                        }
                      },
            )
            ),
          )
      );
  }

  Future<String> getUrl(String imageName) async {
      StorageReference ref = FirebaseStorage.instance.ref().child(imageName);
      String url = (await ref.getDownloadURL()).toString();
      return url;
  }

  Widget GetCard(BuildContext context, FalciModel falci) {
    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[
            //Text(createDate.toString()),
            falci.imagePath == null ? Text("123") : 
              CachedNetworkImage(
                //placeholder: CircularProgressIndicator(),
                imageUrl:
                    falci.imagePath,
              ),
            Text(falci.name.toString() + '(' + falci.coffeePriceAsPoint.toString() + ' puan)'),
            Text(falci.description.toString()),
            Text('Baktığı fal sayısı: ' + falci.coffeeFalCount.toString()),
            FlatButton(
              child: Text("Seç"),
              onPressed: () {
                PagerSingleton.instance.newFal.fortuneTellerUserId = falci.falciId;
                PagerSingleton.instance.newFal.pointSpent = falci.coffeePriceAsPoint;
                gotoDetailAndSubmit();
              }
            ),
          ],
        )
      )
    );
  }
}