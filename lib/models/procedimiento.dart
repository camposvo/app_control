// To parse this JSON data, do
//
//     final procedimiento = procedimientoFromJson(jsonString);

import 'dart:convert';

List<Procedimiento> procedimientoFromJson(String str) => List<Procedimiento>.from(json.decode(str).map((x) => Procedimiento.fromJson(x)));

String procedimientoToJson(List<Procedimiento> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Procedimiento {
  String proceId;
  String proceDescripcion;

  Procedimiento({
    required this.proceId,
    required this.proceDescripcion,
  });

  factory Procedimiento.fromJson(Map<String, dynamic> json) => Procedimiento(
    proceId: json["proce_id"],
    proceDescripcion: json["proce_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "proce_id": proceId,
    "proce_descripcion": proceDescripcion,
  };
}
