/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2018 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './route_handlers.dart';

class Routes {
  static String root = "/";
  static String home = "/home";
  static String userFals = "/user/fals";
  static String signup = "/signup";
  static String newFal = "/newfal";
  static String newFalSelectFalci = "/newfalselectfalci";
  static String newFalSubmit = "/newfalsubmit";
  static String falciHome = "/falci/home";
  static String falDetailForFalci = "/falci/faldetail/:falid";
  static String falDetailForUser = "/user/faldetail/:falid";
  static String pointList = "/pointlist";
  static String messages = "/messages";
  static String messageDetail = "/messagedetail/:id";
  static String survey = "/survey/:id";

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root, handler: rootHandler);
    router.define(signup, handler: signUpHandler);
    router.define(home, handler: homeHandler);
    router.define(newFal, handler: newFalHandler);
    router.define(newFalSelectFalci, handler: newFalSelectFalciHandler);
    router.define(newFalSubmit, handler: newFalSubmitHandler);
    router.define(falciHome, handler: falciHomeHandler);
    router.define(falDetailForFalci, handler: falDetailForFalciHandler);
    router.define(falDetailForUser, handler: falDetailForUserHandler);
    router.define(pointList, handler: pointListHandler);
    router.define(userFals, handler: userFalsHandler);
    router.define(messages, handler: messageListHandler);
    router.define(messageDetail, handler: messageDetailHandler);
    router.define(survey, handler: surveyHandler);

    // router.define(demoSimple, handler: demoRouteHandler);
    // router.define(demoSimpleFixedTrans,
    //     handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(demoFunc, handler: demoFunctionHandler);
    // router.define(deepLink, handler: deepLinkHandler);
  }
}
