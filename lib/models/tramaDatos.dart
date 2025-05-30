// To parse this JSON data, do
//
//     final tramaDatos = tramaDatosFromJson(jsonString);

import 'dart:convert';

TramaDatos tramaDatosFromJson(String str) => TramaDatos.fromJson(json.decode(str));

String tramaDatosToJson(TramaDatos data) => json.encode(data.toJson());

class TramaDatos {
  String tipoMensaje;
  String orgaId;
  String orgaNombre;
  String instId;
  String instNombre;
  String variId;
  String variNombre;
  String subuAbreviatura;
  String imagen;
  int countDown;
  bool cameraReady;
  bool connetionReady;
  bool isApproved;

  TramaDatos({
    required this.tipoMensaje,
    required this.orgaId,
    required this.orgaNombre,
    required this.instId,
    required this.instNombre,
    required this.variId,
    required this.variNombre,
    required this.subuAbreviatura,
    required this.imagen,
    required this.countDown,
    required this.cameraReady,
    required this.connetionReady,
    required this.isApproved,
  });

  factory TramaDatos.fromJson(Map<String, dynamic> json) => TramaDatos(
    tipoMensaje: json["tipo_mensaje"],
    orgaId: json["orga_id"],
    orgaNombre: json["orga_nombre"],
    instId: json["inst_id"],
    instNombre: json["inst_nombre"],
    variId: json["vari_id"],
    variNombre: json["vari_nombre"],
    subuAbreviatura: json["subu_abreviatura"],
    imagen: json["imagen"],
    countDown: json["count_down"],
    cameraReady: json["camera_ready"],
    connetionReady: json["connetion_ready"],
    isApproved: json["is_approved"],
  );

  Map<String, dynamic> toJson() => {
    "tipo_mensaje": tipoMensaje,
    "orga_id": orgaId,
    "orga_nombre": orgaNombre,
    "inst_id": instId,
    "inst_nombre": instNombre,
    "vari_id": variId,
    "vari_nombre": variNombre,
    "subu_abreviatura": subuAbreviatura,
    "imagen": imagen,
    "count_down": countDown,
    "camera_ready": cameraReady,
    "connetion_ready": connetionReady,
    "is_approved": isApproved,
  };
}
