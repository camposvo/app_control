import 'package:control/models/organizacion.dart';
import 'package:control/models/variable.dart';
import 'package:flutter/material.dart';

import '../models/orgaInstrumento.dart';

class ProviderPages with ChangeNotifier {
  List<OrgaInstrumento> _mainData = [];
  late Organization _organization;
  bool _isOrganization = false;
  OrgaRevisione? _revision;


  String _instId = '';
  String _varId = '';
  String _puntId = '';
  String _reviId = '';

  String _mainTopic = '';
  bool _connected = false;



  bool get isOrganization => _isOrganization;
  set isOrganization(bool value) {
    _isOrganization = value;
    notifyListeners();
  }



  OrgaRevisione? get revision => _revision;
  set revision(OrgaRevisione? value) {
    _revision = value;
    notifyListeners();
  }

  Organization get organization => _organization;
  set organization(Organization value) {
    _organization = value;
    notifyListeners();
  }


  List<OrgaInstrumento> get mainData => _mainData;
  set mainData(List<OrgaInstrumento> value) {
    _mainData = value;
    notifyListeners();
  }


  String get instId => _instId;
  set instId(String value) {
    _instId = value;
    notifyListeners();
  }


  String get puntId => _puntId;
  set puntId(String value) {
    _puntId = value;
    notifyListeners();
  }


  String get mainTopic => _mainTopic;
  set mainTopic(String value) {
    _mainTopic = value;
    notifyListeners();
  }

  bool get connected => _connected;
  set connected(bool value) {
    _connected = value;
    notifyListeners();
  }

  String get varId => _varId;
  set varId(String value) {
    _varId = value;
    notifyListeners();
  }


  String get reviId => _reviId;
  set reviId(String value) {
    _reviId = value;
    notifyListeners();
  }



}
