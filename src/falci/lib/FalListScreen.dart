import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:falci/data/models/FalModel.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';

class FalListScreen extends StatefulWidget {

  @override
  State createState() => new FalListScreenState();
}

class FalListScreenState extends State<FalListScreen> {
  
  int userPoint;
  @override
  Widget build(BuildContext context) {

    // Firestore.instance
    // .collection('Fal')
    // //.where("topic", isEqualTo: "flutter")
    // .snapshots()
    // .listen((data) =>
    //     data.documents.forEach((doc) => print("Idd: " + doc["UserId"])));

    return Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: 
          //  Text("denemee")
          
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('Fal')
                .where('UserId', isEqualTo: AuthSingleton.instance.user.uid)
                .where('Status', isGreaterThan: 0 )
                .orderBy('Status')
                .orderBy('CreateDate', descending: true)
                .snapshots(),
              builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error123: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Container(
                        child: ColorLoader(
                              radius: 20.0,
                              dotRadius: 5.0,
                            ) 
                            //,Text("loading")
                        ,);
                    default:
                      return new ListView(
                        children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                            return new CustomFal(
                              id: document.reference,
                              userId: document['UserId'],
                              status: document['Status'],
                              type: document['Type'],
                              createDate: document['CreateDate'],
                              fal: document['Fal'],
                              detailType: document['DetailType'],
                            );
                        }).toList(),
                      );
                  }
                },
              )
            ),
          );
  }
}

class CustomFal extends StatelessWidget {
  CustomFal({@required this.id, this.userId, this.status, this.type, this.createDate, this.fal, this.detailType});

  final id;
  final userId;
  final int status;
  final type;
  final createDate;
  final fal;
  final detailType;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                //Text(createDate.toString()),
                //Text(id.documentID.toString()),
                Text(formatDate(createDate.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn])),
                Text(EnumOperations.getFalStatusText(int.parse(status.toString()))),
                //Text(fal == null ? '' : fal.toString()),
                Text(EnumOperations.getFalIssueDescription(status) ),
                FlatButton(
                    child: Text("İncele"),
                    onPressed: () {
                      PagerSingleton.instance.router.navigateTo(context, "/user/faldetail/" + id.documentID.toString());
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => SecondPage(
                      //             title: title, description: description)));
                    }),
              ],
            )));
  }
}

