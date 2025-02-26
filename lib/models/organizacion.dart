// To parse this JSON data, do
//
//     final organization = organizationFromJson(jsonString);

import 'dart:convert';

List<Organization> organizationFromJson(String str) => List<Organization>.from(json.decode(str).map((x) => Organization.fromJson(x)));

String organizationToJson(List<Organization> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Organization {
  String orgaId;
  String orgaNombre;
  int orgaActivo;
  String orgaPrefijo;

  Organization({
    required this.orgaId,
    required this.orgaNombre,
    required this.orgaActivo,
    required this.orgaPrefijo,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    orgaId: json["orga_id"],
    orgaNombre: json["orga_nombre"],
    orgaActivo: json["orga_activo"],
    orgaPrefijo: json["orga_prefijo"],
  );

  Map<String, dynamic> toJson() => {
    "orga_id": orgaId,
    "orga_nombre": orgaNombre,
    "orga_activo": orgaActivo,
    "orga_prefijo": orgaPrefijo,
  };
}
