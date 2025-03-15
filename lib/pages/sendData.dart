import 'dart:convert';

import 'package:control/helper/common_widgets.dart';
import 'package:control/helper/util.dart';
import 'package:control/models/resultRevision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';

import '../api/client.dart';

class SendData extends StatefulWidget {
  @override
  State<SendData> createState() => _SendDataState();
}

class _SendDataState extends State<SendData> {
  late ResultRevision resultRevision;

  @override
  void initState() {
    super.initState();
    //_loadData(context);
  }

  void _loadData(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    resultRevision = new ResultRevision(
        orgaId: info.organization.orgaId, comentarios: [], pruebas: []);

    for (var i = 0; i < info.mainData.length; i++) {
      if (info.mainData[i].orgaId == info.organization.orgaId) {
        for (var j = 0; j < info.mainData[i].orgaInstrumentos.length; j++) {
          if (info.mainData[i].orgaInstrumentos[j].instId == info.instId) {
            for (var k = 0;
                k < info.mainData[i].orgaInstrumentos[j].instComentarios.length;
                k++) {
              if (info.mainData[i].orgaInstrumentos[j].instComentarios[k]
                      .comeReviId ==
                  info.revision?.reviId) {
                Comentario comment = new Comentario(
                    comeId: Util.generateUUID(),
                    comeFecha: info.mainData[i].orgaInstrumentos[j]
                        .instComentarios[k].comeFecha,
                    comeReviId: info.mainData[i].orgaInstrumentos[j]
                        .instComentarios[k].comeReviId,
                    comeInstId: info.mainData[i].orgaInstrumentos[j].instId,
                    comeDescripcion: info.mainData[i].orgaInstrumentos[j]
                        .instComentarios[k].comeDescripcion);


                resultRevision.comentarios.add(comment);
              }
            }

            for (var k = 0;
                k < info.mainData[i].orgaInstrumentos[j].instVariables.length;
                k++) {
              for (var l = 0;
                  l <
                      info.mainData[i].orgaInstrumentos[j].instVariables[k]
                          .puntPrueba.length;
                  l++) {
                if (info.mainData[i].orgaInstrumentos[j].instVariables[k]
                        .puntPrueba[l].prueReviId ==
                    info.revision?.reviId) {
                  Prueba prueba = new Prueba(
                    prueId: Util.generateUUID(),
                    prueComentario: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntPrueba[l].prueDescripcion,
                    prueFecha: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntPrueba[l].prueFecha,
                    pruePuntId: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntId,
                      prueRecurso1: "Foto 1",
                      prueRecurso2: "Foto 2",
                   /* prueRecurso1: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntPrueba[l].prueFoto1,
                    prueRecurso2: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntPrueba[l].prueFoto1,*/
                    prueReviId: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntPrueba[l].prueReviId,
                    reviNumero: info.mainData[i].orgaInstrumentos[j]
                        .instVariables[k].puntPrueba[l].reviNumero
                  );

                  resultRevision.pruebas.add(prueba);
                }
              }
            }
          }
        }
      }
    }

  }

  Future<bool> _saveComment() async {
    final result =await api.insertComment(resultRevision);
    if(result == null){
      showMsg("Error");
      return false;
    }

    return true;
  }

  Future<bool> _saveTest() async {

    final orgaId = resultRevision.orgaId;

    for (var test in resultRevision.pruebas) {
      var result = await api.insertTest(orgaId, test);

      if (result == null) {
        showMsg("Error al insertar la Prueba con orgaId: ${orgaId}");
        return false; // Retorna false inmediatamente si alguna inserción falla
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
        drawer: setDrawer(context),
        appBar: setAppBarMain(
          context,
          "Ribe",
          "Enviar Datos",
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
            child: Theme(
                data: ThemeData(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColor.themeColor,
                        secondary: AppColor.secondaryColor,
                      ),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(width - 20, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Radio de 10.0
                          ),
                          backgroundColor: AppColor.themeColor,
                          padding: EdgeInsets.all(10.0),
                        ),
                        onPressed: () async {
                          _loadData(context);
                          //await _saveComment();
                          await _saveTest();
                          //Navigator.pushNamed(context, 'organizations');
                        },
                        child: Text(
                          'Enviar Datos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
