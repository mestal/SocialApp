import 'package:flutter/material.dart';
import 'package:falci/data/models/FalModel.dart';
import 'package:fluro/fluro.dart';

class PagerSingleton {
  static final PagerSingleton instance = new PagerSingleton._internal();

  factory PagerSingleton() {
    return instance;
  }

  PageController pageController;
  Widget loginPage;
  Widget signupPage;
  Widget homePage;
  Widget newCoffeeFal;
  Widget newCoffeeFalSelectFalci;
  Widget newCoffeeFalDetailAndSubmit;

  Router router;

  FalCreateModel newFal;

  createNewFal()
  {
    newFal = new FalCreateModel();
    newFal.createDate = DateTime.now();
    newFal.images = new List<String>();
  }

  PagerSingleton._internal()
  {

  }
}