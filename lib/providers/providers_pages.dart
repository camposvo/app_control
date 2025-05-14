import 'dart:convert';

import 'package:control/helper/util.dart';
import 'package:control/models/organizacion.dart';
import 'package:control/models/variable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../helper/constant.dart';
import '../models/orgaInstrumento.dart';
import '../models/resultRevision.dart';

class ProviderPages with ChangeNotifier {
  final _box = Hive.box('boxname'); // Accede al contenedor

  List<OrgaInstrumento> _mainData = [];
  ResultRevision? _resultData;
  Organization? _organization;
  bool _isOrganization = false;
  OrgaRevisione? _revision;

  String _instId = '';
  String _varId = '';
  String _puntId = '';

  String _mainTopic = '';
  bool _connected = false;
  bool _pendingData = false;

  ModuleSelect _moduleSelected = ModuleSelect.NOTHING;

  // INITIAL DATA
  ProviderPages() {
    getIsOrganizationFromHive();
    getPendingDataFromHive();
    getMainTopicFromHive();
    getConnectFromHive();
    getModuleSelectedFromHive();
    getResultDataFromHive();

    final orga = getOrganizationFromHive();
    if (orga != null) {
      _organization = orga;
    }

    final revi = getRevisionFromHive();
    if (revi != null) {
      _revision = revi;
    }

    final data = getOrgaInstrumentosFromHive();
    if (data != null) {
      _mainData = data;
    }

  }

  bool get pendingData => _pendingData;
  set pendingData(bool value) {
    _pendingData = value;
    _box.put('pendingdata', value);
    notifyListeners();
  }

  ModuleSelect get moduleSelected => _moduleSelected;
  set moduleSelected(ModuleSelect value) {
    _moduleSelected = value;
    _box.put('moduleSelected', value);
    notifyListeners();
  }

  bool get isOrganization => _isOrganization;
  set isOrganization(bool value) {
    _isOrganization = value;
    _box.put('isOrganization', value);
    notifyListeners();
  }

  OrgaRevisione? get revision => _revision;
  set revision(OrgaRevisione? value) {
    _revision = value;
    final jsonString = jsonEncode(value!.toJson());
    _box.put('revision', jsonString);
    notifyListeners();
  }

  Organization? get organization => _organization;
  set organization(Organization? value) {
    _organization = value;
    final jsonString = jsonEncode(value!.toJson());
    _box.put('organization', jsonString);
    notifyListeners();
  }

  List<OrgaInstrumento> get mainData => _mainData;
  void mainDataUpdate(List<OrgaInstrumento> value) {
    final jsonString = orgaInstrumentoToJson(value);
    _box.put('maindata', jsonString);
    notifyListeners();
  }


  ResultRevision? get resultData => _resultData;
  void resultDataUpdate(ResultRevision value) {
    final jsonString = resultRevisionToJson(value);
    _box.put('_resultData', jsonString);
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
    _box.put('mainTopic', value);
    notifyListeners();
  }

  bool get connected => _connected;
  set connected(bool value) {
    _connected = value;
    _box.put('connected', value);
    notifyListeners();
  }

  String get varId => _varId;
  set varId(String value) {
    _varId = value;
    notifyListeners();
  }

  // LOAD DATA FROM HIVE
  void getIsOrganizationFromHive() {
    _isOrganization = _box.get('isOrganization', defaultValue: false);
  }

  void getPendingDataFromHive() {
    _pendingData = _box.get('pendingdata', defaultValue: false);
  }

  void getModuleSelectedFromHive() {
    _moduleSelected = _box.get('moduleSelected', defaultValue: ModuleSelect.NOTHING);
  }

  void getMainTopicFromHive() {
    _mainTopic = _box.get('mainTopic', defaultValue: '');
  }

  void getConnectFromHive() {
    _connected = _box.get('connected', defaultValue: false);
  }

  Organization? getOrganizationFromHive() {
    final jsonString = _box.get('organization');
    if (jsonString == null) {
      return null; // Retorna null si no hay datos guardados
    }
    try {
      final decodedJson = jsonDecode(jsonString);
      return Organization.fromJson(decodedJson);
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return null; // Retorna null si hay un error al decodificar
    }
  }

  OrgaRevisione? getRevisionFromHive() {
    final jsonString = _box.get('revision');
    if (jsonString == null) {
      return null; // Retorna null si no hay datos guardados
    }
    try {
      final decodedJson = jsonDecode(jsonString);
      return OrgaRevisione.fromJson(decodedJson);
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return null; // Retorna null si hay un error al decodificar
    }
  }

  List<OrgaInstrumento>? getOrgaInstrumentosFromHive() {
    final jsonString = _box.get('maindata');

    if (jsonString == null) {
      return null; // Retorna null si no hay datos guardados
    }
    try {
      return orgaInstrumentoFromJson(jsonString);
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return null; // Retorna null si hay un error al decodificar
    }
  }

  ResultRevision? getResultDataFromHive() {
    final jsonString = _box.get('resultData');
    if (jsonString == null) {
      return null; // Retorna null si no hay datos guardados
    }
    try {
      final decodedJson = jsonDecode(jsonString);
      return ResultRevision.fromJson(decodedJson);
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return null; // Retorna null si hay un error al decodificar
    }
  }

  // CLEAR ALL DATA
  Future<void> clearData() async{
    await _box.clear();

    _mainData.clear();
    _organization = null;
    _isOrganization = false;
    _revision = null;
    _instId = '';
    _varId = '';
    _puntId = '';
    _mainTopic = '';
    _connected = false;
    _pendingData = false;

    notifyListeners();
  }

  void  refreshData() async{
    notifyListeners();
  }






}
