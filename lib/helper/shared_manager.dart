
import 'package:control/helper/util.dart';
import 'package:flutter/cupertino.dart';

import 'package:control/helper/constant.dart';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SharedManager {
  static final SharedManager shared = SharedManager._internal();

  factory SharedManager() {
    return shared;
  }

  SharedManager._internal();

  // bool isRTL = true;
  bool isRTL = false;
  var direction = TextDirection.ltr;
  var count = 2;
  bool isOnboarding = false;
  int currentIndex = 0;
  var fontFamilyName = "Quicksand";
  bool isOpenMessageScreen = false;
  var ipAddress = "";

  String name = "";
  String mobile = "";
  String specility = "";
  bool isDoctor = false;

  var language = Locale("en", "");
  // var language =   Locale("es", "");
  // var language =   Locale("ar", "");
  // var language =   Locale("fr", "");

  setNavigation(BuildContext context, dynamic viewScreen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => viewScreen()));
  }

  String themeType = 'light';
  ThemeData getThemeType() {
    return new ThemeData(
      brightness: _getBrightness(),
    );
  }

  Brightness _getBrightness() {
    if (themeType == "dark") {
      return Brightness.dark;
    } else {
      return Brightness.light;
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  ValueNotifier<Locale> locale = new ValueNotifier(Locale('en', ''));




  void showAlertDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Mensaje"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: new Text(message),
          actions: <Widget>[
            TextButton(
              child: new Text("Aceptar",
                  style: TextStyle(color: AppColor.themeColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
