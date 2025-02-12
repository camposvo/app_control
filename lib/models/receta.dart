// To parse this JSON data, do
//
//     final receta = recetaFromJson(jsonString);

import 'dart:convert';

List<Receta> recetaFromJson(String str) => List<Receta>.from(json.decode(str).map((x) => Receta.fromJson(x)));

String recetaToJson(List<Receta> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Receta {
  String receId;
  String receNombre;
  String receDescripcion;

  Receta({
    required this.receId,
    required this.receNombre,
    required this.receDescripcion,
  });

  factory Receta.fromJson(Map<String, dynamic> json) => Receta(
    receId: json["rece_id"],
    receNombre: json["rece_nombre"],
    receDescripcion: json["rece_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "rece_id": receId,
    "rece_nombre": receNombre,
    "rece_descripcion": receDescripcion,
  };
}
