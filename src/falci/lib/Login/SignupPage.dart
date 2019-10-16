  import 'package:flutter/material.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:falci/data/models/FalModel.dart';

class SignupPage extends StatefulWidget {
  @override
  State createState() {
    return new SignupState();
  }
}

class SignupState extends State<SignupPage> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    void _register() async {
        var name = _nameController.text;
        var email = _emailController.text;
        var password = _passwordController.text;
        var passwordConfirmation = _passwordConfirmController.text;

        var errorMessage;
        if(password == null || password.length < 6)
        {
          errorMessage = "Şifre en az 6 karakter olmalıdır.";
        }
        else if(password != passwordConfirmation)
        {
          errorMessage = "Şifre aynı değil.";
        }
        else if(name == null || name.length < 3)
        {
          errorMessage = 'İsim giriniz.';
        }
        else if(email == null || email.length < 3)
        {
          //TODO : email check
          errorMessage = 'Doğru bir E-mail giriniz.';
        }

        if(errorMessage != null)
        {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text("Şifre aynı değil."),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Kapat"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ]
              );
            }
          );
          return;
        }

        var user;
        try {
          user = await AuthSingleton.instance.createUserWithEmailAndPassword(email, password);
        }
        catch(ex)
        {
          var errorMessage = '';
          if(ex.code == 'ERROR_EMAIL_ALREADY_IN_USE')
          {
            errorMessage = 'Bu e-mail adresi başka bir hesapta kullanılmaktadır.';
          }
          else if (ex.message != null && ex.message != '')
          {
            errorMessage = ex.message;
          }
          else
          {
            errorMessage = ex.toString();
          }
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
                      Navigator.of(context).pop();
                    },
                  )
                ]
              );
            }
          );

          return;
        }

        if (user != null) {
          var userModel = UserModel(
            email: user.email,
            name: user.displayName != null ? user.displayName : null,
            point: 0,
            roleType: RoleType.User.index,
            status: UserStatus.Active.index,
            userId: user.uid,
            providerType: AuthProviderType.UserNameAndPassword.index,
            genderType: -1,
            birthDate: null,
            maritalStatusType: -1,

          );
          FireStoreHelper.dbHelper.createUser(userModel);
          PagerSingleton.instance.router.navigateTo(context, "/");
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text("Hata"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Kapat"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ]
              );
            }
          );
        }
    }

    return new Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gönder'),
      ),
          body: SingleChildScrollView(
        child: new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: new Text(
                    "Falcı",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 15.0,
                    ),
                  ),
              
              // Icon(
              //   Icons.headset_mic,
              //   color: Colors.redAccent,
              //   size: 50.0,
              // ),
            ),
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
                    controller: _nameController,
                    //obscureText: true,
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
          Divider(
            height: 15.0,
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: new Text(
                    "E-mail",
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
                    controller: _emailController,
                    //obscureText: true,
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
          Divider(
            height: 15.0,
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: new Text(
                    "Şifre",
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
                    controller: _passwordController,
                    obscureText: true,
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
          Divider(
            height: 15.0,
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: new Text(
                    "Şifre (Tekrar)",
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
                    controller: _passwordConfirmController,
                    obscureText: true,
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
          Divider(
            height: 5.0,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: new FlatButton(
                  child: new Text(
                    "Zaten bir hesabım var?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  onPressed: () => {
                    Navigator.of(context).pop()
                  },
                ),
              ),
            ],
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5.0),
            alignment: Alignment.center,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new FlatButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    color: Colors.redAccent,
                    onPressed: () => _register(),
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
                              "Kaydol",
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
            height: 24.0,
          ),
        ],
      ),
    )
          
    );
  }
}
