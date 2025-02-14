import 'package:control/models/variable.dart';
import 'package:flutter/material.dart';

import '../models/orgaInstrumento.dart';

class ProviderPages with ChangeNotifier {
  List<OrgaInstrumento> _organizations = [];
  List<OrgaInstrumento> _filterList = [];

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

}
