import 'package:control/pages/controlList.dart';
import 'package:control/pages/instrument.dart';
import 'package:control/pages/organization.dart';
import 'package:control/pages/takePhoto.dart';

import 'package:control/pages/mainMenu.dart';
import 'package:flutter/material.dart';



Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    'mainMenu': (BuildContext context) => MainMenu(),
    'controlList': (BuildContext context) => ControlList(),
    'takePhoto': (BuildContext context) => TakePhoto(),
    'organizations': (BuildContext context) => Organization(),
    'instrument': (BuildContext context) => Instrument(),

  };
}
