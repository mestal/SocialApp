import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';

class FalciHomePage extends StatefulWidget {

  @override
  State createState() => new FalciHomePageState();
}

class FalciHomePageState extends State<FalciHomePage> {
  
  @override
  Widget build(BuildContext context) {

    _logOut() async{
      await AuthSingleton.instance.signOut();
      PagerSingleton.instance.router.navigateTo(context, "/");
    }

    return Scaffold(
      appBar: new AppBar(
        title: FlatButton(
          child: new Text("Falcı"),
          onPressed: () {
            PagerSingleton.instance.router.navigateTo(context, "/home");
          },
        ),// new Text("Falcı"),
        automaticallyImplyLeading: false, //Back button
        elevation: 2.0,
                actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: const Text('Sign out'),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                if (AuthSingleton.instance.auth.currentUser() == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: const Text('No one has signed in.'),
                  ));
                  return;
                }
                _logOut();

              },
            );
          })
        ],
      ),
        body: Material(child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: 
          //  Text("denemee")
          
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('Fal')
                .where('FortuneTellerUserId', isEqualTo: AuthSingleton.instance.user.uid)
                .where('Status', isGreaterThan: 0 )
                .snapshots(),
              builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                            //var falItem = FalListModel.map(document.data);
                            return new FalItem(
                              id: document.reference.documentID,
                              userId: document['UserId'],
                              status: document['Status'],
                              type: document['Type'],
                              submitDateByUser: document['SubmitDateByUser'],
                              userName: document['UserName'],
                            );
                        }).toList(),
                      );
                  }
                },
              )
            ),
          )
      )
    );
  }
}

// class CustomFal extends StatelessWidget {
//   CustomFal({@required this.id, this.userId, this.status, this.type, this.createDate});

//   final id;
//   final userId;
//   final status;
//   final type;
//   final createDate;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         child: Container(
//             padding: const EdgeInsets.only(top: 5.0),
//             child: Column(
//               children: <Widget>[
//                 //Text(createDate.toString()),
//                 Text(id.documentID.toString()),
//                 Text(createDate.toString()),
//                 FlatButton(
//                     child: Text("İncele"),
//                     onPressed: () {
//                       // Navigator.push(
//                       //     context,
//                       //     MaterialPageRoute(
//                       //         builder: (context) => SecondPage(
//                       //             title: title, description: description)));
//                     }),
//               ],
//             )));
//   }
// }

class FalItem extends StatelessWidget {
  FalItem({@required this.id, this.userId, this.status, this.type, this.submitDateByUser, this.userName});

  final id;
  final userId;
  final status;
  final type;
  final submitDateByUser;
  final userName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
      child: new FlatButton(
        onPressed: () {
          PagerSingleton.instance.router.navigateTo(context, "/falci/faldetail/" + id);
        },
        child: Container(
          height: 70.0,
          width: double.infinity,
          color: Colors.white,
          child: Row(children: <Widget>[
            Container(
              width: 80.0,
              height: 40.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: status == FalStatus.SentByUser.index ? AssetImage('assets/images/envelope_closed.png'): AssetImage('assets/images/envelope_open.png'), //AssetImage('assets/images/envelope_closed.png'), //
                  fit: BoxFit.contain
                )
              )
              ,),
              SizedBox(width: 5.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Row(children: <Widget>[
                    Text(userName,// createDate.toString(),
                    textAlign: TextAlign.left, 
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold
                    ),),
                  ],),
                  SizedBox(height: 5.0),
              Container(
                width: 150.0,
                child: Text(formatDate(submitDateByUser.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]), 
                  textAlign: TextAlign.left, 
                  style: TextStyle (
                    fontFamily: 'Quicksand' ,
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                )
              ),
              Container(
                width: 150.0,
                child: Text(EnumOperations.getFalStatusText(status), 
                  textAlign: TextAlign.left, 
                  style: TextStyle (
                    fontFamily: 'Quicksand' ,
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                )
              )
                ],
              ),
            ],
          ),
        ),
      )
    );

  }
}