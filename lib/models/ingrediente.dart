// To parse this JSON data, do
//
//     final ingrediente = ingredienteFromJson(jsonString);

import 'dart:convert';

List<Ingrediente> ingredienteFromJson(String str) => List<Ingrediente>.from(json.decode(str).map((x) => Ingrediente.fromJson(x)));

String ingredienteToJson(List<Ingrediente> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ingrediente {
  String ingreId;
  String ingreNombre;
  double ingreCantidad;
  String ingreUnidad;

  Ingrediente({
    required this.ingreId,
    required this.ingreNombre,
    required this.ingreCantidad,
    required this.ingreUnidad,
  });

  factory Ingrediente.fromJson(Map<String, dynamic> json) => Ingrediente(
    ingreId: json["ingre_id"],
    ingreNombre: json["ingre_nombre"],
    ingreCantidad: json["ingre_cantidad"]?.toDouble(),
    ingreUnidad: json["ingre_unidad"],
  );

  Map<String, dynamic> toJson() => {
    "ingre_id": ingreId,
    "ingre_nombre": ingreNombre,
    "ingre_cantidad": ingreCantidad,
    "ingre_unidad": ingreUnidad,
  };
}
