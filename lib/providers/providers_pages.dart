import 'package:control/models/variable.dart';
import 'package:flutter/material.dart';

import '../models/orgaInstrumento.dart';

class ProviderPages with ChangeNotifier {
  List<OrgaInstrumento> _organizations = [];
  List<OrgaInstrumento> _filterList = [];
  String _orgaId = '';
  String _instId = '';
  String _varId = '';

  String _mainTopic = '';
  String _connected = '';


  List<OrgaInstrumento> get organizations => _organizations;
  List<OrgaInstrumento> get filterList => _filterList;

  set organizations(List<OrgaInstrumento> value) {
    _organizations = value;
    notifyListeners();
  }

  set filterList(List<OrgaInstrumento> value) {
    _filterList = value;
    notifyListeners();
  }

  String get orgaId => _orgaId;
  set orgaId(String value) {
    _orgaId = value;
    notifyListeners();
  }

  String get instId => _instId;
  set instId(String value) {
    _instId = value;
    notifyListeners();
  }


  String get mainTopic => _mainTopic;
  set mainTopic(String value) {
    _mainTopic = value;
    notifyListeners();
  }

  String get connected => _connected;
  set connected(String value) {
    _connected = value;
    notifyListeners();
  }

  String get varId => _varId;
  set varId(String value) {
    _varId = value;
    notifyListeners();
  }


}
