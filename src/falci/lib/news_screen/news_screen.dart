import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falci/ColorLoader.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewsScreen extends StatefulWidget {

  @override
  State createState() => new NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {

  List<DocumentSnapshot> _news = [];
  bool _loadingNews = true;
  int _perPage = 10;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreNews = false;
  bool _moreNewsAvailable = true;

  _getNews() async {
    Query q = Firestore.instance.collection("News")
              .where('Status', isEqualTo: 0 )
              .orderBy('CreateDate', descending: true)
              .limit(_perPage);

    setState(() {
      _loadingNews = true;  
    });
    
    QuerySnapshot querySnapshot = await q.getDocuments();
    _news = querySnapshot.documents;
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    setState(() {
      _loadingNews = false; 
    });
    
  }

  _getMoreNews () async
  {
    print('_getMoreNews called');
    if(_moreNewsAvailable == false)
    {
      print('No more news');
      return;
    }

    if(_gettingMoreNews == true)
    {
      return;
    }

    _gettingMoreNews = true;

    Query q = Firestore.instance.collection("News")
          //.where('Status', isEqualTo: 0 )
          .orderBy('CreateDate', descending: true)
          .startAfter([_lastDocument.data['CreateDate']])
          .limit(_perPage);

    QuerySnapshot querySnapshot = await q.getDocuments();

    if(querySnapshot.documentChanges.length < _perPage)
    {
      _moreNewsAvailable = false;
    }

    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    _news.addAll(querySnapshot.documents);

    
    setState(() {
      
    });

    _gettingMoreNews = false;
  }

  @override
  void initState() {
    super.initState();
    _getNews();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if(maxScroll - currentScroll < delta)
      {
      _getMoreNews();
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    // Firestore.instance
    // .collection('Fal')
    // //.where("topic", isEqualTo: "flutter")
    // .snapshots()
    // .listen((data) =>
    //     data.documents.forEach((doc) => print("Idd: " + doc["UserId"])));

    return _loadingNews == true ? Container(
        child: Center(child: ColorLoader(
              radius: 20.0,
              dotRadius: 5.0,
            ) 
            //,Text("loading")
        ,)) :
    
        Container(
          padding: const EdgeInsets.all(10.0),
          child: _news.length == 0 ?
            Center(child: Text('Bilgi bulunamadı.'),)
            : ListView.builder(
              controller: _scrollController,
              itemCount: _news.length,
              itemBuilder: (BuildContext ctx, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    
                      Flexible(
                        fit: FlexFit.loose,
                        // child: FlatButton(
                            child: 
                            new Image.network(_news[index].data["MainPicturePath"],fit: BoxFit.cover),
                            
                          // ),
                      ),
                      
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0,16,0,8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Flexible(child: FlatButton(child: Text(_news[index].data["Title"]),onPressed: () {
                            PagerSingleton.instance.router.navigateTo(context, "/survey/" + _news[index].documentID.toString());
                          },
                    ),),
                            
                          ]
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0,0,0,8),
                      child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            new Icon(FontAwesomeIcons.heart, color: Colors.black,),
                            //new Icon(FontAwesomeIcons.solidHeart, color: Colors.red,),
                            SizedBox(width: 16,),
                            new Icon(FontAwesomeIcons.comment),
                          ]
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0,0,0,0),
                      child: Text("124 kişi beğendi", style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                    SizedBox(height: 45,)
                  ],
                );
                
                
                //ListTile(title: Text(_news[index].data["Title"]),);
              },
            )
          
            // StreamBuilder<QuerySnapshot>(
            //   stream: Firestore.instance.collection('News')
            //     .where('Status', isEqualTo: 0 )
            //     .orderBy('CreateDate', descending: true)
            //     .snapshots(),
            //   builder: (BuildContext context,
            //     AsyncSnapshot<QuerySnapshot> snapshot) {
            //       if (snapshot.hasError)
            //         return new Text('Error123: ${snapshot.error}');
            //       switch (snapshot.connectionState) {
            //         case ConnectionState.waiting:
            //           return new Text('Loading...');
            //         default:
            //           return new ListView(
            //             children: snapshot.data.documents
            //               .map((DocumentSnapshot document) {
            //                 return new CustomNews(
            //                   id: document.reference,
            //                   type: document['Type'],
            //                   createDate: document['CreateDate'],
            //                   title: document['Title'],
            //                   description: document['Description'],
            //                 );
            //             }).toList(),
            //           );
            //       }
            //     },
            //   )
            // ),
          );
  }
}

class CustomNews extends StatelessWidget {
  CustomNews({@required this.id, this.type, this.createDate, this.title, this.description});

  final id;
  final type;
  final createDate;
  final title;
  final description;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                //Text(createDate.toString()),
                //Text(id.documentID.toString()),
                //Text(formatDate(createDate, [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn])),
                Text(title),
                Text(description),
                // FlatButton(
                //     child: Text("İncele"),
                //     onPressed: () {
                //       // Navigator.push(
                //       //     context,
                //       //     MaterialPageRoute(
                //       //         builder: (context) => SecondPage(
                //       //             title: title, description: description)));
                //     }),
              ],
            )));
  }
}

