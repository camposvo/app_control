// To parse this JSON data, do
//
//     final resultRevision = resultRevisionFromJson(jsonString);

import 'dart:convert';

import 'orgaInstrumento.dart';

ResultRevision resultRevisionFromJson(String str) => ResultRevision.fromJson(json.decode(str));

String resultRevisionToJson(ResultRevision data) => json.encode(data.toJson());

List<Map<String, dynamic>> comentariosToJson(List<Comentario> comentarios) {
  List<Map<String, dynamic>> jsonList = comentarios.map((comentario) => comentario.toJson()).toList();
  return jsonList;
  //return json.encode(jsonList);
}

List<Map<String, dynamic>> finalizadosToJson(List<InstFinalizado> instFinalizados) {
  List<Map<String, dynamic>> jsonList = instFinalizados.map((instFinalizado) =>  instFinalizado.toJson()).toList();
  return jsonList;
}

List<Map<String, dynamic>> CommentToJson(List<PuntComment> puntComment) {
  List<Map<String, dynamic>> jsonList = puntComment.map((item) =>  item.toJson()).toList();
  return jsonList;
}


class ResultRevision {
  String orgaId;
  List<Comentario> comentarios;
  List<InstFinalizado> instFinalizados;
  List<Prueba> pruebas;
  List<PuntComment> puntComentarios;

  ResultRevision({
    required this.orgaId,
    required this.comentarios,
    required this.instFinalizados,
    required this.pruebas,
    required this.puntComentarios,
  });

  factory ResultRevision.fromJson(Map<String, dynamic> json) => ResultRevision(
    orgaId: json["orga_id"],
    comentarios: List<Comentario>.from(json["comentarios"].map((x) => Comentario.fromJson(x))),
    instFinalizados: List<InstFinalizado>.from(json["inst_finalizados"].map((x) => InstFinalizado.fromJson(x))),
    pruebas: List<Prueba>.from(json["pruebas"].map((x) => Prueba.fromJson(x))),
    puntComentarios: List<PuntComment>.from(json["punt_comentarios"].map((x) => PuntComment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "orga_id": orgaId,
    "comentarios": List<dynamic>.from(comentarios.map((x) => x.toJson())),
    "inst_finalizados": List<dynamic>.from(instFinalizados.map((x) => x.toJson())),
    "pruebas": List<dynamic>.from(pruebas.map((x) => x.toJson())),
    "punt_comentarios": List<dynamic>.from(puntComentarios.map((x) => x.toJson())),
  };
}

/*class ResultRevision {
  String orgaId;
  List<Comentario> comentarios;
  List<InstFinalizado> instFinalizados;
  List<Prueba> pruebas;

  ResultRevision({
    required this.orgaId,
    required this.comentarios,
    required this.instFinalizados,
    required this.pruebas,
  });

  factory ResultRevision.fromJson(Map<String, dynamic> json) => ResultRevision(
    orgaId: json["orga_id"],
    comentarios: List<Comentario>.from(json["comentarios"].map((x) => Comentario.fromJson(x))),
    instFinalizados: List<InstFinalizado>.from(json["inst_finalizados"].map((x) => InstFinalizado.fromJson(x))),
    pruebas: List<Prueba>.from(json["pruebas"].map((x) => Prueba.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "orga_id": orgaId,
    "comentarios": List<dynamic>.from(comentarios.map((x) => x.toJson())),
    "inst_finalizados": List<dynamic>.from(instFinalizados.map((x) => x.toJson())),
    "pruebas": List<dynamic>.from(pruebas.map((x) => x.toJson())),
  };

}*/

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
  dynamic prueValor1;
  dynamic prueValor2;
  int prueActivo;

  Prueba({
    required this.prueId,
    required this.prueFecha,
    required this.prueReviId,
    required this.reviNumero,
    required this.pruePuntId,
    required this.prueComentario,
    required this.prueRecurso1,
    required this.prueRecurso2,
    required this.prueValor1,
    required this.prueValor2,
    required this.prueActivo,
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
    prueValor1: json["prue_valor_1"],
    prueValor2: json["prue_valor_2"],
    prueActivo: json["prue_activo"],
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
    "prue_valor_1": prueValor1,
    "prue_valor_2": prueValor2,
    "prue_activo": prueActivo,
  };
}

class PuntComment {
  String comePuntId;
  String comeReviId;
  DateTime comeFecha;
  String comeDescripcion;
  int comeActivo;

  PuntComment({
    required this.comePuntId,
    required this.comeReviId,
    required this.comeFecha,
    required this.comeDescripcion,
    required this.comeActivo,
  });

  factory PuntComment.fromJson(Map<String, dynamic> json) => PuntComment(
    comePuntId: json["come_punt_id"],
    comeReviId: json["come_revi_id"],
    comeFecha: DateTime.parse(json["come_fecha"]),
    comeDescripcion: json["come_descripcion"],
    comeActivo: json["come_activo"],
  );

  Map<String, dynamic> toJson() => {
    "come_punt_id": comePuntId,
    "come_revi_id": comeReviId,
    "come_fecha": comeFecha.toIso8601String(),
    "come_descripcion": comeDescripcion,
    "come_activo": comeActivo,
  };
}



