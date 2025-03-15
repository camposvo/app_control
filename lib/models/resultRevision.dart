// To parse this JSON data, do
//
//     final resultRevision = resultRevisionFromJson(jsonString);

import 'dart:convert';


/*{
"orga_id": "XXXXX",
"comentarios":[{
"come_fecha": "2025-02-21T11:20:00"  ,
"come_id":"",
"come_revi_id":"" ,
"come_inst_id":"" ,
"come_descripcion":""
}],
"pruebas":[{
"prue_id": "",
"prue_fecha":"2025-02-21T11:20:00",
"prue_revi_id":"",
"revi_numero": "",
"prue_punt_id": "",
"prue_comentario":"",
"prue_recurso_1":"",
"prue_recurso_2":""
}]
}*/

ResultRevision resultRevisionFromJson(String str) => ResultRevision.fromJson(json.decode(str));

String resultRevisionToJson(ResultRevision data) => json.encode(data.toJson());

class ResultRevision {
  String orgaId;
  List<Comentario> comentarios;
  List<Prueba> pruebas;

  ResultRevision({
    required this.orgaId,
    required this.comentarios,
    required this.pruebas,
  });

  factory ResultRevision.fromJson(Map<String, dynamic> json) => ResultRevision(
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
  String comeId;
  String comeReviId;
  String comeInstId;
  String comeDescripcion;

  Comentario({
    required this.comeFecha,
    required this.comeId,
    required this.comeReviId,
    required this.comeInstId,
    required this.comeDescripcion,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
    comeFecha: DateTime.parse(json["come_fecha"]),
    comeId: json["come_id"],
    comeReviId: json["come_revi_id"],
    comeInstId: json["come_inst_id"],
    comeDescripcion: json["come_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "come_fecha": comeFecha.toIso8601String(),
    "come_id": comeId,
    "come_revi_id": comeReviId,
    "come_inst_id": comeInstId,
    "come_descripcion": comeDescripcion,
  };
}

class Prueba {
  String prueId;
  DateTime prueFecha;
  String prueReviId;
  String reviNumero;
  String pruePuntId;
  String prueComentario;
  String prueRecurso1;
  String prueRecurso2;

  Prueba({
    required this.prueId,
    required this.prueFecha,
    required this.prueReviId,
    required this.reviNumero,
    required this.pruePuntId,
    required this.prueComentario,
    required this.prueRecurso1,
    required this.prueRecurso2,
  });

  factory Prueba.fromJson(Map<String, dynamic> json) => Prueba(
    prueId: json["prue_id"],
    prueFecha: DateTime.parse(json["prue_fecha"]),
    prueReviId: json["prue_revi_id"],
    reviNumero: json["revi_numero"],
    pruePuntId: json["prue_punt_id"],
    prueComentario: json["prue_comentario"],
    prueRecurso1: json["prue_recurso_1"],
    prueRecurso2: json["prue_recurso_2"],
  );

  Map<String, dynamic> toJson() => {
    "prue_id": prueId,
    "prue_fecha": prueFecha.toIso8601String(),
    "prue_revi_id": prueReviId,
    "revi_numero": reviNumero,
    "prue_punt_id": pruePuntId,
    "prue_comentario": prueComentario,
    "prue_recurso_1": prueRecurso1,
    "prue_recurso_2": prueRecurso2,
  };
}
