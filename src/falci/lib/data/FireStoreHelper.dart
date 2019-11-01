import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:falci/data/models/FalModel.dart';

class FireStoreHelper {
  Firestore _db = Firestore.instance;
  final String tbName = "movies";
  final String autoIncrementId = "autoIncrementId";
  final String id = "id";
  final String name = "name";
  final String poster = "poster";
  final String backdrop = "backdrop";
  final String desc = "desc";
  final String tag = "tag";

  static final FireStoreHelper dbHelper = new FireStoreHelper._helper();

  factory FireStoreHelper() {
    return dbHelper;
  }

  FireStoreHelper._helper() {
    print("opening");
    //_open(new DbPath().path);
  }

  Future<bool> createFal(FalCreateModel model) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(_db.collection('Fal').document());
  
      var dataMap = new Map<String, dynamic>();
      dataMap['CreateDate'] = model.createDate;
      dataMap['DetailType'] = model.detailType;
      dataMap['PointSpent'] = model.pointSpent;
      dataMap['Status'] = 0;
      dataMap['SubmitDateByUser'] = model.submitDate;
      dataMap['Type'] = model.type;
      dataMap['UserId'] = model.userId;
      dataMap['FortuneTellerUserId'] = model.fortuneTellerUserId;
      dataMap['Images'] = model.images;
      dataMap['Id'] = model.id;
  
      await tx.set(ds.reference, dataMap);
      debugPrint("Finished");
      return dataMap;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
        return true;
      }).catchError((error) {
        print('error: $error');
        return false;
      });
  }

  Future<bool> submitFalComment(SubmitFalCommentModel model) async {
    final DocumentSnapshot dsFal = await _db.document('Fal/' + model.id).get();
 
    var dataMap = new Map<String, dynamic>();
    dataMap['Status'] = model.status;
    dataMap['SubmitDateByFalci'] = model.submitDateByFalci;
    dataMap['Fal'] = model.fal;
    dataMap['Id'] = model.id;

    dataMap['CreateDate'] = dsFal.data['CreateDate'];
    dataMap['DetailType'] = dsFal.data['DetailType'];
    dataMap['PointSpent'] = dsFal.data['PointSpent'];
    dataMap['SubmitDateByUser'] = dsFal.data['SubmitDateByUser'];
    dataMap['Type'] = dsFal.data['Type'];
    dataMap['UserId'] = dsFal.data['UserId'];
    dataMap['UserName'] = dsFal.data['UserName'];
    dataMap['FortuneTellerUserId'] = dsFal.data['FortuneTellerUserId'];
    dataMap['Images'] = dsFal.data['Images'];

    //await tx.set(ds.reference, dataMap);
    //await tx.update(dsFal.reference, dataMap);
    debugPrint("Finished");

    await _db.document('Fal/' + model.id).updateData(dataMap);

    return true;
  }

  Future<bool> createUser(UserModel model) async {
      var dataMap = new Map<String, dynamic>();
      dataMap['UserId'] = model.userId;
      dataMap['Name'] = model.name;
      dataMap['Point'] = model.point;
      dataMap['Status'] = model.status;
      dataMap['RoleType'] = model.roleType;
      dataMap['Email'] = model.email;
      dataMap['MessagingToken'] = model.messagingToken;
      dataMap['ProviderType'] = model.providerType;
  
      await _db.document('User/' + model.userId).setData(dataMap);

      return true;
  }

  Future<int> createFalAndUpdatePoint(FalCreateModel model) async {
    var dsFal = _db.collection("Fal").document();
    var dsUser = _db.collection('User').document(model.userId);
    var userData = await dsUser.get();
    int newPoint;

      var dataMap = new Map<String, dynamic>();
      dataMap['CreateDate'] = model.createDate;
      dataMap['DetailType'] = model.detailType;
      dataMap['PointSpent'] = model.pointSpent;
      dataMap['Status'] = model.status;
      dataMap['SubmitDateByUser'] = model.submitDate;
      dataMap['Type'] = model.type;
      dataMap['UserId'] = model.userId;
      dataMap['UserName'] = model.userName;
      dataMap['FortuneTellerUserId'] = model.fortuneTellerUserId;
      dataMap['Images'] = model.images;
      dataMap['Id'] = model.id;
      dataMap['BirthDate'] = model.birthDate;
      dataMap['Gender'] = model.genderType;
      dataMap['MaritalStatus'] = model.maritalStatusType;
      dataMap['UserDisplayNameForFal'] = model.userDisplayNameForFal;
      dsFal.setData(dataMap);

      var user = UserModel.map(userData.data);
  
      var dataMapForUser = new Map<String, dynamic>();
      newPoint = user.point - model.pointSpent;;
      dataMapForUser['Point'] = newPoint;

      await dsUser.updateData(dataMapForUser);

    // await _db.runTransaction((Transaction tx) async {

    //   var dataMap = new Map<String, dynamic>();
    //   dataMap['CreateDate'] = model.createDate;
    //   dataMap['DetailType'] = model.detailType;
    //   dataMap['PointSpent'] = model.pointSpent;
    //   dataMap['Status'] = model.status;
    //   dataMap['SubmitDateByUser'] = model.submitDate;
    //   dataMap['Type'] = model.type;
    //   dataMap['UserId'] = model.userId;
    //   dataMap['UserName'] = model.userName;
    //   dataMap['FortuneTellerUserId'] = model.fortuneTellerUserId;
    //   dataMap['Images'] = model.images;
    //   dataMap['Id'] = model.id;
    //   dataMap['BirthDate'] = model.birthDate;
    //   dataMap['Gender'] = model.genderType;
    //   dataMap['MaritalStatus'] = model.maritalStatusType;
    //   dataMap['UserDisplayNameForFal'] = model.userDisplayNameForFal;
  
    //   await tx.set(dsFal, dataMap);
    //   debugPrint("Finished");

    //   var user = UserModel.map(userData.data);
  
    //   var dataMapForUser = new Map<String, dynamic>();
    //   newPoint = user.point - model.pointSpent;;
    //   dataMapForUser['Point'] = newPoint;

    //   await tx.update(dsUser, dataMapForUser);

    // });

    return newPoint;
  }

  Future<int> increasePoint(String userId,  int point) async {
    var dsUser = _db.collection('User').document(userId);
    var userData = await dsUser.get();
    var user = UserModel.map(userData.data);
    var newTotalPoint;
    newTotalPoint = user.point + point;
    var dataMapForUser = new Map<String, dynamic>();
    dataMapForUser['Point'] = newTotalPoint;
    dsUser.updateData(dataMapForUser);

    // await _db.runTransaction((Transaction tx) async {
    //   var dataMapForUser = new Map<String, dynamic>();
    //   newTotalPoint = user.point + point;
    //   dataMapForUser['Point'] = newTotalPoint;
    //   await tx.update(dsUser, dataMapForUser);
    // });

    return newTotalPoint;
  }

  Future updateMessagingToken(String userId,  String messagingToken) async {
    var dsUser = _db.collection('User').document(userId);

    var dataMapForUser = new Map<String, dynamic>();
    dataMapForUser['MessagingToken'] = messagingToken;
    dsUser.updateData(dataMapForUser);

    // String message = "";
    // try {
    //   await _db.runTransaction((Transaction tx) async {

    //     var dataMapForUser = new Map<String, dynamic>();
    //     dataMapForUser['MessagingToken'] = messagingToken;

    //     await tx.update(dsUser, dataMapForUser);

    //   });
    // }
    // catch(ex)
    // {
    //   message = ex.toString();
    // }

  }

  Future updateUserProfile(String userId,  String name, int genderType, int maritalStatus, Timestamp birthDate) async {
    var dsUser = _db.collection('User').document(userId);

    var dataMapForUser = new Map<String, dynamic>();
    dataMapForUser['Name'] = name;
    dataMapForUser['BirthDate'] = birthDate;
    dataMapForUser['MaritalStatus'] = maritalStatus;
    dataMapForUser['Gender'] = genderType;
    dsUser.updateData(dataMapForUser);

    // await _db.runTransaction((Transaction tx) async {

    //   var dataMapForUser = new Map<String, dynamic>();
    //   dataMapForUser['Name'] = name;
    //   dataMapForUser['BirthDate'] = birthDate;
    //   dataMapForUser['MaritalStatus'] = maritalStatus;
    //   dataMapForUser['Gender'] = genderType;

    //   await tx.update(dsUser, dataMapForUser);

    // });

  }

  Future updateMessageAsRed(String messageId) async {
    var dsUser = _db.collection('Message').document(messageId);

    var dataMapForMessage = new Map<String, dynamic>();
    dataMapForMessage['Status'] = 1;
    dataMapForMessage['ReadTime'] = Timestamp.fromDate(DateTime.now());
    dsUser.updateData(dataMapForMessage);

    // await _db.runTransaction((Transaction tx) async {

    //   var dataMapForUser = new Map<String, dynamic>();
    //   dataMapForUser['Name'] = name;
    //   dataMapForUser['BirthDate'] = birthDate;
    //   dataMapForUser['MaritalStatus'] = maritalStatus;
    //   dataMapForUser['Gender'] = genderType;

    //   await tx.update(dsUser, dataMapForUser);

    // });

  }


  Future<UserModel> getUser(String userId) async
  {
    var document = await _db.collection('User').document(userId).get();

    if(document.data == null)
      return null;
      
    var userModel = new UserModel.map(document.data);
    return userModel;
  }

  Future<FalciModel> getFalci(String userId) async
  {
    var document = await _db.collection('Falci').document(userId).get();
    var falciModel = new FalciModel.map(document.data);
    return falciModel;
  }

  Future<FalListModel> getFalDetail(String id) async
  {
    var document = await _db.collection('Fal').document(id).get();
    var falModel = new FalListModel.map(document.data);
    return falModel;
  }

  Future<int> getUnreadMessageCount(String userId) async
  {
    var messageCount = await _db.collection('Message')
                    .where('Status', isEqualTo: 0)
                    .where('ToUserId', isEqualTo: userId).getDocuments();

            
    return messageCount.documents.length;
  }

  // Future<List<FalListModel>> listFal() async {
  //   var snapShots = _db.collection('Fal').where("UserId", isEqualTo: "123").snapshots();

  //   var result = List<FalListModel>();

  //   var list = snapShots.map((obj) => new FalListModel.map(obj)).toList();

  //   snapShots.forEach((value) 
  //     { 
  //       Fal
  //       FalListModel item = Fal.map(value);
  //       result.Add(item);
  //     }
  //   );

  //     List data = res['results'];
  //     return data.map((obj) => new Movie.map(obj)).toList();

  //   return result;
  // }

  Future likeUnlikeSurveyComment(String surveyId, String commentId, bool likeOrUnlike, String userId) async {
    var dsComment = _db.collection('News').document(surveyId).collection('Comments').document(commentId);
    var comment = await dsComment.get();
    
    var likedUsers = comment.data['LikedUsers'].toList();
    if(likeOrUnlike)
    {
      if(likedUsers.contains(userId))
      {
        return;
      }

      likedUsers.add(userId);
      var dataMapForMessage = new Map<String, dynamic>();
      dataMapForMessage['LikedUsers'] = likedUsers;
      dsComment.updateData(dataMapForMessage);
    }
    else
    {
      if(!likedUsers.contains(userId))
      {
        return;
      }

      likedUsers.remove(userId);
      var dataMapForMessage = new Map<String, dynamic>();
      dataMapForMessage['LikedUsers'] = likedUsers;
      dsComment.updateData(dataMapForMessage);
    }
  }

  Future AddSurveyComment(String surveyId, String message, String parentId, String userId) async {
    var dsComment = _db.collection('News').document(surveyId).collection('Comments').document();
    
    var dataMap = new Map<String, dynamic>();
    dataMap['CreateDate'] = Timestamp.fromDate(DateTime.now());
    dataMap['Message'] = message;
    dataMap['UserId'] = userId;
    dataMap['ParentId'] = parentId;
    dataMap['LikedUsers'] = new List<String>();
    dsComment.setData(dataMap);
    
  }
}