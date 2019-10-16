import 'package:flutter/material.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:flutter/rendering.dart';
//import 'package:date_format/date_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';

class FalDetailForUserPage extends StatefulWidget {

  FalListModel falModel;
  final String falId;

  FalDetailForUserPage(this.falId);

  @override
  State createState() => new FalDetailForUserPageState(falId);
}

class FalDetailForUserPageState extends State<FalDetailForUserPage> {
  final String falId;
  FalDetailForUserPageState(this.falId);

  @override
  void initState() {
    super.initState();
  }

  Future<FalListModel> getFalDetail() async
  {
    var fal = await Firestore.instance.collection('Fal').document(falId).get();

    var falModel = FalListModel.map(fal.data);

    return falModel;
  }

  Widget GetFutureBuilder()
  {
    return FutureBuilder(
      future: getFalDetail(),
      builder: (BuildContext context, AsyncSnapshot<FalListModel> snapshot) {
        if (snapshot.hasError)
          return new Text('Error123: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
                        child: Center(
                          child: ColorLoader(
                              radius: 20.0,
                              dotRadius: 5.0,
                            ),
                            //ColorLoader2(),
                          )
                        );
          default:
            var fal = snapshot.data;
            return //SingleChildScrollView(child:Text(fal.id));
            SingleChildScrollView(
                child: new Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Divider(
                      height: 15.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Durum: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              EnumOperations.getFalStatusText(fal.status),
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Gönderim tarihi: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              formatDate(fal.submitDateByUser.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]),
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Yorum tarihi: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              fal.submitDateByFalci != null ? formatDate(fal.submitDateByFalci.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]) : '',
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Fal Konusu: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              EnumOperations.getFalIssueDescription(fal.detailType),
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "İsim: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              fal.userDisplayNameForFal ?? '',
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Doğum Tarihi: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              fal.birthDate == null ? '' : formatDate(fal.birthDate.toDate(), [dd, '-', mm, '-', yyyy]),
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Cinsiyet: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              EnumOperations.getGenderDescription(fal.genderType),
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Medeni Durum: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: new Text(
                              EnumOperations.getMaritalStatusDescription(fal.maritalStatusType),
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 5.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: new Text(
                              "Fal yorumu: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 15.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: new Text(
                              fal.fal ?? '',
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );   
        }
      }    
    );
  }

  @override
  Widget build(BuildContext context) {

    var falDetail = getFalDetail();

    return Scaffold(
              appBar: AppBar(
                title: const Text('Fal Detay'),
              ),
              body: Container(
                child: GetFutureBuilder()
              )
    );
  }
}