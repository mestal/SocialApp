import 'package:falci/AuthSingleton.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:flutter/material.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:flutter/rendering.dart';
//import 'package:date_format/date_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';
import 'package:falci/main.dart';

class MessageDetail extends StatefulWidget {

  MessageModel messageModel;
  final String id;

  MessageDetail(this.id);

  @override
  State createState() => new MessageDetailState(id);
}

class MessageDetailState extends State<MessageDetail> {
  final String id;
  MessageDetailState(this.id);

  @override
  void initState() {
    super.initState();
  }

  Future<MessageModel> getMessageDetail() async
  {
    var message = await Firestore.instance.collection('Message').document(id).get();

    var messageModel = MessageModel.map(message.data);

    if(messageModel.status == 0)
    {
      messageModel.status = 1;
      messageModel.readTime = Timestamp.fromDate(DateTime.now());
      FireStoreHelper.dbHelper.updateMessageAsRed(messageModel.id);
      AuthSingleton.instance.unreadMessageCount = await FireStoreHelper.dbHelper.getUnreadMessageCount(AuthSingleton.instance.userModel.userId);
      final container = AppComponent.of(context);
      container.updateUnreadMessageCount(newMessageCount: AuthSingleton.instance.unreadMessageCount);
    }

    return messageModel;
  }

  Widget GetFutureBuilder()
  {
    return FutureBuilder(
      future: getMessageDetail(),
      builder: (BuildContext context, AsyncSnapshot<MessageModel> snapshot) {
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
            var message = snapshot.data;
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
                              "Başlık: ",
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
                            child: new Text(message.title,
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
                              "Mesaj: ",
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
                              message.message,
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
                              formatDate(message.sentTime.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]),
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
                              "Okunma tarihi: ",
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
                              message.status != 0 ? formatDate(message.readTime.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]) : '',
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
                  
                  ],
                ),
              );   
        }
      }    
    );
  }

  @override
  Widget build(BuildContext context) {

    var messageDetail = getMessageDetail();

    return Scaffold(
              appBar: AppBar(
                title: const Text('Mesaj'),
              ),
              body: Container(
                child: GetFutureBuilder()
              )
    );
  }
}