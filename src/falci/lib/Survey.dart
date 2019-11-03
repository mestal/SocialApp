import 'dart:math';

import 'package:falci/AuthSingleton.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/ColorLoader.dart';
import 'package:flutter/rendering.dart';
import 'package:date_format/date_format.dart';

class Survey extends StatefulWidget {
  final String surveyId;

  Survey(this.surveyId);

  @override
  State createState() => new SurveyState(surveyId); //, this.pageController
}

class SurveyState extends State<Survey> {
  Widget _form;
  final String surveyId;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _mainCommentController = TextEditingController();
  // @override
  // initState() async {
  //   var abc = 123;
  // }
  ScrollController _scrollController;
  List<int> selectedValues = new List<int>();
  double scrollPosition = 0;
  bool surveyFinished = false;
  int result = -1;
  SurveyDetailModel surveyDetail;
  bool textFieldTapClicked = false;
  String showCommentTextFieldFor = "";
  SurveyState(this.surveyId);

  void onTapComment()
  {
    textFieldTapClicked = true;
  }
  @override
  void initState() {
    super.initState();
    _commentController.text = "";
    textFieldTapClicked = false;
    _scrollController = new ScrollController(initialScrollOffset: scrollPosition, keepScrollOffset: true);
  }

  @override
  Widget build(BuildContext context) {
    
     

    if (_form == null) {
      _form = _createForm(context);
    }
    if(textFieldTapClicked)
    {
      scrollPosition = _scrollController.position.pixels;
      textFieldTapClicked = false;
      return _form;
    }
    _form = _createForm(context);
    return _form;
  }

  Future<SurveyDetailModel> getSurveyDetail() async
  {
    var surveyDocument = Firestore.instance.collection('News').document(surveyId);
    var survey = await surveyDocument.get();
    var questions = await surveyDocument.collection('Questions').getDocuments();
    var comments = await surveyDocument.collection('Comments').orderBy("CreateDate").getDocuments();

    List<UserModel> users = new List<UserModel>();
    for(int i = 0; i < comments.documents.length; i ++)
    {
      var userId = comments.documents[i].data["UserId"];
      var uss = users.where((a) => a.userId == userId);
      if(uss.length == 0)
      {
        var dsUser = Firestore.instance.collection('User').document(userId);
        var userData = await dsUser.get();
        var userModel = UserModel.map(userData.data);
        users.add(userModel);
      }
    }

    var surveyModel = SurveyDetailModel.map(survey.documentID, survey.data, questions.documents, comments.documents, users, AuthSingleton.instance.user.uid);
    this.surveyDetail = surveyModel;
    if(selectedValues.length == 0){
      for(int i = 0; i < surveyModel.questions.length; i ++)
      {
        selectedValues.add(0);
      }
    }
    return surveyModel;
  }

  void onChangedRadio(int questionNo, int value)
  {
    setState(() {
      //trial = value; 
      selectedValues[questionNo] = value;
      scrollPosition = _scrollController.position.pixels;

      if(AllQuestionsAnswered())
      {
        this.surveyFinished = true;
        result = findResult();
      }

    });
  }

  bool AllQuestionsAnswered()
  {
    for(int i = 0; i < selectedValues.length; i ++)
    {
      if(selectedValues[i] == 0)
        return false;
    }

    return true;
  }

  void likeUnlikeComment(CommentModel commentModel)
  {
    bool likeOrUnlike = !commentModel.likedByTheUser;
    FireStoreHelper.dbHelper.likeUnlikeSurveyComment(surveyDetail.id, commentModel.id, likeOrUnlike, AuthSingleton.instance.user.uid);
    setState(() {
      commentModel.likedByTheUser = !commentModel.likedByTheUser;
      scrollPosition = _scrollController.position.pixels;
    });
  }

  void deleteComment(String id)
  {
    FireStoreHelper.dbHelper.deleteComment(surveyDetail.id, id);
    setState(() {
      scrollPosition = _scrollController.position.pixels;
    });
  }

  void openCommentTextField(String parentId)
  {
    setState(() {
      scrollPosition = _scrollController.position.pixels;
      showCommentTextFieldFor = parentId;
    });
  }

  void addComment(String message, String parentId)
  {
    FireStoreHelper.dbHelper.AddSurveyComment(surveyDetail.id, message, parentId, AuthSingleton.instance.user.uid);
    setState(() {
      scrollPosition = _scrollController.position.pixels;
      showCommentTextFieldFor = "";
      _commentController.text = "";
      _mainCommentController.text = "";
    });
  }

  int findResult()
  {
    List<int> resultTotalWeights = new List<int>();
    surveyDetail.results.forEach((f) => resultTotalWeights.add(0));

    for(int i = 0; i < selectedValues.length; i ++)
    {
      for(var j = 0; j <surveyDetail.results.length; j ++)
      {
        resultTotalWeights[j] += surveyDetail.questions[i].answers[selectedValues[i]].weights[j];
      }
    }

    var maxVal = resultTotalWeights.reduce(max);
    for(int i = 0; i < surveyDetail.results.length; i ++)
    {
      if(resultTotalWeights[i] == maxVal)
        return i;
    }

    return 1;
  }

  Widget GetFutureBuilder()
  {
    return FutureBuilder(
      future: getSurveyDetail(),
      builder: (BuildContext context, AsyncSnapshot<SurveyDetailModel> snapshot) {
        if (snapshot.hasError)
          return new Text('Error123 : ${snapshot.error}');
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
            var survey = snapshot.data;
            
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(survey.title),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: 
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: ScrollPhysics(),
                        //controller: _scrollController,
                        itemCount: survey.questions.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: EdgeInsets.only(left: 5, right: 5.0, top: 5.0),
                            child: Container(
                              height: survey.questions[index].answers[0].picPath?.length > 0 ?
                                (150 * ((survey.questions[index].answers.length / 2) + 1)) + 20 + (survey.questions[index].picPath.length > 0 ? 1 : 0) * 200 
                                :
                                ((70 * (survey.questions[index].answers.length)).toDouble() + (survey.questions[index].picPath.length > 0 ? 1 : 0) * 250).toDouble(),
                          
                              width: double.infinity,
                              alignment: Alignment.center,
                              //color: Colors.white,
                              child: Column(children: <Widget>[
                                Container(
                                  //width: 80.0,
                                  //height: 40.0,
                                  alignment: Alignment.center,
                                  child: Text(survey.questions[index].no.toString() + '. ' + survey.questions[index].info),
                                ),
                                survey.questions[index].picPath.length > 0 ?
                                  Image.network(survey.questions[index].picPath, width: 400, height: 200) : Container(),
                                new GridView.count(
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 1,
                                  padding: EdgeInsets.all(1),
                                  primary: true,
                                  crossAxisCount: survey.questions[index].answers[0].picPath.length > 0 ? 2 : 1,
                                  childAspectRatio: survey.questions[index].answers[0].picPath.length > 0 ? 1 : 6,
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  children: List.generate(survey.questions[index].answers.length, (indexAnswer) {
                                    return IntrinsicHeight (
                                      child: Container(
                                        height: 50,
                                        //color: Colors.yellow,
                                        margin: EdgeInsets.all(5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              // height: 60,
                                              //color: Colors.green,
                                              child: new Radio(
                                                value: indexAnswer,
                                                groupValue: selectedValues[index],
                                                onChanged: ((i) => onChangedRadio(index, i))
                                              )
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                survey.questions[index].answers[indexAnswer].picPath.length > 0 ?
                                                  Image.network(survey.questions[index].answers[indexAnswer].picPath, width: 100, height: 100) : Container(),//color: Colors.deepPurple),
                                                survey.questions[index].answers[indexAnswer].answer.length > 0 ?
                                                  Container(
                                                    child: 
                                                    Text(survey.questions[index].answers[indexAnswer].answer,
                                                      textAlign: TextAlign.left,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                      ),
                                                    //color: Colors.blue,
                                                    alignment: Alignment.centerLeft,
                                                    // height: 60,
                                                    width: 250,
                                                  ) : Container(),
                                                ],
                                              )
                                            ]
                                          )
                                        )
                                      );
                                    }
                                  ),
                                ),
                              ]
                            )
                          ),
                        );
                      },
                    )
                  ),
                  result != -1 ? Container(
                    padding: const EdgeInsets.all(10.0),
                    child: 
                      Padding(
                            padding: EdgeInsets.only(left: 5, right: 5.0, top: 5.0),
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Column(children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(survey.results[result]),
                                ),
                              ]
                              )
                            )
                        )
                        
                  )
                  :
                  Container(),

                  new Container(
                    child:
                      new Column(
                        children: <Widget>[
                          new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Expanded(
                                child: new TextField(
                                  controller: _mainCommentController,
                                  onTap: onTapComment
                                )
                              ),
                            ],
                          ),
                          new FlatButton(
                            onPressed: () =>  addComment(_mainCommentController.text, null),
                            child: new Container(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Expanded(
                                    child: Text(
                                      "Gönder",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                  ),


                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: 
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: ScrollPhysics(),
                        //controller: _scrollController,
                        itemCount: survey.comments.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: EdgeInsets.only(left: 5, right: 5.0, top: 5.0),
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              //color: Colors.white,
                              child: Column(children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(survey.comments[index].userName + ";",
                                    style: TextStyle(
                                    // color: Colors.grey[800],
                                    fontWeight: FontWeight.w900,
                                    //fontStyle: FontStyle.italic,
                                    // fontFamily: 'Open Sans',
                                    // fontSize: 40
                                    ),),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(survey.comments[index].message),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(formatDate(survey.comments[index].createDate.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]), 
                                    textAlign: TextAlign.left, 
                                    style: TextStyle (
                                      fontFamily: 'Quicksand' ,
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                    ),
                                  )
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Row(children: <Widget>[
                                    new Expanded(
                                      child:
                                        new FlatButton(
                                          onPressed: () =>  likeUnlikeComment(survey.comments[index]),
                                          child: new Container(
                                            child: new Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: Text(
                                                    "Beğen (" + survey.comments[index].likedUsers.length.toString() + ")",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: survey.comments[index].likedByTheUser ? Colors.red : Colors.black,
                                                        fontWeight: survey.comments[index].likedByTheUser ? FontWeight.bold : FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ),

                                    Text(" - "), 
                                    new Expanded(
                                      child:
                                        new FlatButton(
                                          onPressed: () =>  openCommentTextField(survey.comments[index].id),
                                          child: new Container(
                                            child: new Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: Text(
                                                    "Yanıtla",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                    survey.comments[index].userId == AuthSingleton.instance.user.uid ? Text(" - ") : Container(), 
                                    survey.comments[index].userId == AuthSingleton.instance.user.uid ? new Expanded(
                                      child:
                                        new FlatButton(
                                          onPressed: () =>  deleteComment(survey.comments[index].id),
                                          child: new Container(
                                            child: new Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: Text(
                                                    "Sil",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ) : Container(),
                                    ],),
                                ),

                                showCommentTextFieldFor == survey.comments[index].id ?
                                  new Container(
                                    child:
                                      new Column(
                                        children: <Widget>[
                                          new Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              new Expanded(
                                                child: new TextField(
                                                  controller: _commentController,
                                                  onTap: onTapComment
                                                )
                                              ),
                                            ],
                                          ),
                                          new FlatButton(
                                            onPressed: () =>  addComment(_commentController.text, survey.comments[index].id),
                                            child: new Container(
                                              child: new Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Expanded(
                                                    child: Text(
                                                      "Gönder",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                  ) : Container(),


                                ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: ScrollPhysics(),
                                  //controller: _scrollController,
                                  itemCount: survey.childComments.where((a) => a.parentId == survey.comments[index].id).length,
                                  itemBuilder: (BuildContext ctx, int indexChild) {

                                    var childComment = survey.childComments.where((a) => a.parentId == survey.comments[index].id).toList()[indexChild];

                                    return Padding(
                                      padding: EdgeInsets.only(left: 30, right: 5.0, top: 5.0),
                                      child: Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Column(children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(childComment.userName + ";",
                                              style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              ),),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(childComment.message),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(formatDate(childComment.createDate.toDate(), [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn]), 
                                              textAlign: TextAlign.left, 
                                              style: TextStyle (
                                                fontFamily: 'Quicksand' ,
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                              ),
                                            )
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            child: Row(children: <Widget>[
                                              new Expanded(
                                                child:
                                                  new FlatButton(
                                                    onPressed: () =>  likeUnlikeComment(childComment),
                                                    child: new Container(
                                                      child: new Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          new Expanded(
                                                            child: Text(
                                                              "Beğen (" + childComment.likedUsers.length.toString() + ")",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  color: childComment.likedByTheUser ? Colors.red : Colors.black,
                                                                  fontWeight: childComment.likedByTheUser ? FontWeight.bold : FontWeight.normal),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ),

                                                childComment.userId == AuthSingleton.instance.user.uid ? Text(" - ") : Container(), 
                                                  childComment.userId == AuthSingleton.instance.user.uid ? new Expanded(
                                                    child:
                                                      new FlatButton(
                                                        onPressed: () =>  deleteComment(childComment.id),
                                                        child: new Container(
                                                          child: new Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: <Widget>[
                                                              new Expanded(
                                                                child: Text(
                                                                  "Sil",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.normal),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ) : Container(),
                                              ]
                                            ),
                                          ),
                                        ]
                                      )
                                    ),
                                  );
                                },
                              )

                              ]
                            )
                          ),
                        );
                      },
                    )
                  ),
                ],
              ),
            );
          }
        }
      );
    }

    Widget _createForm(BuildContext context) { 

      _scrollController = new ScrollController(initialScrollOffset: scrollPosition, keepScrollOffset: true);
      return new Scaffold(
        appBar: AppBar(
          title: const Text('Anket Detay'),
        ),
        body: GetFutureBuilder(),
    );
  }
}