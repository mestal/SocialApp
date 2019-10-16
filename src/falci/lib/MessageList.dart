import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';
import 'package:falci/main.dart';
import 'package:falci/my_flutter_app_icons.dart' as CustomIcons;

class MessagesScreen extends StatefulWidget {

  @override
  State createState() => new MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {

  List<DocumentSnapshot> _messages = [];
  bool _loadingMessages = true;
  int _perPage = 10;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreMessages = false;
  bool _moreMessagesAvailable = true;

  _getMessages() async {
    Query q = Firestore.instance.collection("Message")
              //.where('Status', isEqualTo: 0 )
              .orderBy('SentTime', descending: true)
              .limit(_perPage);

    setState(() {
      _loadingMessages = true;  
    });
    
    QuerySnapshot querySnapshot = await q.getDocuments();
    _messages = querySnapshot.documents;
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    setState(() {
      _loadingMessages = false; 
    });
    
  }

  _getMoreMessages () async
  {
    print('_getMoreMessages called');
    if(_moreMessagesAvailable == false)
    {
      print('No more messages');
      return;
    }

    if(_gettingMoreMessages == true)
    {
      return;
    }

    _gettingMoreMessages = true;

    Query q = Firestore.instance.collection("Message")
          //.where('Status', isEqualTo: 0 )
          .orderBy('SentTime', descending: true)
          .startAfter([_lastDocument.data['SentTime']])
          .limit(_perPage);

    QuerySnapshot querySnapshot = await q.getDocuments();

    if(querySnapshot.documentChanges.length < _perPage)
    {
      _moreMessagesAvailable = false;
    }

    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    _messages.addAll(querySnapshot.documents);

    
    setState(() {
      
    });

    _gettingMoreMessages = false;
  }

  @override
  void initState() {
    super.initState();
    _getMessages();
    
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if(maxScroll - currentScroll < delta)
      {
      _getMoreMessages();
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new MyAppBar(
        title: FlatButton(
          child: new Text("Falcı"),
          onPressed: () {
            PagerSingleton.instance.router.navigateTo(context, "/home");
          },
        ),
        automaticallyImplyLeading: false
      ),
      floatingActionButton:  
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
        body: _loadingMessages == true ? 
          Container(
            child: Center(
              child: ColorLoader(
                radius: 20.0,
                dotRadius: 5.0,
              ) 
              //,Text("loading"),
            )
          ) 
          :
          Container(
            padding: const EdgeInsets.all(10.0),
            child: _messages.length == 0 ?
              Center(child: Text('Bilgi bulunamadı.'),)
              : ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return MessageItem(
                    id: _messages[index].data["Id"],
                    userId: _messages[index].data["UserId"],
                    sentTime: _messages[index].data["SentTime"],
                    readTime: _messages[index].data["ReadTime"],
                    status: _messages[index].data["Status"],
                    title: _messages[index].data["Title"],

                  );
                },
              )
            )
    );
        
  }
}

class MessageItem extends StatelessWidget {
  MessageItem({@required this.id, this.userId, this.sentTime, this.readTime, this.status, this.title});

  final id;
  final userId;
  final sentTime;
  final readTime;
  final status;
  final title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
      child: new FlatButton(
        onPressed: () {
          PagerSingleton.instance.router.navigateTo(context, "/messagedetail/" + id);
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
                  image: status == 0 ? AssetImage('assets/images/envelope_closed.png') : AssetImage('assets/images/envelope_open.png'), //AssetImage('assets/images/envelope_closed.png'), //
                  fit: BoxFit.contain
                )
              )
              ,),
              SizedBox(width: 5.0,),
              Container(
                width: 150.0,
                child: 
                  Column(
                    children: <Widget>[
                      SizedBox(height: 15.0,),
                      Text(title, 
                        textAlign: TextAlign.left, 
                        style: TextStyle (
                          fontFamily: 'Quicksand' ,
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                      Text(formatDate(sentTime.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]), 
                        textAlign: TextAlign.left, 
                        style: TextStyle (
                          fontFamily: 'Quicksand' ,
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      )
    );
  }
}