import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:falci/data/FirestoreHelper.dart';
import 'package:falci/Configurations.dart';
// import 'package:flutter_twitter_login/flutter_twitter_login.dart';

class AuthSingleton {
  static final AuthSingleton instance = new AuthSingleton._internal();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = new FacebookLogin();
  final TwitterLogin _twitterLogin = new TwitterLogin(consumerKey: Configurations.Twitter_ConsumerKey, consumerSecret: Configurations.Twitter_ConsumerSecret);
  FirebaseUser user;
  UserModel userModel;
  FalciModel falciModel;
  String userMessagingToken;
  int unreadMessageCount;

  factory AuthSingleton() {
    return instance;
  }

  AuthSingleton._internal()
  {

  }

  void SetUser(FirebaseUser user) async
  {
    if(user == null)
      user = await AuthSingleton.instance.auth.currentUser();

    AuthSingleton.instance.user = user;
    if(user != null)
    {
      var userModel = await FireStoreHelper.dbHelper.getUser(user.uid);

      if(userModel == null || (!user.isEmailVerified && userModel.providerType == AuthProviderType.UserNameAndPassword.index))
      {
        AuthSingleton.instance.user = null;
        await AuthSingleton.instance.auth.signOut();
        return;
      }
      
      AuthSingleton.instance.userModel = userModel;
      unreadMessageCount = await FireStoreHelper.dbHelper.getUnreadMessageCount(userModel.userId);

      if(userModel.roleType == RoleType.Falci.index)
      {
        var falciModel = await FireStoreHelper.dbHelper.getFalci(user.uid);
        AuthSingleton.instance.falciModel = falciModel;
      }
    }
  }

  Future<FirebaseUser> createUserWithEmailAndPassword(String email, String password) async {
    var user = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
    await user.sendEmailVerification();

    return user;      
  }

  signOut() async
  {
      await FireStoreHelper.dbHelper.updateMessagingToken(user.uid, "");

      await auth.signOut().then((_){
        //Navigator.of(context).pushNamedAndRemoveUntil("/login", ModalRoute.withName("/home"));

                // final String uid = user.uid;
                // Scaffold.of(context).showSnackBar(SnackBar(
                //   content: Text(uid + ' has successfully signed out.'),
                // ));


      });

      await _googleSignIn.signOut();
      await _facebookLogin.logOut();
      await _twitterLogin.logOut();
      user = null;
  }

  Future<FirebaseUser> loginWithFacebook() async {
    var result = await _facebookLogin.logInWithReadPermissions(['public_profile']);//['email']

    debugPrint("Facebook Status: " + result.status.toString());
    if(result.status == FacebookLoginStatus.error)
    {
      throw Exception('Facebook Error: ' + result.errorMessage);
      debugPrint("Error message: " + result.errorMessage);
    }

    if(result.status == FacebookLoginStatus.loggedIn)
    {
      var credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
      user = await auth.signInWithCredential(credential);
      return user;
    }

    return null;
  }

  Future<FirebaseUser> loginWithTwitter() async {
    var result = await _twitterLogin.authorize();

    debugPrint("Twitter Status: " + result.status.toString());
    if(result.status == TwitterLoginStatus.error)
    {
      throw Exception('Twitter Error: ' + result.errorMessage);
      debugPrint("Error message: " + result.errorMessage);
    }

    if(result.status == TwitterLoginStatus.loggedIn)
    {
      var credential = TwitterAuthProvider.getCredential(authToken: result.session.token, authTokenSecret: result.session.secret);
      user = await auth.signInWithCredential(credential);
      return user;
    }

    return null;
  }

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await auth.signInWithCredential(credential);
    // assert(user.email != null);
    // assert(user.displayName != null);
    // assert(!user.isAnonymous);
    // assert(await user.getIdToken() != null);

    return user;

    // final FirebaseUser currentUser = await _auth.currentUser();
    //assert(user.uid == currentUser.uid);
    // setState(() {
    //   if (user != null) {
    //     debugPrint("Email: " + user.email);
    //     //_success = true;
    //     //_userID = user.uid;

    //     Navigator.push(context, MaterialPageRoute(
    //       builder: (context) => HomePage()
    //     ));

    //   } else {
    //     debugPrint("_success = false");
    //     //_success = false;
    //   }
    // });
  }

  Future<FirebaseUser> signInWithEmailAndPassword(String email, String password) async {
    user = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (user != null) {
      debugPrint("_signInWithEmailAndPassword Success: true");
    } else {
      // _success = false;
      debugPrint("_signInWithEmailAndPassword Success: false");
    }
    await SetUser(user);

    return user;
  }
}