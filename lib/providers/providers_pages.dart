import 'package:control/models/variable.dart';
import 'package:flutter/material.dart';

class ProviderPages with ChangeNotifier {
  List<DataItem> _dataItems = [];
  List<DataItem> _filterList = [];
  int selectedIndex = 0;

  List<DataItem> get dataItems => _dataItems;
  List<DataItem> get filterList => _filterList;

  set dataItems(List<DataItem> value) {
    _dataItems = value;
    notifyListeners();
  }

  set filterList(List<DataItem> value) {
    _filterList = value;
    notifyListeners();
  }

}
