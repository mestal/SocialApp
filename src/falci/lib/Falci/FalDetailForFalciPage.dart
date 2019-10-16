import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';

class FalDetailForFalciPage extends StatefulWidget {
  final String falId;

  FalDetailForFalciPage(this.falId);

  @override
  State createState() => new FalDetailForFalciPageState(falId);
}

class FalDetailForFalciPageState extends State<FalDetailForFalciPage> {
  
  final String falId;
  TextEditingController _commentController = TextEditingController();
  // @override
  // initState() async {
  //   var abc = 123;
  // }

  FalDetailForFalciPageState(this.falId);

  Future<FalListModel> getFalDetail() async
  {
    var fal = await Firestore.instance.collection('Fal').document(falId).get();

    var falModel = FalListModel.map(fal.data);

    var i = 0;

    await Future.wait(falModel.images.map((item) async {

      var realPath = await getUrl(item);
      falModel.images[i] = realPath;
      i++;
    }));

    return falModel;
  }

  Future<String> getUrl(String imageName) async {
      StorageReference ref = FirebaseStorage.instance.ref().child(imageName);
      String url = (await ref.getDownloadURL()).toString();
      return url;
  }

  void SubmitComment()
  {
    var model = new SubmitFalCommentModel(
      id: falId,
      status: FalStatus.CommentedByFT.index,
      fal: _commentController.text,
      submitDateByFalci: DateTime.now()
    );
    FireStoreHelper.dbHelper.submitFalComment(model).then((result) {
      PagerSingleton.instance.router.navigateTo(context, "/falci/home");
    });
  }

  Widget GetCard(BuildContext context, String imagePath) {
    return 
    //Card (
    //  child: 
        Container (
          padding: const EdgeInsets.only(top: 5.0),
          child: Image.network(imagePath),
        )
    //)
    ;
  }

  Widget EnterComment() {
    return 
      // new Material(
      // child:
        new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: new Text(
                        "Fal",
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
              new Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.redAccent,
                        width: 0.5,
                        style: BorderStyle.solid),
                  ),
                ),
                padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        controller: _commentController,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new FlatButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        color: Colors.redAccent,
                        onPressed: () async {
                          SubmitComment();
                        },
                        child: new Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 20.0,
                          ),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: Text(
                                  "Gönder",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        );
    //);
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
            var fal = snapshot.data;
            return new Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Divider(
                      height: 15.0,
                    ),

                    // Flexible(
                    //   child: 

                    // ),

                    //fal.status == FalStatus.SentByUser.index ? EnterComment() : new Container(),
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
                    fal.status == FalStatus.CommentedByFT.index ? new Row(
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
                    ) : new Container(),
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
                    Divider(
                      height: 25.0,
                    ),
                      SizedBox(
                        height: double.tryParse(fal.images.length.toString()) * 300,
                        width: 200,
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: fal.images.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Image.network(fal.images[index].toString());// Text(fal.images[index].toString());
                          },
                        ),
                      ),
                    
                    // Text('deneme'),
                    // Expanded(
                    //   child: SizedBox(
                    //     height: 200.0,
                    //     child: 
                    //       ListView(
                    //         children: 
                    //           fal.images
                    //           .map((imagePath) {
                    //             return Expanded (
                    //               //padding: const EdgeInsets.only(top: 5.0),
                    //               child: Image.network(imagePath),
                    //             );
                    //           })//.followedBy([Container(child: EnterComment(),)])
                    //           .toList()
                    //       ),
                    //   )
                    // ),


                    // Padding(
                    //       padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0),
                    //       child: 
                    //             ListView(
                    //               children: 
                    //                 fal.images
                    //                 .map((imagePath) {
                    //                   return Container (
                    //                     padding: const EdgeInsets.only(top: 25.0),
                    //                     child: Image.network(imagePath),
                    //                   );
                    //                 })//.followedBy([Container(child: EnterComment(),)])
                    //                 .toList()
                    //             ),
                    //     )
                    Divider(
                      height: 40.0,
                    ),
                  ],
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                );   
            
            // new Column(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: <Widget>[
            //       Expanded(
            //         flex: 2,
            //         child: Column(
            //             //crossAxisAlignment: CrossAxisAlignment.start,
            //             children: <Widget>[
            //               SizedBox(height: 10.0),
            //               Row(
            //                 children: <Widget>[
            //                   Text(fal.userName,// createDate.toString(),
            //                     textAlign: TextAlign.left, 
            //                     style: TextStyle(
            //                       fontFamily: 'Quicksand',
            //                       fontSize: 17.0,
            //                       fontWeight: FontWeight.bold
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               SizedBox(height: 5.0),
            //               Container(
            //                 width: 250.0,
            //                 child: Text('UserId: ' + fal.userId.toString(), 
            //                   textAlign: TextAlign.left, 
            //                   style: TextStyle (
            //                     fontFamily: 'Quicksand' ,
            //                     color: Colors.grey,
            //                     fontSize: 12.0,
            //                   ),
            //                 )
            //               ),
            //             ],
            //           ),
            //       ),
                  
            //   ]
            // );
          }
        }
      );
    }

    @override
    Widget build(BuildContext context) {

      return new Scaffold(
        appBar: AppBar(
          title: const Text('Fal Detay'),
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            
              // Divider(
              //   height: 30.0,
              // ),
            EnterComment(),
            GetFutureBuilder(),
            
            Divider(
              height: 100.0,
            ),
          ],
        )
      )
    );
  }
}
