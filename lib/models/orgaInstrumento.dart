// To parse this JSON data, do
//
//     final orgaInstrumento = orgaInstrumentoFromJson(jsonString);

import 'dart:convert';

List<OrgaInstrumento> orgaInstrumentoFromJson(String str) => List<OrgaInstrumento>.from(json.decode(str).map((x) => OrgaInstrumento.fromJson(x)));

String orgaInstrumentoToJson(List<OrgaInstrumento> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrgaInstrumento {
  String orgaId;
  String orgaNombre;
  String orgaEntiId;
  String orgaPrefijo;
  List<OrgaInstrumentoElement> orgaInstrumentos;

  OrgaInstrumento({
    required this.orgaId,
    required this.orgaNombre,
    required this.orgaEntiId,
    required this.orgaPrefijo,
    required this.orgaInstrumentos,
  });

  factory OrgaInstrumento.fromJson(Map<String, dynamic> json) => OrgaInstrumento(
    orgaId: json["orga_id"],
    orgaNombre: json["orga_nombre"],
    orgaEntiId: json["orga_enti_id"],
    orgaPrefijo: json["orga_prefijo"],
    orgaInstrumentos: List<OrgaInstrumentoElement>.from(json["orga_instrumentos"].map((x) => OrgaInstrumentoElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "orga_id": orgaId,
    "orga_nombre": orgaNombre,
    "orga_enti_id": orgaEntiId,
    "orga_prefijo": orgaPrefijo,
    "orga_instrumentos": List<dynamic>.from(orgaInstrumentos.map((x) => x.toJson())),
  };
}

class OrgaInstrumentoElement {
  String instId;
  String instTipo;
  InstConfig instConfig;
  String instNombre;
  int instNumero;
  String instEntiId;
  List<InstVariable> instVariables;
  String instMqttCodigo;
  String instIdentificador;
  String instEspaAreaNombre;
  String instEspaPisoNombre;
  String instUbicAreaNombre;
  String instUbicPisoNombre;

  OrgaInstrumentoElement({
    required this.instId,
    required this.instTipo,
    required this.instConfig,
    required this.instNombre,
    required this.instNumero,
    required this.instEntiId,
    required this.instVariables,
    required this.instMqttCodigo,
    required this.instIdentificador,
    required this.instEspaAreaNombre,
    required this.instEspaPisoNombre,
    required this.instUbicAreaNombre,
    required this.instUbicPisoNombre,
  });

  factory OrgaInstrumentoElement.fromJson(Map<String, dynamic> json) => OrgaInstrumentoElement(
    instId: json["inst_id"],
    instTipo: json["inst_tipo"],
    instConfig: InstConfig.fromJson(json["inst_config"]),
    instNombre: json["inst_nombre"],
    instNumero: json["inst_numero"],
    instEntiId: json["inst_enti_id"],
    instVariables: List<InstVariable>.from(json["inst_variables"].map((x) => InstVariable.fromJson(x))),
    instMqttCodigo: json["inst_mqtt_codigo"],
    instIdentificador: json["inst_identificador"],
    instEspaAreaNombre: json["inst_espa_area_nombre"],
    instEspaPisoNombre: json["inst_espa_piso_nombre"],
    instUbicAreaNombre: json["inst_ubic_area_nombre"],
    instUbicPisoNombre: json["inst_ubic_piso_nombre"],
  );

  Map<String, dynamic> toJson() => {
    "inst_id": instId,
    "inst_tipo": instTipo,
    "inst_config": instConfig.toJson(),
    "inst_nombre": instNombre,
    "inst_numero": instNumero,
    "inst_enti_id": instEntiId,
    "inst_variables": List<dynamic>.from(instVariables.map((x) => x.toJson())),
    "inst_mqtt_codigo": instMqttCodigo,
    "inst_identificador": instIdentificador,
    "inst_espa_area_nombre": instEspaAreaNombre,
    "inst_espa_piso_nombre": instEspaPisoNombre,
    "inst_ubic_area_nombre": instUbicAreaNombre,
    "inst_ubic_piso_nombre": instUbicPisoNombre,
  };
}

class InstConfig {
  InstConfig();

  factory InstConfig.fromJson(Map<String, dynamic> json) => InstConfig(
  );

  Map<String, dynamic> toJson() => {
  };
}

class InstVariable {
  String subuId;
  String variId;
  String subuNombre;
  String variNombre;
  String subuSimbolo;
  String variEntiId;
  String subuAbreviatura;
  String variMqttCodigo;

  InstVariable({
    required this.subuId,
    required this.variId,
    required this.subuNombre,
    required this.variNombre,
    required this.subuSimbolo,
    required this.variEntiId,
    required this.subuAbreviatura,
    required this.variMqttCodigo,
  });

  factory InstVariable.fromJson(Map<String, dynamic> json) => InstVariable(
    subuId: json["subu_id"],
    variId: json["vari_id"],
    subuNombre: json["subu_nombre"],
    variNombre: json["vari_nombre"],
    subuSimbolo: json["subu_simbolo"],
    variEntiId: json["vari_enti_id"],
    subuAbreviatura: json["subu_abreviatura"],
    variMqttCodigo: json["vari_mqtt_codigo"],
  );

  Map<String, dynamic> toJson() => {
    "subu_id": subuId,
    "vari_id": variId,
    "subu_nombre": subuNombre,
    "vari_nombre": variNombre,
    "subu_simbolo": subuSimbolo,
    "vari_enti_id": variEntiId,
    "subu_abreviatura": subuAbreviatura,
    "vari_mqtt_codigo": variMqttCodigo,
  };
}
