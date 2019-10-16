import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/data/FireStoreHelper.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/main.dart';
//import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailControllerForPasswordRenewal = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

    void afterSignIn (FirebaseUser user, AuthProviderType provideType) async
    {
      if (user == null) {
        debugPrint("afterSignIn: user is null");
        return;
      }

      AuthSingleton.instance.user = user;
      //debugPrint("Email: " + user.email);

      var userModel = await FireStoreHelper.dbHelper.getUser(user.uid);
      if(userModel == null)
      {
        userModel = UserModel(
          email: user.email, 
          lastLoginDate: DateTime.now(), 
          messagingToken: AuthSingleton.instance.userMessagingToken,
          name: user.displayName,
          point: 0,
          roleType: RoleType.User.index,
          status: UserStatus.Active.index,
          userId: user.uid,
          providerType: provideType.index,
          genderType: -1,
          maritalStatusType: -1,
          birthDate: null
        );

        FireStoreHelper.dbHelper.createUser(userModel);
      }
      AuthSingleton.instance.userModel = userModel;

      if(userModel.roleType == RoleType.User.index)
      {
        if(!user.isEmailVerified && provideType == AuthProviderType.UserNameAndPassword)
        {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text("Mailinize gönderilen onay linkine tıklamanız gerekmektedir."),
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

        final container = AppComponent.of(context);
        container.updateUserPoint(newPoint: userModel.point);
        var unreadMessageCount = await FireStoreHelper.dbHelper.getUnreadMessageCount(user.uid);
        container.updateUnreadMessageCount(newMessageCount: unreadMessageCount);
        PagerSingleton.instance.router.navigateTo(context, "/home");
      }
      else if(userModel.roleType == RoleType.Falci.index)
      {
        var falciModel = await FireStoreHelper.dbHelper.getFalci(user.uid);
        AuthSingleton.instance.falciModel = falciModel;
        PagerSingleton.instance.router.navigateTo(context, "/falci/home");
      }

      if(userModel.messagingToken != AuthSingleton.instance.userMessagingToken)
      {
        userModel.messagingToken = AuthSingleton.instance.userMessagingToken;
        await FireStoreHelper.dbHelper.updateMessagingToken(userModel.userId, userModel.messagingToken);
      }
    }

    void _signInWithEmailAndPassword() async {
      var user = await AuthSingleton.instance.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
      await afterSignIn(user, AuthProviderType.UserNameAndPassword);
    }

    void _loginFacebook() async {
      var user;
      try {
        user = await AuthSingleton.instance.loginWithFacebook();
      }
      catch(ex)
      {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text(ex.message),
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
      await afterSignIn(user, AuthProviderType.Facebook);
    }

    void _loginTwitter() async {
      var user;
      try {
      user = await AuthSingleton.instance.loginWithTwitter();
      }
      catch(ex)
      {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text(ex.message),
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
      await afterSignIn(user, AuthProviderType.Twitter);
    }

    void _signInWithGoogle() async {
      var user;
      try {
        user = await AuthSingleton.instance.signInWithGoogle();
      }
      catch(ex)
      {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                //title: Text(""),
                content: Text(ex.message),
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
      await afterSignIn(user, AuthProviderType.Google);
    }

    return new Material(
      child:
        new Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.05), BlendMode.dstATop),
              image: AssetImage('assets/images/mountains.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: new Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(50.0),
                child: Center(
                  child: Text('Falcı', style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),)
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
                height: 24.0,
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
                height: 24.0,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right:85.0),
                    child: new FlatButton(
                      child: new Text(
                        "Kaydol",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      onPressed: () => {

                        //AuthSingleton.instance.auth.sendPasswordResetEmail(email: "mestal@gmail.com")
                        PagerSingleton.instance.router.navigateTo(context, "/signup")
                        
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: new FlatButton(
                      child: new Text(
                        "Şifremi unuttum?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      onPressed: () => {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("E-mail adresinizi giriniz."),
                              content: 
                                  TextField(
                                    controller: _emailControllerForPasswordRenewal,
                                    //obscureText: true,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                      hintText: '',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("Gönder"),
                                  onPressed: () async {
                                    await AuthSingleton.instance.auth.sendPasswordResetEmail(
                                      email: _emailControllerForPasswordRenewal.text
                                    );
                                    Navigator.of(context).pop();
                                  },
                                )
                              ]
                            );
                          }
                        )
                      },
                    ),
                  ),
                ],
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
                          //if (_formKey.currentState.validate()) {
                            _signInWithEmailAndPassword();
                            //AuthSingleton.instance.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
                          //}
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
                                  "Giriş",
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
              new Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(border: Border.all(width: 0.25)),
                      ),
                    ),
                    Text(
                      "ya da şununla giriş yap",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    new Expanded(
                      child: new Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(border: Border.all(width: 0.25)),
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded( //Facebook
                      child: new Container(
                        margin: EdgeInsets.only(right: 8.0),
                        alignment: Alignment.center,
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new FlatButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                color: Color(0Xff3B5998),
                                onPressed: () => { },
                                child: new Container(
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Expanded(
                                        child: new FlatButton(
                                          onPressed: ()=> _loginFacebook() ,
                                          padding: EdgeInsets.only(
                                            top: 20.0,
                                            bottom: 20.0,
                                          ),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Icon(
                                                const IconData(0xea90,
                                                    fontFamily: 'icomoon'),
                                                color: Colors.white,
                                                size: 15.0,
                                              ),
                                            ],
                                          ),
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
                    ),
                    new Expanded( //Google
                      child: new Container(
                        margin: EdgeInsets.only(left: 8.0),
                        alignment: Alignment.center,
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new FlatButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                color: Color(0Xffdb3236),
                                onPressed: () => {},
                                child: new Container(
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Expanded(
                                        child: new FlatButton(
                                          onPressed: ()=>{ _signInWithGoogle() },
                                          padding: EdgeInsets.only(
                                            top: 20.0,
                                            bottom: 20.0,
                                          ),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Icon(
                                                const IconData(0xea88,
                                                    fontFamily: 'icomoon'),
                                                color: Colors.white,
                                                size: 15.0,
                                              ),
                                            ],
                                          ),
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
                    ),
                    new Expanded( //Twitter
                      child: new Container(
                        margin: EdgeInsets.only(left: 8.0),
                        alignment: Alignment.center,
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new FlatButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                color: Color(0Xff00aced), //alpha, r, g, b
                                onPressed: () => {},
                                child: new Container(
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Expanded(
                                        child: new FlatButton(
                                          onPressed: ()=>{
                                            _loginTwitter()
                                          },
                                          padding: EdgeInsets.only(
                                            top: 20.0,
                                            bottom: 20.0,
                                          ),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Icon(
                                                const IconData(0xea96,
                                                    fontFamily: 'icomoon'),
                                                color: Colors.white,
                                                size: 15.0,
                                              ),
                                            ],
                                          ),
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
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
    //);
  }
}
