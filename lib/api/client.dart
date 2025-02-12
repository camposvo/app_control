import 'dart:async';
import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';





class _Clients {

  String getPrettyJSONString(Object jsonObject) {
    dynamic result = JsonEncoder.withIndent('  ').convert(jsonObject);
    if (result == 'null') return  '';
    return result;
  }

  _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
  }





}

final api = _Clients();
