// import '../helpers/color_helpers.dart';
// import '../components/demo/demo_simple_component.dart';
// import '../components/home/home_component.dart';
// import 'package:flutter/painting.dart';
import 'package:falci/MessageDetail.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:falci/Login/LoginPage.dart';
import 'package:falci/Login/SignupPage.dart';
import 'package:falci/HomePage.dart';
import 'package:falci/NewFal/NewCoffeeFal.dart';
import 'package:falci/NewFal/NewCoffeeFalSelectFalci.dart';
import 'package:falci/NewFal/NewCoffeeFalDetailAndSubmit.dart';
import 'package:falci/AuthSingleton.dart';
import 'package:falci/Falci/FalciHomePage.dart';
import 'package:falci/Falci/FalDetailForFalciPage.dart';
import 'package:falci/Point/PointListPage.dart';
import 'package:falci/FalDetailForUserPage.dart';
import 'package:falci/FalListScreen2.dart';
import 'package:falci/MessageList.dart';
import 'package:falci/Survey.dart';

var rootHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      var user = AuthSingleton.instance.user;
      if(user == null)
      {
        return LoginPage();
      }
      else if (AuthSingleton.instance.falciModel != null)
      {
        return FalciHomePage();
      }

      return HomePage2();
    }
);

var signUpHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return SignupPage();
    }
);

var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return HomePage2();
    }
);

var newFalHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return NewCoffeeFal();
    }
);

var newFalSelectFalciHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return NewCoffeeFalSelectFalci();
    }
);

var newFalSubmitHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return NewCoffeeFalDetailAndSubmit();
    }
);

var falciHomeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return FalciHomePage();
    }
);

var falDetailForFalciHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return FalDetailForFalciPage(params['falid'][0].toString());
    }
);

var falDetailForUserHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return FalDetailForUserPage(params['falid'][0].toString());
    }
);

var pointListHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return PointListPage();
    }
);

var userFalsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return FalListScreen2();
    }
);

var messageListHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return MessagesScreen();
    }
);

var messageDetailHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return MessageDetail(params['id'][0].toString());
    }
);

var surveyHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      //if(AuthSingleton.instance.user == null)
        return Survey(params['id'][0].toString());
    }
);

// var demoRouteHandler = new Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   String message = params["message"]?.first;
//   String colorHex = params["color_hex"]?.first;
//   String result = params["result"]?.first;
//   Color color = new Color(0xFFFFFFFF);
//   if (colorHex != null && colorHex.length > 0) {
//     color = Colors.blue;// new Color(ColorHelpers.fromHexString(colorHex));
//   }
//   return new DemoSimpleComponent(
//       message: message, color: color, result: result);
// });

// var demoFunctionHandler = new Handler(
//     type: HandlerType.function,
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//       String message = params["message"]?.first;
//       showDialog(
//         context: context,
//         builder: (context) {
//           return new AlertDialog(
//             title: new Text(
//               "Hey Hey!",
//               style: new TextStyle(
//                 color: const Color(0xFF00D6F7),
//                 fontFamily: "Lazer84",
//                 fontSize: 22.0,
//               ),
//             ),
//             content: new Text("$message"),
//             actions: <Widget>[
//               new Padding(
//                 padding: new EdgeInsets.only(bottom: 8.0, right: 8.0),
//                 child: new FlatButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                   child: new Text("OK"),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     });

// /// Handles deep links into the app
// /// To test on Android:
// ///
// /// `adb shell am start -W -a android.intent.action.VIEW -d "fluro://deeplink?path=/message&mesage=fluro%20rocks%21%21" com.theyakka.fluro`
// var deepLinkHandler = new Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   String colorHex = params["color_hex"]?.first;
//   String result = params["result"]?.first;
//   Color color = new Color(0xFFFFFFFF);
//   if (colorHex != null && colorHex.length > 0) {
//     color = Colors.blueGrey;// new Color(ColorHelpers.fromHexString(colorHex));
//   }
//   return new DemoSimpleComponent(
//       message: "DEEEEEP LINK!!!", color: color, result: result);
// });
