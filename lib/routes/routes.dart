import 'package:control/pages/controlList.dart';
import 'package:control/pages/dashboard/dashboard.dart';
import 'package:control/pages/instrument.dart';
import 'package:control/pages/sendData.dart';
import 'package:control/pages/showOrganization.dart';
import 'package:control/pages/selectMode.dart';
import 'package:control/pages/takePhoto.dart';

import 'package:control/pages/mainMenu.dart';
import 'package:control/pages/variable.dart';
import 'package:flutter/material.dart';

import '../pages/showRevision.dart';



Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    'dashboard': (BuildContext context) => DashboardPage(),
    'mainMenu': (BuildContext context) => MainMenu(),
    'controlList': (BuildContext context) => ControlList(),
    'takePhoto': (BuildContext context) => TakePhoto(),
    'organizations': (BuildContext context) => ShowOrganization(),
    'instrument': (BuildContext context) => Instrument(),
    'selectMode': (BuildContext context) => SelectMode(),
    'variable': (BuildContext context) => Variable(),
    'showRevision': (BuildContext context) => ShowRevision(),
    'sendData': (BuildContext context) => SendData(),

  };
}
