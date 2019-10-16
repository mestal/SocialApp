import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:falci/main.dart';
import 'package:date_format/date_format.dart';
import 'package:falci/ColorLoader.dart';

class NewCoffeeFalDetailAndSubmit extends StatefulWidget {

  PageController pageController;
  FalListModel falModel;

  NewCoffeeFalDetailAndSubmit({this.pageController});

  @override
  State createState() => new NewCoffeeFalDetailAndSubmitState(pageController: pageController);
}

class NewCoffeeFalDetailAndSubmitState extends State<NewCoffeeFalDetailAndSubmit> {
  bool _sendingFal = false;
  PageController pageController;
  TextEditingController _displayUserNameForFalController = TextEditingController();
  Timestamp _birthDate;
  FalListModel falModel;
  NewCoffeeFalDetailAndSubmitState({this.pageController});
  int _currentIssue;
  int _currentGender;
  int _currentMaritalStatus;
  bool _saveProfile;

  @override
  void initState() {
    _dropDownMenuItemsForFalIssues = getDropDownMenuItemsForFalIssues();
    _dropDownMenuItemsForGenders = getDropDownMenuItemsForGenders();
    _dropDownMenuItemsForMaritalStatuses = getDropDownMenuItemsForMaritalStatuses();

    _currentMaritalStatus = AuthSingleton.instance.userModel.maritalStatusType;
    _currentIssue = _dropDownMenuItemsForFalIssues[0].value;
    _currentGender = AuthSingleton.instance.userModel.genderType;
    _birthDate = AuthSingleton.instance.userModel.birthDate;
    _saveProfile = true;
    _displayUserNameForFalController.text = AuthSingleton.instance.userModel.name;
    super.initState();
  }

  List<DropdownMenuItem<int>> getDropDownMenuItemsForFalIssues() {
    List<DropdownMenuItem<int>> items = new List();
    items.add(new DropdownMenuItem(
          value: -1,
          child: new Text('Seçiniz')
      ));
    for (var item in FalIssue.values) {
      items.add(new DropdownMenuItem(
          value: item.index,
          child: new Text(EnumOperations.getFalIssueDescription(item.index))
      ));
    }
    return items;
  }

  List<DropdownMenuItem<int>> getDropDownMenuItemsForGenders() {
    List<DropdownMenuItem<int>> items = new List();
    items.add(new DropdownMenuItem(
          value: -1,
          child: new Text('Seçiniz')
      ));
    for (var item in GenderType.values) {
      items.add(new DropdownMenuItem(
          value: item.index,
          child: new Text(EnumOperations.getGenderDescription(item.index)
      )));
    }

    return items;
  }

  List<DropdownMenuItem<int>> getDropDownMenuItemsForMaritalStatuses() {
    List<DropdownMenuItem<int>> items = new List();
    items.add(new DropdownMenuItem(
          value: -1,
          child: new Text('Seçiniz')
      ));
    for (var item in MaritalStatus.values) {
      items.add(new DropdownMenuItem(
          value: item.index,
          child: new Text(EnumOperations.getMaritalStatusDescription(item.index))
      ));
    }
    return items;
  }

  List<DropdownMenuItem<int>> _dropDownMenuItemsForFalIssues;

  List<DropdownMenuItem<int>> _dropDownMenuItemsForGenders;

  List<DropdownMenuItem<int>> _dropDownMenuItemsForMaritalStatuses;

  bool Validation(FalCreateModel fal) {

    var errorMessage;
    if(AuthSingleton.instance.userModel.point < fal.pointSpent)
    {
      errorMessage = "Puanınız yetersiz. Lütfen önce puan satın alınız.";
    }
    else if(_currentIssue == -1)
    {
      errorMessage = 'Fal konusu seçiniz.';
    }
    else if(_displayUserNameForFalController.text == null || _displayUserNameForFalController.text.length < 3)
    {
      errorMessage = 'İsim giriniz';
    }
    else if(_displayUserNameForFalController.text.length > 150)
    {
      errorMessage = 'İsim 150 karakteri geçemez.';
    }
    else if(_birthDate == null)
    {
      errorMessage = 'Doğum Tarihi giriniz.';
    }
    else if(_currentGender == -1)
    {
      errorMessage = 'Cinsiyet seçiniz.';
    }
    else if(_currentMaritalStatus == -1)
    {
      errorMessage = 'Medeni durum seçiniz.';
    }

    if(errorMessage != null)
    {
      setState(() {
        _sendingFal = false;  
      });
      
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              //title: Text(""),
              content: Text(errorMessage),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Kapat"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ]
            );
          }
        );
        return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {

    void _send() async {
      setState(() {
        _sendingFal = true;  
      });

      var fal = PagerSingleton.instance.newFal;

      var result = Validation(fal);

      if(!result)
        return;

      var uuid = new Uuid();
      
      fal.type = FalType.Coffee.index;
      fal.detailType = _currentIssue;
      fal.userId = AuthSingleton.instance.user.uid;
      fal.submitDate = DateTime.now();
      fal.status = FalStatus.SentByUser.index;
      fal.id = uuid.v4();
      fal.userName = AuthSingleton.instance.userModel.name;
      fal.maritalStatusType = _currentMaritalStatus;
      fal.userDisplayNameForFal = _displayUserNameForFalController.text;
      fal.genderType = _currentGender;
      fal.birthDate = _birthDate;

      //1 - Send Images To the Storage

      // if(fal.images.length == 0)
      // {
      //   return;
      // }

      //fal.images = ["/data/user/0/com.mestal.falci/app_flutter/Pictures/flutter_test/1556572329987.jpg"];

      var i = 0;
      for (var image in fal.images)
      {
        var imagePath = image;
        image = "fallar/" + fal.userId + "_" + fal.submitDate.toString() + "_" + uuid.v4() + ".jpg";

        fal.images[i] = image;
        final StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child(image);
        final StorageUploadTask task =
            firebaseStorageRef.putFile(new File(imagePath));

        await task.onComplete;
        i++;
      }

      //2 - Puan düş ve Create Fal

      FireStoreHelper.dbHelper.createFalAndUpdatePoint(PagerSingleton.instance.newFal).then((newPoint) async{
        
        final container = AppComponent.of(context);
        container.updateUserPoint(newPoint: newPoint);

        if(_saveProfile)
        {
          await FireStoreHelper.dbHelper.updateUserProfile(fal.userId, 
            fal.userDisplayNameForFal, 
            fal.genderType, 
            fal.maritalStatusType,
            fal.birthDate);

          AuthSingleton.instance.userModel.birthDate = fal.birthDate;
          AuthSingleton.instance.userModel.name = fal.userDisplayNameForFal;
          AuthSingleton.instance.userModel.genderType = fal.genderType;
          AuthSingleton.instance.userModel.maritalStatusType = fal.maritalStatusType;
        }

        setState(() {
          _sendingFal = false;  
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              //title: Text(""),
              content: Text("Gönderildi"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Kapat"),
                  onPressed: () {
                    //Navigator.of(context).pop();
                    PagerSingleton.instance.router.navigateTo(context, "/home");
                  },
                )
              ]
            );
          }
        );
      });

    }

    void changedFalIssueDropDownItem(int selectedIssue) {
      setState(() {
        _currentIssue = selectedIssue;
      });
    }

    void changedGenderDropDownItem(int selectedIssue) {
      setState(() {
        _currentGender = selectedIssue;
      });
    }

    void changedMaritalStatusDropDownItem(int selectedIssue) {
      setState(() {
        _currentMaritalStatus = selectedIssue;
      });
    }

    void changedSaveProfile(bool newVal)
    {
      setState(() {
          _saveProfile = newVal;
      });
    }

    void onTapBirthDate() async
    {
       var takenDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

      var takenDateTimestamp = Timestamp.fromDate(takenDateTime);

      if(takenDateTimestamp != null)
      {
        setState(() {
          _birthDate = takenDateTimestamp;
        });
      }
    }

    return Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gönder'),
      ),
      body: _sendingFal == true ? Container(

        child: Center(child: 
          ColorLoader(
              radius: 20.0,
              dotRadius: 5.0,
            ),
            //ColorLoader2(),
          )
        ) :
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
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Fal Konusu",
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
                    child: new DropdownButton(
                      value: _currentIssue,
                      items: _dropDownMenuItemsForFalIssues,
                      onChanged: changedFalIssueDropDownItem,
                    )
                  ),
                ],
              ),
            ),
            Divider(
              height: 5.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "İsim",
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
              height: 5.0,
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
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
                    child: new TextField(
                      controller: _displayUserNameForFalController,
                    )
                  ),
                ],
              ),
            ),
            Divider(
              height: 5.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Doğum Tarihi",
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
              height: 25.0,
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
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
                  Container(child:
                    GestureDetector(
                      onTap:()=> onTapBirthDate(),
                      child:AbsorbPointer(
                        child: Container(child:Text(_birthDate == null ? 'GG-AA-YYYY' : formatDate(_birthDate.toDate(), [dd, '-', mm, '-', yyyy]))),//Container(child: TextField()),
                      )
                    )
                    // child: new TextField(
                    //   onTap: onTapBirthDate,
                    // )
                  )
                ],
              ),
            ),
            Divider(
              height: 25.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Cinsiyet",
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
                    child: new DropdownButton(
                      value: _currentGender,
                      items: _dropDownMenuItemsForGenders,
                      onChanged: changedGenderDropDownItem,
                    )
                  ),
                ],
              ),
            ),
            Divider(
              height: 5.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Medeni durum",
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
                    child: new DropdownButton(
                      value: _currentMaritalStatus,
                      items: _dropDownMenuItemsForMaritalStatuses,
                      onChanged: changedMaritalStatusDropDownItem,
                    )
                  ),
                ],
              ),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Profilimi güncelle",
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
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Checkbox(value: _saveProfile, onChanged: changedSaveProfile,),
                  ),
                ),
              ],
            ),
            Divider(
              height: 15.0,
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
              alignment: Alignment.center,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new FlatButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Colors.redAccent,
                      onPressed: () => _send(),
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
            Divider(
              height: 40.0,
            ),
          ],
        ),
      )
    );
  }
}