// To parse this JSON data, do
//
//     final mqttPayload = mqttPayloadFromJson(jsonString);

import 'dart:convert';

MqttPayload mqttPayloadFromJson(String str) => MqttPayload.fromJson(json.decode(str));

String mqttPayloadToJson(MqttPayload data) => json.encode(data.toJson());

class MqttPayload {
  String tipoMensaje;
  String orgaId;
  String orgaNombre;
  String instId;
  String instNombre;
  String variId;
  String variNombre;
  String subuAbreviatura;
  String imagen;

  MqttPayload({
    required this.tipoMensaje,
    required this.orgaId,
    required this.orgaNombre,
    required this.instId,
    required this.instNombre,
    required this.variId,
    required this.variNombre,
    required this.subuAbreviatura,
    required this.imagen,
  });

  factory MqttPayload.fromJson(Map<String, dynamic> json) => MqttPayload(
    tipoMensaje: json["tipo_mensaje"],
    orgaId: json["orga_id"],
    orgaNombre: json["orga_nombre"],
    instId: json["inst_id"],
    instNombre: json["inst_nombre"],
    variId: json["vari_id"],
    variNombre: json["vari_nombre"],
    subuAbreviatura: json["subu_abreviatura"],
    imagen: json["imagen"],
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
  };
}
