// To parse this JSON data, do
//
//     final orgaInstrumento = orgaInstrumentoFromJson(jsonString);

import 'dart:convert';

List<OrgaInstrumento> orgaInstrumentoFromJson(String str) => List<OrgaInstrumento>.from(json.decode(str).map((x) => OrgaInstrumento.fromJson(x)));

String orgaInstrumentoToJson(List<OrgaInstrumento> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

//  ************* NUEVO METODO  ******************************
int? findIndexByOrgaId(List<OrgaInstrumento> lista, String orgaId) {
  for (int i = 0; i < lista.length; i++) {
    if (lista[i].orgaId == orgaId) {
      return i;
    }
  }
  return null;
}

class OrgaInstrumento {
  String orgaId;
  String orgaNombre;
  String orgaEntiId;
  String orgaPrefijo;
  List<OrgaRevisione> orgaRevisiones;
  List<OrgaInstrumentoElement> orgaInstrumentos;

  OrgaInstrumento({
    required this.orgaId,
    required this.orgaNombre,
    required this.orgaEntiId,
    required this.orgaPrefijo,
    required this.orgaRevisiones,
    required this.orgaInstrumentos,
  });

  factory OrgaInstrumento.fromJson(Map<String, dynamic> json) => OrgaInstrumento(
    orgaId: json["orga_id"],
    orgaNombre: json["orga_nombre"],
    orgaEntiId: json["orga_enti_id"],
    orgaPrefijo: json["orga_prefijo"],
    orgaRevisiones: List<OrgaRevisione>.from(json["orga_revisiones"].map((x) => OrgaRevisione.fromJson(x))),
    orgaInstrumentos: List<OrgaInstrumentoElement>.from(json["orga_instrumentos"].map((x) => OrgaInstrumentoElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "orga_id": orgaId,
    "orga_nombre": orgaNombre,
    "orga_enti_id": orgaEntiId,
    "orga_prefijo": orgaPrefijo,
    "orga_revisiones": List<dynamic>.from(orgaRevisiones.map((x) => x.toJson())),
    "orga_instrumentos": List<dynamic>.from(orgaInstrumentos.map((x) => x.toJson())),
  };

  //  ************* NUEVO METODO PARA OBTENER PuntPrueba por prueId ******************************
  PuntPrueba? getPuntPruebaById(String prueId) {
    for (var instrumento in orgaInstrumentos) {
      for (var variable in instrumento.instVariables) {
        for (var prueba in variable.puntPrueba) {
          if (prueba.prueId == prueId) {
            return prueba;
          }
        }
      }
    }
    print('No se encontró ningún PuntPrueba con el ID: $prueId en la organización: $orgaId.');
    return null; // Devuelve null si no se encuentra el PuntPrueba
  }

  //  ************* NUEVO METODO PARA AGREGAR PuntPrueba ******************************
  bool addPuntPrueba(String puntId, PuntPrueba nuevoPuntPrueba) {
    for (var instrumento in orgaInstrumentos) {
      for (var variable in instrumento.instVariables) {
        if (variable.puntId == puntId) {
          variable.puntPrueba.add(nuevoPuntPrueba);
          print('Nuevo PuntPrueba agregado a la variable con puntId: $puntId del instrumento ${instrumento.instId}.');
          return true; // Indica que se encontró la variable y se agregó el PuntPrueba
        }
      }
    }
    print('No se encontró ninguna variable con el puntId: $puntId en la organización: $orgaId.');
    return false; // Indica que no se encontró la variable
  }

  //  ************* NUEVO METODO PARA ACTUALIZAR proteccio ******************************
  void updateInstProteccion(String instId, double nuevoValorProteccion) {
    for (var instrumento in orgaInstrumentos) {
      if (instrumento.instId == instId) {
        instrumento.instProteccion = nuevoValorProteccion;
        print('Instrumento con ID $instId actualizado a protección: $nuevoValorProteccion');
        return; // Si se encuentra y actualiza, podemos salir del método
      }
    }
    print('No se encontró ningún instrumento con el ID: $instId');
  }

  //  ************* NUEVO METODO PARA ACTUALIZAR PuntPrueba ******************************
  bool updatePuntPrueba(String prueId, PuntPrueba nuevoPuntPrueba) {
    for (var instrumento in orgaInstrumentos) {
      for (var variable in instrumento.instVariables) {
        for (int i = 0; i < variable.puntPrueba.length; i++) {
          if (variable.puntPrueba[i].prueId == prueId) {
            variable.puntPrueba[i] = nuevoPuntPrueba;
            print('PuntPrueba con ID $prueId del instrumento ${instrumento.instId} actualizado.');
            return true; // Indica que se encontró y actualizó el PuntPrueba
          }
        }
      }
    }
    print('No se encontró ningún PuntPrueba con el ID: $prueId en la organización: $orgaId.');
    return false; // Indica que no se encontró el PuntPrueba
  }

  //  ************* NUEVO METODO PARA ELIMINAR PuntPrueba ******************************
  bool deletePuntPrueba(String prueId) {
    for (var instrumento in orgaInstrumentos) {
      for (var variable in instrumento.instVariables) {
        for (int i = 0; i < variable.puntPrueba.length; i++) {
          if (variable.puntPrueba[i].prueId == prueId) {
            variable.puntPrueba[i].prueActivo = 0;
            print('PuntPrueba con ID $prueId del instrumento ${instrumento.instId} actualizado.');
            return true; // Indica que se encontró y actualizó el PuntPrueba
          }
        }
      }
    }
    print('No se encontró ningún PuntPrueba con el ID: $prueId en la organización: $orgaId.');
    return false; // Indica que no se encontró el PuntPrueba
  }





}

class OrgaInstrumentoElement {
  String instId;
  String instTipo;
  String instNombre;
  int instNumero;
  List<InstVariable> instVariables;
  double instProteccion;
  String instAbreviatura;
  List<InstComentario> instComentarios;
  String instClasificacion;
  String instEspaAreaNombre;
  String instEspaPisoNombre;
  String instUbicAreaNombre;
  String instUbicPisoNombre;

  OrgaInstrumentoElement({
    required this.instId,
    required this.instTipo,
    required this.instNombre,
    required this.instNumero,
    required this.instVariables,
    required this.instProteccion,
    required this.instAbreviatura,
    required this.instComentarios,
    required this.instClasificacion,
    required this.instEspaAreaNombre,
    required this.instEspaPisoNombre,
    required this.instUbicAreaNombre,
    required this.instUbicPisoNombre,
  });

  factory OrgaInstrumentoElement.fromJson(Map<String, dynamic> json) => OrgaInstrumentoElement(
    instId: json["inst_id"],
    instTipo: json["inst_tipo"],
    instNombre: json["inst_nombre"],
    instNumero: json["inst_numero"],
    instVariables: List<InstVariable>.from(json["inst_variables"].map((x) => InstVariable.fromJson(x))),
    instProteccion: json["inst_proteccion"]?.toDouble(),
    instAbreviatura: json["inst_abreviatura"],
    instComentarios: List<InstComentario>.from(json["inst_comentarios"].map((x) => InstComentario.fromJson(x))),
    instClasificacion: json["inst_clasificacion"],
    instEspaAreaNombre: json["inst_espa_area_nombre"],
    instEspaPisoNombre: json["inst_espa_piso_nombre"],
    instUbicAreaNombre: json["inst_ubic_area_nombre"],
    instUbicPisoNombre: json["inst_ubic_piso_nombre"],
  );

  Map<String, dynamic> toJson() => {
    "inst_id": instId,
    "inst_tipo": instTipo,
    "inst_nombre": instNombre,
    "inst_numero": instNumero,
    "inst_variables": List<dynamic>.from(instVariables.map((x) => x.toJson())),
    "inst_proteccion": instProteccion,
    "inst_abreviatura": instAbreviatura,
    "inst_comentarios": List<dynamic>.from(instComentarios.map((x) => x.toJson())),
    "inst_clasificacion": instClasificacion,
    "inst_espa_area_nombre": instEspaAreaNombre,
    "inst_espa_piso_nombre": instEspaPisoNombre,
    "inst_ubic_area_nombre": instUbicAreaNombre,
    "inst_ubic_piso_nombre": instUbicPisoNombre,
  };
}

class InstComentario {
  String comeId;
  DateTime comeFecha;
  String reviNumero;
  int comeEnviado;
  String comeReviId;
  String reviEntiId;
  String comeDescripcion;

  InstComentario({
    required this.comeId,
    required this.comeFecha,
    required this.reviNumero,
    required this.comeEnviado,
    required this.comeReviId,
    required this.reviEntiId,
    required this.comeDescripcion,
  });

  factory InstComentario.fromJson(Map<String, dynamic> json) => InstComentario(
    comeId: json["come_id"],
    comeFecha: DateTime.parse(json["come_fecha"]),
    reviNumero: json["revi_numero"],
    comeEnviado: json["come_enviado"],
    comeReviId: json["come_revi_id"],
    reviEntiId: json["revi_enti_id"],
    comeDescripcion: json["come_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "come_id": comeId,
    "come_fecha": comeFecha.toIso8601String(),
    "revi_numero": reviNumero,
    "come_enviado": comeEnviado,
    "come_revi_id": comeReviId,
    "revi_enti_id": reviEntiId,
    "come_descripcion": comeDescripcion,
  };
}

class InstVariable {
  String puntId;
  String variId;
  List<PuntPrueba> puntPrueba;
  String subuNombre;
  String variNombre;
  String subuSimbolo;
  String variSubuId;
  String subuAbreviatura;
  String variAbreviatura;

  InstVariable({
    required this.puntId,
    required this.variId,
    required this.puntPrueba,
    required this.subuNombre,
    required this.variNombre,
    required this.subuSimbolo,
    required this.variSubuId,
    required this.subuAbreviatura,
    required this.variAbreviatura,
  });

  factory InstVariable.fromJson(Map<String, dynamic> json) => InstVariable(
    puntId: json["punt_id"],
    variId: json["vari_id"],
    puntPrueba: List<PuntPrueba>.from(json["punt_prueba"].map((x) => PuntPrueba.fromJson(x))),
    subuNombre: json["subu_nombre"],
    variNombre: json["vari_nombre"],
    subuSimbolo: json["subu_simbolo"],
    variSubuId: json["vari_subu_id"],
    subuAbreviatura: json["subu_abreviatura"],
    variAbreviatura: json["vari_abreviatura"],
  );

  Map<String, dynamic> toJson() => {
    "punt_id": puntId,
    "vari_id": variId,
    "punt_prueba": List<dynamic>.from(puntPrueba.map((x) => x.toJson())),
    "subu_nombre": subuNombre,
    "vari_nombre": variNombre,
    "subu_simbolo": subuSimbolo,
    "vari_subu_id": variSubuId,
    "subu_abreviatura": subuAbreviatura,
    "vari_abreviatura": variAbreviatura,
  };
}

class PuntPrueba {
  String prueId;
  DateTime prueFecha;
  String prueFoto1;
  String prueFoto2;
  int prueActivo;
  String reviNumero;
  int prueEnviado;
  String prueReviId;
  dynamic prueValor1;
  dynamic prueValor2;
  String reviEntiId;
  String prueDescripcion;

  PuntPrueba({
    required this.prueId,
    required this.prueFecha,
    required this.prueFoto1,
    required this.prueFoto2,
    required this.prueActivo,
    required this.reviNumero,
    required this.prueEnviado,
    required this.prueReviId,
    required this.prueValor1,
    required this.prueValor2,
    required this.reviEntiId,
    required this.prueDescripcion,
  });

  factory PuntPrueba.fromJson(Map<String, dynamic> json) => PuntPrueba(
    prueId: json["prue_id"],
    prueFecha: DateTime.parse(json["prue_fecha"]),
    prueFoto1: json["prue_foto1"],
    prueFoto2: json["prue_foto2"],
    prueActivo: json["prue_activo"],
    reviNumero: json["revi_numero"],
    prueEnviado: json["prue_enviado"],
    prueReviId: json["prue_revi_id"],
    prueValor1: json["prue_valor_1"],
    prueValor2: json["prue_valor_2"],
    reviEntiId: json["revi_enti_id"],
    prueDescripcion: json["prue_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "prue_id": prueId,
    "prue_fecha": prueFecha.toIso8601String(),
    "prue_foto1": prueFoto1,
    "prue_foto2": prueFoto2,
    "prue_activo": prueActivo,
    "revi_numero": reviNumero,
    "prue_enviado": prueEnviado,
    "prue_revi_id": prueReviId,
    "prue_valor_1": prueValor1,
    "prue_valor_2": prueValor2,
    "revi_enti_id": reviEntiId,
    "prue_descripcion": prueDescripcion,
  };
}

class OrgaRevisione {
  String reviId;
  String reviEstado;
  String reviNumero;
  String reviEntiId;
  String reviDescripcion;

  OrgaRevisione({
    required this.reviId,
    required this.reviEstado,
    required this.reviNumero,
    required this.reviEntiId,
    required this.reviDescripcion,
  });

  factory OrgaRevisione.fromJson(Map<String, dynamic> json) => OrgaRevisione(
    reviId: json["revi_id"],
    reviEstado: json["revi_estado"],
    reviNumero: json["revi_numero"],
    reviEntiId: json["revi_enti_id"],
    reviDescripcion: json["revi_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "revi_id": reviId,
    "revi_estado": reviEstado,
    "revi_numero": reviNumero,
    "revi_enti_id": reviEntiId,
    "revi_descripcion": reviDescripcion,
  };
}
