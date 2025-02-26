import 'package:control/models/organizacion.dart';
import 'package:control/models/variable.dart';
import 'package:flutter/material.dart';

import '../models/orgaInstrumento.dart';

class ProviderPages with ChangeNotifier {
  List<OrgaInstrumento> _orgaInstruments = [];
  late OrgaInstrumento _orgaInstrument;
  List<OrgaInstrumento> _filterList = [];

  late Organization _organization;
  List<Organization> _organizations = [];

  OrgaRevisione? _revision;



  String _orgaId = '';
  String _instId = '';
  String _varId = '';
  String _reviId = '';

  String _mainTopic = '';
  String _connected = '';


  OrgaRevisione? get revision => _revision;
  set revision(OrgaRevisione? value) {
    _revision = value;
    notifyListeners();
  }

  List<Organization> get organizations => _organizations;
  set organizations(List<Organization> value) {
    _organizations = value;
    notifyListeners();
  }


  Organization get organization => _organization;
  set organization(Organization value) {
    _organization = value;
    notifyListeners();
  }




  OrgaInstrumento get orgaInstrument => _orgaInstrument;
  set orgaInstrument(OrgaInstrumento value) {
    _orgaInstrument = value;
    notifyListeners();
  }

  List<OrgaInstrumento> get orgaInstruments => _orgaInstruments;
  List<OrgaInstrumento> get filterList => _filterList;

  set orgaInstruments(List<OrgaInstrumento> value) {
    _orgaInstruments = value;
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


  String get reviId => _reviId;
  set reviId(String value) {
    _reviId = value;
    notifyListeners();
  }



}
