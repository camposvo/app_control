
import 'dart:convert';

List<DataItem> parseData(String jsonString) {
  final Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.entries.map((entry) {
    final Map<String, dynamic> itemData = entry.value;

    return DataItem.fromJson({
      'key': entry.key,
      'time': itemData['time'],
      'value': itemData['value'],
    });
  }).toList();
}

class DataItem {
  final String key;
  final DateTime time;
  final double value;

  DataItem({
    required this.key,
    required this.time,
    required this.value,
  });

  // Constructor desde un Map (para parsear el JSON)
  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      key: json['key'],
      time: DateTime.parse(json['time']),
      value: json['value'].toDouble(),
    );
  }
}