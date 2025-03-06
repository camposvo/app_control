// To parse this JSON data, do
//
//     final resultTest = resultTestFromJson(jsonString);

import 'dart:convert';

/*
{
"orga_id": "XXXXX",
"comentarios":[{
"come_fecha": ""  ,
"come_revi_id":"" ,
"come_inst_id":"" ,
"come_descripcion":""
}],
"pruebas":[{
"prue_fecha":"",
"prue_revi_id":"",
"prue_punt_id": "",
"prue_comentario":"",
"prue_recurso_1":"",
"prue_recurso_2":""
}]
}*/

ResultTest resultTestFromJson(String str) => ResultTest.fromJson(json.decode(str));

String resultTestToJson(ResultTest data) => json.encode(data.toJson());

class ResultTest {
  String orgaId;
  List<Comentario> comentarios;
  List<Prueba> pruebas;

  ResultTest({
    required this.orgaId,
    required this.comentarios,
    required this.pruebas,
  });

  factory ResultTest.fromJson(Map<String, dynamic> json) => ResultTest(
    orgaId: json["orga_id"],
    comentarios: List<Comentario>.from(json["comentarios"].map((x) => Comentario.fromJson(x))),
    pruebas: List<Prueba>.from(json["pruebas"].map((x) => Prueba.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "orga_id": orgaId,
    "comentarios": List<dynamic>.from(comentarios.map((x) => x.toJson())),
    "pruebas": List<dynamic>.from(pruebas.map((x) => x.toJson())),
  };
}

class Comentario {
  DateTime comeFecha;
  String comeReviId;
  String comeInstId;
  String comeDescripcion;

  Comentario({
    required this.comeFecha,
    required this.comeReviId,
    required this.comeInstId,
    required this.comeDescripcion,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
    comeFecha: DateTime.parse(json["come_fecha"]),
    comeReviId: json["come_revi_id"],
    comeInstId: json["come_inst_id"],
    comeDescripcion: json["come_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "come_fecha": comeFecha.toIso8601String(),
    "come_revi_id": comeReviId,
    "come_inst_id": comeInstId,
    "come_descripcion": comeDescripcion,
  };
}

class Prueba {
  DateTime prueFecha;
  String prueReviId;
  String pruePuntId;
  String prueComentario;
  String prueRecurso1;
  String prueRecurso2;

  Prueba({
    required this.prueFecha,
    required this.prueReviId,
    required this.pruePuntId,
    required this.prueComentario,
    required this.prueRecurso1,
    required this.prueRecurso2,
  });

  factory Prueba.fromJson(Map<String, dynamic> json) => Prueba(
    prueFecha: DateTime.parse(json["prue_fecha"]),
    prueReviId: json["prue_revi_id"],
    pruePuntId: json["prue_punt_id"],
    prueComentario: json["prue_comentario"],
    prueRecurso1: json["prue_recurso_1"],
    prueRecurso2: json["prue_recurso_2"],
  );

  Map<String, dynamic> toJson() => {
    "prue_fecha": prueFecha.toIso8601String(),
    "prue_revi_id": prueReviId,
    "prue_punt_id": pruePuntId,
    "prue_comentario": prueComentario,
    "prue_recurso_1": prueRecurso1,
    "prue_recurso_2": prueRecurso2,
  };
}
