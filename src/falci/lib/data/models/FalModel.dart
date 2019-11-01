import 'package:cloud_firestore/cloud_firestore.dart';

enum FalStatus{
  Draft,
  SentByUser,
  CommentedByFT,
  CommentSeenByUser
}

class EnumOperations {
  static String getFalStatusText(int status)
  {
    if(status == 0)
    {
      return 'Yeni fal';
    }
    else if(status == 1)
    {
      return 'Fal yorumu bekleniyor';
    }
    else if(status == 2)
    {
      return 'Yorum yapıldı';
    }
    else if(status == 3)
    {
      return 'Okundu';
    }
    
    return 'NotDefined';
  }

  static String getFalIssueDescription(int value)
  {
    if(value == 0)
      return 'Aşk';
    else if (value == 1)
      return 'Kariyer / Para';
    else if (value == 2)
      return 'Sağlık';
    else if (value == 3)
      return 'Genel';

    return 'Undefined';
  }

  static String getGenderDescription(int value)
  {
    if(value == 0)
      return 'Kadın';
    else if (value == 1)
      return 'Erkek';

    return 'Undefined';
  }

  static String getMaritalStatusDescription(int value)
  {
    if(value == 0)
      return 'Bekar';
    else if (value == 1)
      return 'Evli';

    return 'Undefined';
  }
}

enum AuthProviderType
{
  UserNameAndPassword,
  Facebook,
  Google,
  Twitter
}


enum FalType{
  Coffee,
  Tarot,
  Dream
}

enum RoleType{
  User,
  Falci
}

enum UserStatus {
  Active,
  Deactive
}

enum FalIssue {
  Love,
  CarierMoney,
  Health,
  General
}

enum GenderType {
  Female,
  Male
}

enum MaritalStatus {
  Single,
  Married
}

class FalListModel {

  final String id;
  final Timestamp createDate;
  final Timestamp submitDateByUser;
  final Timestamp submitDateByFalci;
  final int type;
  final int detailType;
  final int status;
  final String userId;
  final String fortuneTellerUserId;
  final String userName;
  final List<dynamic> images;
  final Timestamp birthDate;
  final String userDisplayNameForFal;
  final int maritalStatusType;
  final int genderType;
  final String fal;
  
  FalListModel({this.id, this.createDate, this.submitDateByUser, this.submitDateByFalci, this.type, this.detailType, this.status, this.userId, this.fortuneTellerUserId, this.userName, this.images, this.birthDate, this.genderType, this.maritalStatusType, this.userDisplayNameForFal, this.fal});

  FalListModel.map(Map<String, dynamic> map) :
    id = map['Id'],
    createDate = map['CreateDate'],
    submitDateByUser = map['SubmitDateByUser'],
    submitDateByFalci = map['SubmitDateByFalci'],
    type = map['Type'],
    detailType = map['DetailType'],
    status = map['Status'],
    userId = map['UserId'],
    fortuneTellerUserId = map['FortuneTellerUserId'],
    userName = map['UserName'],
    images = map['Images'],
    birthDate = map['BirthDate'],
    genderType = map['Gender'],
    maritalStatusType = map['MaritalStatus'],
    userDisplayNameForFal = map['UserDisplayNameForFal'],
    fal = map['Fal'];
}

class FalCreateModel {

  String id;
  DateTime createDate;
  int type;
  int detailType;
  int status;
  DateTime submitDate;
  String userId;
  String userName;
  int pointSpent;
  String fortuneTellerUserId;
  List<String> images = new List<String>();
  Timestamp birthDate;
  String userDisplayNameForFal;
  int maritalStatusType;
  int genderType;

  FalCreateModel({this.id, this.createDate, this.type, this.detailType, this.status, this.submitDate, this.userId, this.userName, this.pointSpent, this.fortuneTellerUserId, this.images, this.birthDate, this.genderType, this.maritalStatusType, this.userDisplayNameForFal});

  FalCreateModel.map(Map<String, dynamic> map) :
    id = map['Id'],
    createDate = map['CreateDate'],
    type = map['Type'],
    detailType = map['DetailType'],
    status = map['Status'],
    submitDate = map['SubmitDate'],
    userId = map['UserId'],
    userName = map['UserName'],
    pointSpent = map['PointSpent'],
    fortuneTellerUserId = map['FortuneTellerUserId'],
    images = map['Images'],
    birthDate = map['BirthDate'],
    genderType = map['GenderType'],
    maritalStatusType = map['MaritalStatusType'],
    userDisplayNameForFal = map['UserDisplayNameForFal'];
}

class SubmitFalCommentModel {

  String id;
  DateTime submitDateByFalci;
  int status;
  String fal;

  SubmitFalCommentModel({this.id, this.submitDateByFalci, this.status, this.fal});

  SubmitFalCommentModel.map(Map<String, dynamic> map) :
    id = map['Id'],
    submitDateByFalci = map['SubmitDateByFalci'],
    status = map['Status'],
    fal = map['Fal'];
}

class FalciModel {

  final String falciId;
  final String name;
  final String description;
  final int coffeeFalCount;
  final String imagePath;
  final Timestamp lastLoginDate;
  final int coffeeRating;
  final int coffeeRatingCount;
  final int coffeePriceAsPoint;

  String realPath;

  FalciModel({this.falciId, this.name, this.description, this.coffeeFalCount, this.imagePath, this.lastLoginDate, this.coffeeRating, this.coffeeRatingCount, this.coffeePriceAsPoint});

  FalciModel.map(Map<String, dynamic> map) :
    falciId = map['UserId'],
    name = map['Name'],
    description = map['Description'],
    coffeeFalCount = map['CoffeeFalCount'],
    imagePath = map['ImagePath'],
    lastLoginDate = map['LastLoginDate'],
    coffeeRating = map['CoffeeRating'],
    coffeeRatingCount = map['CoffeeRatingCount'],
    coffeePriceAsPoint = map['CoffeePriceAsPoint'];
}

class UserModel {

  final String userId;
  String name;
  final DateTime lastLoginDate;
  int point;
  final int roleType;
  final String email;
  final int status;
  String messagingToken;
  final int providerType;
  Timestamp birthDate;
  int genderType;
  int maritalStatusType;

  UserModel({this.userId, this.name, this.lastLoginDate, this.point, this.roleType, this.email, this.status, this.messagingToken, this.providerType, this.birthDate, this.genderType, this.maritalStatusType});

  UserModel.map(Map<String, dynamic> map) :
    userId = map['UserId'],
    name = map['Name'],
    lastLoginDate = map['LastLoginDate'],
    point = map['Point'],
    roleType = map['RoleType'],
    email = map['Email'],
    status = map['Status'],
    messagingToken = map['MessagingToken'],
    providerType = map['ProviderType'],
    birthDate = map['BirthDate'],
    genderType = map['Gender'],
    maritalStatusType = map['MaritalStatus'];
}

class PointModel {

  String id;
  String name;

  PointModel({this.id, this.name});

  PointModel.map(Map<String, dynamic> map) :
    id = map['Id'],
    name = map['Name'];

}

class MessageModel {

  final String id;
  final Timestamp sentTime;
  Timestamp readTime;
  int status;
  final String userId;
  final String message;
  final String title;
  
  MessageModel({this.id, this.sentTime, this.readTime, this.status, this.userId, this.message, this.title});

  MessageModel.map(Map<String, dynamic> map) :
    id = map['Id'],
    sentTime = map['SentTime'],
    readTime = map['ReadTime'],
    status = map['Status'],
    userId = map['UserId'],
    message = map['Message'],
    title = map['Title'];
}

class SurveyDetailModel {
  String id;
  Timestamp createDate;
  int type;
  int status;
  String title;
  List<QuestionModel> questions;
  List<CommentModel> comments;
  List<CommentModel> childComments;
  List<dynamic> results;
  int likeCount;
  bool likedByUser;
  
  SurveyDetailModel.map(String documentId, Map<String, dynamic> map, List<DocumentSnapshot> questionsP, List<DocumentSnapshot> commentsP, List<UserModel> commentUsers, String loginUserId)  {
    id = documentId;
    createDate = map['CreateDate'];
    type = map['Type'];
    status = map['Status'];
    title = map['Title'];
    likeCount = map['LikedUsers'].toList().length;
    results = map['Results'];
    likedByUser = true;//map['LikedUsers'].toList();//.where('', isEqualto: '').any(); 

    questions = questionsP.map((question) { 
      // var ans = answersP.where((a) => a['QuestionNo'] == question['No']).toList();
      // ans.sort((a,b) => a.data['No'].compareTo(b.data['No']));
      
      return QuestionModel.map(question.data);//, ans);
    }).toList();
    questions.sort((a,b)=> a.no.compareTo(b.no));

    comments = commentsP.where((a) => a['ParentId'] == "").map((comment) {
      
      return CommentModel.map(comment.documentID, comment.data, commentUsers, loginUserId);
    }).toList();

    childComments = commentsP.where((a) => a['ParentId'] != "").map((comment) {
      return CommentModel.map(comment.documentID, comment.data, commentUsers, loginUserId);
    }).toList();
  }
}

class QuestionModel {
    String info;
    int no;
    String picPath;
    List<AnswerModel> answers;

    QuestionModel.map(Map<String, dynamic> map) { //, List<DocumentSnapshot> answersP
      info = map['Info'];
      no = map['No'];
      picPath = map['PicPath'] != null ? map['PicPath'] : "";

      if(map['Answers'] != null)
      {
        answers = new List<AnswerModel>();
        for(var i = 0; i < map['Answers'].length; i ++)
        {
          var answerPicPath = map['AnswerPicPaths'] != null ? map['AnswerPicPaths'][i] : "";
          var answerWeights = map['AnswerWeights'] != null ? map['AnswerWeights'][i] : "";
          answers.add(new AnswerModel(i+1, map['Answers'][i], answerPicPath, answerWeights));
        }
      }
    }
}

class CommentModel {
    String message;
    Timestamp createDate;
    String userId;
    String userName;
    List<dynamic> likedUsers;
    String parentId;
    String id;
    bool likedByTheUser;

    CommentModel.map(String documentId, Map<String, dynamic> map, List<UserModel> commentUsers, String loginUserId)
    {
      this.id = documentId;
      message = map['Message'];
      createDate = map['CreateDate'];
      userId = map['UserId'];
      likedUsers = map['LikedUsers'];
      parentId = map['ParentId'];
      var user = commentUsers.firstWhere((a) => a.userId == userId);
      userName = user.name;
      likedByTheUser = likedUsers.where((a) => a.toString() == loginUserId).length > 0;
    }
    
}

class LikeModel {
    Timestamp createTime;
    String userId;

    LikeModel.map(Map<String, dynamic> map) :
      createTime = map['CreateTime'],
      userId = map['UserId'];
    
}

class AnswerModel {
    String answer;
    int no;
    List<int> weights;
    String picPath;
    
    // AnswerModel.map(Map<String, dynamic> map) :
    //   answer = map['Answer'],
    //   no = map['No'],
    //   point = map['Point'],
    //   picPath = map['PicPath'];

    AnswerModel(int no, String answer, String picPath, String stringWeights)  {
      this.answer = answer;
      this.no = no;
      this.picPath = picPath;
      if(stringWeights == "")
        return;
      var listWeights = stringWeights.split(',');
      this.weights = new List<int>();
      listWeights.forEach((item) => this.weights.add(int.parse(item)));
      
    }
}
