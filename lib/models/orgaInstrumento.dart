// To parse this JSON data, do
//
//     final orgaInstrumento = orgaInstrumentoFromJson(jsonString);

import 'dart:convert';

import 'package:control/models/resultRevision.dart';

import '../helper/util.dart';

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

  //  ************* NUEVO METODO PARA OBTENER Lista de InstComentario por comeReviId ******************************
/*  List<Comentario> getComentariosByReviId(String comeReviId) {
    List<Comentario> comentariosEncontrados = [];

    for (var instrumento in orgaInstrumentos) {
      for (var comentario in instrumento.instComentarios) {
        if (comentario.comeReviId == comeReviId && comentario.comeEnviado == 2) {

          Comentario comment = Comentario(comeFecha: comentario.comeFecha,
              comeId: comentario.comeId,
              comeReviId: comentario.comeReviId,
              comeInstId: instrumento.instId,
              comeDescripcion: comentario.comeDescripcion);

          comentariosEncontrados.add(comment);
        }
      }
    }

    return comentariosEncontrados;
  }*/

  //  ************* NUEVO METODO PARA OBTENER Lista de PuntPrueba por prueReviId ******************************
  List<Prueba> getPruebasByReviId(String prueReviId) {
    List<Prueba> pruebasEncontradas = [];
    for (var instrumento in orgaInstrumentos) {
      for (var variable in instrumento.instVariables) {
        for (var prueba in variable.puntPrueba) {
          if (prueba.prueReviId == prueReviId &&  prueba.prueEnviado == 2 ) {
            Prueba temp = Prueba(
              prueId: prueba.prueId,
              prueReviId : prueba.prueReviId,
              pruePuntId: variable.puntId,
              prueComentario: prueba.prueDescripcion,
              prueFecha: prueba.prueFecha,
              prueRecurso2: prueba.prueFoto2,
              prueRecurso1: prueba.prueFoto1,
              reviNumero: prueba.reviNumero,
              prueValor1: prueba.prueValor1,
              prueValor2: prueba.prueValor2,
              prueActivo: prueba.prueActivo
            );
            pruebasEncontradas.add(temp);
          }
        }
      }
    }

    return pruebasEncontradas;
  }

//  ************* NUEVO METODO PARA OBTENER Lista de PuntPrueba por prueReviId ******************************
  List<InstFinalizado> getInstFinalizadosEnviados(String reviId) {
    List<InstFinalizado> finalizadosEnviados = [];

    for (var instrumento in orgaInstrumentos) {
      for (var instFinalizado in instrumento.instFinalizados) {
        if (instFinalizado.inreEnviado == 2 && instFinalizado.reviId == reviId) {
          finalizadosEnviados.add(instFinalizado);
        }
      }
    }

    return finalizadosEnviados;
  }


  //  ************* NUEVO METODO PARA OBTENER Lista de PuntPrueba por prueReviId ******************************
  List<PuntComment> getPuntComeByReviId(String prueReviId) {
    List<PuntComment> pruebasEncontradas = [];
    for (var instrumento in orgaInstrumentos) {
      for (var variable in instrumento.instVariables) {
        for (var comment in variable.puntComentarios) {
          if (comment.comeReviId == prueReviId &&  comment.comeEnviado == 2 ) {
            PuntComment temp = PuntComment(
              comePuntId: variable.puntId,
              comeReviId: comment.comeReviId,
              comeFecha: comment.comeFecha,
              comeDescripcion: comment.comeDescripcion,
              comeActivo: comment.comeActivo,

            );
            pruebasEncontradas.add(temp);
          }
        }
      }
    }

    return pruebasEncontradas;
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
  List<InstFinalizado> instFinalizados;
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
    required this.instFinalizados,
    required this.instClasificacion,
    required this.instEspaAreaNombre,
    required this.instEspaPisoNombre,
    required this.instUbicAreaNombre,
    required this.instUbicPisoNombre,
  });

  factory OrgaInstrumentoElement.fromJson(Map<String, dynamic> json) =>
      OrgaInstrumentoElement(
        instId: json["inst_id"],
        instTipo: json["inst_tipo"],
        instNombre: json["inst_nombre"],
        instNumero: json["inst_numero"],
        instVariables: List<InstVariable>.from(
            json["inst_variables"].map((x) => InstVariable.fromJson(x))),
        instProteccion: json["inst_proteccion"]?.toDouble(),
        instAbreviatura: json["inst_abreviatura"],
        instFinalizados: List<InstFinalizado>.from(
            json["inst_finalizados"].map((x) => InstFinalizado.fromJson(x))),
        instClasificacion: json["inst_clasificacion"],
        instEspaAreaNombre: json["inst_espa_area_nombre"],
        instEspaPisoNombre: json["inst_espa_piso_nombre"],
        instUbicAreaNombre: json["inst_ubic_area_nombre"],
        instUbicPisoNombre: json["inst_ubic_piso_nombre"],
      );

  Map<String, dynamic> toJson() =>
      {
        "inst_id": instId,
        "inst_tipo": instTipo,
        "inst_nombre": instNombre,
        "inst_numero": instNumero,
        "inst_variables": List<dynamic>.from(
            instVariables.map((x) => x.toJson())),
        "inst_proteccion": instProteccion,
        "inst_abreviatura": instAbreviatura,
        "inst_finalizados": List<dynamic>.from(
            instFinalizados.map((x) => x.toJson())),
        "inst_clasificacion": instClasificacion,
        "inst_espa_area_nombre": instEspaAreaNombre,
        "inst_espa_piso_nombre": instEspaPisoNombre,
        "inst_ubic_area_nombre": instUbicAreaNombre,
        "inst_ubic_piso_nombre": instUbicPisoNombre,
      };


  //  ************* OBTIEN EL FINALIZADO PARA UN REVIID  ******************************
  int? getInreFinalizadoByReviId(String targetReviId) {
    try {
      final InstFinalizado foundInstFinalizado = instFinalizados.firstWhere(
            (instFinalizado) => instFinalizado.reviId == targetReviId,
      );
      return foundInstFinalizado.inreFinalizado;
    } catch (e) {
      return null;
    }
  }

  //  ************* ADD OR UPDATE  ******************************

  void updateOrCreateInstFinalizado(String reviId, InstFinalizado newInstFinalizado) {
    int index = instFinalizados.indexWhere((inst) => inst.reviId == reviId);
    if (index != -1) {
      instFinalizados[index].inreFinalizado = newInstFinalizado.inreFinalizado;
      instFinalizados[index].inreEnviado = 2;
    } else {
      instFinalizados.add(newInstFinalizado);
     
    }
  }



}

class InstFinalizado {
  String instId;
  String reviId;
  String reviNumero;
  String reviEntiId;
  int inreFinalizado;
  int? inreEnviado;


  InstFinalizado({
    required this.instId,
    required this.reviId,
    required this.reviNumero,
    required this.reviEntiId,
    required this.inreFinalizado,
    this.inreEnviado = 1,
  });

  factory InstFinalizado.fromJson(Map<String, dynamic> json) => InstFinalizado(
    instId: json["inst_id"],
    reviId: json["revi_id"],
    reviNumero: json["revi_numero"],
    reviEntiId: json["revi_enti_id"],
    inreFinalizado: json["inre_finalizado"],
  );

  Map<String, dynamic> toJson() => {
    "inst_id": instId,
    "revi_id": reviId,
    "revi_numero": reviNumero,
    "revi_enti_id": reviEntiId,
    "inre_finalizado": inreFinalizado,
  };


}

class InstVariable {
  String puntId;
  String variId;
  String variTipo;
  List<PuntPrueba> puntPrueba;
  String subuNombre;
  String variNombre;
  String subuSimbolo;
  String variSubuId;
  List<PuntComentario> puntComentarios;
  String subuAbreviatura;
  String variAbreviatura;

  InstVariable({
    required this.puntId,
    required this.variId,
    required this.variTipo,
    required this.puntPrueba,
    required this.subuNombre,
    required this.variNombre,
    required this.subuSimbolo,
    required this.variSubuId,
    required this.puntComentarios,
    required this.subuAbreviatura,
    required this.variAbreviatura,
  });

  factory InstVariable.fromJson(Map<String, dynamic> json) => InstVariable(
    puntId: json["punt_id"],
    variId: json["vari_id"],
    variTipo: json["vari_tipo"],
    puntPrueba: List<PuntPrueba>.from(json["punt_prueba"].map((x) => PuntPrueba.fromJson(x))),
    subuNombre: json["subu_nombre"],
    variNombre: json["vari_nombre"],
    subuSimbolo: json["subu_simbolo"],
    variSubuId: json["vari_subu_id"],
    puntComentarios: List<PuntComentario>.from(json["punt_comentarios"].map((x) => PuntComentario.fromJson(x))),
    subuAbreviatura: json["subu_abreviatura"],
    variAbreviatura: json["vari_abreviatura"],
  );

  Map<String, dynamic> toJson() => {
    "punt_id": puntId,
    "vari_id": variId,
    "vari_tipo": variTipo,
    "punt_prueba": List<dynamic>.from(puntPrueba.map((x) => x.toJson())),
    "subu_nombre": subuNombre,
    "vari_nombre": variNombre,
    "subu_simbolo": subuSimbolo,
    "vari_subu_id": variSubuId,
    "punt_comentarios": List<dynamic>.from(puntComentarios.map((x) => x.toJson())),
    "subu_abreviatura": subuAbreviatura,
    "vari_abreviatura": variAbreviatura,
  };

  //  ************* NUEVO METODO PARA CONTAR PRUEBAS ACTIVAS ******************************
  int countActivePruebas() {
    return puntPrueba.where((prueba) => prueba.prueActivo == 1).length;
  }

  //  ************* NUEVO METODO PARA OBTENER TODAS LAS PRUEBAS POR prueReviId ******************************
  List<PuntPrueba> getPruebasByReviId(String prueReviId) {
    return puntPrueba.where((prueba) => prueba.prueReviId == prueReviId).toList();
  }

  //  ************* NUEVO METODO: OBTENER COMENTARIO POR comeReviId ******************************
  PuntComentario? getComentarioByReviId(String comeReviId) {
    try {
      return puntComentarios.firstWhere(
            (comentario) => comentario.comeReviId == comeReviId,
      );
    } catch (e) {
      // Si no se encuentra ningún elemento, firstWhere lanzará un StateError.
      // En ese caso, devolvemos null.
      return null;
    }
  }

  //  ************* NUEVO METODO: AGREGAR COMENTARIO ******************************
  void addComentario(PuntComentario nuevoComentario) {
    puntComentarios.add(nuevoComentario);
  }

  //  ************* NUEVO METODO: ACTUALIZAR COMENTARIO POR comeId ******************************
  bool updateComentario(String comeId, PuntComentario updatedComentario) {
    final index = puntComentarios.indexWhere((comentario) => comentario.comeId == comeId);
    if (index != -1) {
      // Si el comentario es encontrado, lo reemplazamos en la lista
      puntComentarios[index] = updatedComentario;
      return true; // La actualización fue exitosa
    }
    return false; // El comentario con el comeId dado no fue encontrado
  }
}

class PuntComentario {
  DateTime comeFecha;
  int comeActivo;
  String comeReviId;
  String comeDescripcion;
  String? comeId;
  int? comeEnviado;

  PuntComentario({
    required this.comeFecha,
    required this.comeActivo,
    required this.comeReviId,
    required this.comeDescripcion,
    String? comeId, // También nullable en el constructor
    this.comeEnviado = 1,
  }) : this.comeId = comeId ?? Util.generateUUID(); // Asigna el valor por defecto si no se provee


  factory PuntComentario.fromJson(Map<String, dynamic> json) => PuntComentario(
    comeFecha: DateTime.parse(json["come_fecha"]),
    comeActivo: json["come_activo"],
    comeReviId: json["come_revi_id"],
    comeDescripcion: json["come_descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "come_fecha": comeFecha.toIso8601String(),
    "come_activo": comeActivo,
    "come_revi_id": comeReviId,
    "come_descripcion": comeDescripcion,
  };


}

/*class InstVariable {
  String puntId;
  String variId;
  String variTipo;
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
    required this.variTipo,
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
    variTipo: json["vari_tipo"],
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
    "vari_tipo": variTipo,
    "punt_prueba": List<dynamic>.from(puntPrueba.map((x) => x.toJson())),
    "subu_nombre": subuNombre,
    "vari_nombre": variNombre,
    "subu_simbolo": subuSimbolo,
    "vari_subu_id": variSubuId,
    "subu_abreviatura": subuAbreviatura,
    "vari_abreviatura": variAbreviatura,
  };

  //  ************* NUEVO METODO PARA CONTAR PRUEBAS ACTIVAS ******************************
  int countActivePruebas() {
    return puntPrueba.where((prueba) => prueba.prueActivo == 1).length;
  }

  //  ************* NUEVO METODO PARA OBTENER TODAS LAS PRUEBAS POR prueReviId ******************************
  List<PuntPrueba> getPruebasByReviId(String prueReviId) {
    return puntPrueba.where((prueba) => prueba.prueReviId == prueReviId).toList();
  }

}*/

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
