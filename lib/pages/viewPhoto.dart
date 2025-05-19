import 'dart:convert';
import 'dart:io';
import 'package:control/models/tramaDatos.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../api/client.dart';
import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/mqttManager.dart';
import '../models/imageTest.dart';
import '../models/orgaInstrumento.dart';
import '../providers/providers_pages.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:control/helper/util.dart';

enum WidgetState { LOADING, LOADED, ERROR }

const String infoPrefix = 'MyAPP ';

class ViewPhoto extends StatefulWidget {
  final String? prueId;

  const ViewPhoto({super.key, this.prueId});

  @override
  _ViewPhotoState createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  var logger = Logger();

  static const List<String> commentPunto = [
    'La prueba esta correcta',
    'La prueba esta incorrecta'
  ];

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();


  String? descriptionValue;

  WidgetState _widgetState = WidgetState.LOADING;

  String imagePhoto1 = "";
  String imagePhoto2 = "";
  
  
  String comment = '';
  int typeImage_1 = -1;
  int typeImage_2 = -1;


  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento orgaInstrument;
  late InstVariable variable;
  String prueId = '';
  dynamic valor1;
  dynamic valor2;



  @override
  void initState() {
    super.initState();
    prueId = widget.prueId!;

    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});
    final info = Provider.of<ProviderPages>(context, listen: false);

    try {

      orgaInstrument = info.mainData
          .firstWhere((item) => item.orgaId == info.organization!.orgaId);

      instrument = orgaInstrument.orgaInstrumentos
          .firstWhere((item) => item.instId == info.instId);
      variable = instrument.instVariables
          .firstWhere((item) => item.variId == info.varId);


      final index = findIndexByOrgaId(info.mainData, info.organization!.orgaId);
      if(index == null){
        //fallo el update
        return;
      }

      final puntoPrueba = info.mainData[index].getPuntPruebaById(prueId);

      if(puntoPrueba == null){
        return;
      }

      valor1 = puntoPrueba.prueValor1 != null ? puntoPrueba.prueValor1.toString() : '';
      valor2 = puntoPrueba.prueValor2 != null ? puntoPrueba.prueValor2.toString() : '';

      // 1: Is URL or 2: Is Base64 -1: Null
      typeImage_1 = Util.isUrlOrBase64(puntoPrueba.prueFoto1);
      typeImage_2 = Util.isUrlOrBase64(puntoPrueba.prueFoto2);
      descriptionValue = puntoPrueba.prueDescripcion;

      if(typeImage_1 == 1){        
        final result =  await api.fetchImage(puntoPrueba.prueFoto1);        
        if(result == null) {
          imagePhoto1 = "";
        }
        else  {
          final img1 = imageTestFromJson(result);
          imagePhoto1 = img1.fileFull;
        }        
      }else{
        imagePhoto1 = puntoPrueba.prueFoto1;
      }

      if(typeImage_1 == 1){
        final result =  await api.fetchImage(puntoPrueba.prueFoto2);
        if(result == null) {
          imagePhoto2 = "";
        }
        else  {
          final img1 = imageTestFromJson(result);
          imagePhoto2 = img1.fileFull;
        }
      }else{
        imagePhoto2 = puntoPrueba.prueFoto2;
      }
       


    }catch (e) {
      _widgetState = WidgetState.ERROR;
      setState(() {});
      return;
    }

    _widgetState = WidgetState.LOADED;
    setState(() {});
  }

  void _saveDescription(BuildContext context, int value) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    bool found = false;

    PuntPrueba puntPrueba = new PuntPrueba(
      prueId: Util.generateUUID(),
      prueFecha: DateTime.now(),
      prueFoto1: "",
      prueFoto2: "",
      reviNumero: info.revision!.reviNumero,
      prueEnviado: 2,
      prueReviId: info.revision!.reviId,
      reviEntiId: info.revision!.reviEntiId,
      prueDescripcion: descriptionValue!,
      prueActivo: 1,
      prueValor1: 0,
      prueValor2: 0,
    );

    for (var i = 0; i < info.mainData.length; i++) {
      if (info.mainData[i].orgaId == info.organization!.orgaId) {
        for (var j = 0; j < info.mainData[i].orgaInstrumentos.length; j++) {
          if (info.mainData[i].orgaInstrumentos[j].instId == info.instId) {
            for (var k = 0;
                k < info.mainData[i].orgaInstrumentos[j].instVariables.length;
                k++) {
              if (info.mainData[i].orgaInstrumentos[j].instVariables[k]
                      .puntId ==
                  info.puntId) {
                for (var l = 0;
                    l <
                        info.mainData[i].orgaInstrumentos[j].instVariables[k]
                            .puntPrueba.length;
                    l++) {
                  if (info.mainData[i].orgaInstrumentos[j].instVariables[k]
                          .puntPrueba[l].prueReviId ==
                      info.revision!.reviId) {
                    found = true;
                    info.mainData[i].orgaInstrumentos[j].instVariables[k]
                        .puntPrueba[l].prueId = puntPrueba.prueId;

                    info
                        .mainData[i]
                        .orgaInstrumentos[j]
                        .instVariables[k]
                        .puntPrueba[l]
                        .prueDescripcion = puntPrueba.prueDescripcion;

                    info.mainData[i].orgaInstrumentos[j].instVariables[k]
                        .puntPrueba[l].prueFecha = puntPrueba.prueFecha;

                    info.mainData[i].orgaInstrumentos[j].instVariables[k]
                        .puntPrueba[l].prueEnviado = puntPrueba.prueEnviado;

                    info.pendingData = true;
                    info.mainDataUpdate(info.mainData);

                    return; // Elemento encontrado y modificado
                  }
                }

              }
            }
          }
        }
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return Scaffold(
          body: Center(child: circularProgressMain()),
        );

      case WidgetState.LOADED:
        return _buildScaffold(context, _viewImage(context));

      case WidgetState.ERROR:
        return Scaffold(
          body: Center(
            child: Text("Error Inesperado, cargado Información"),
          ),
        );

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.themeColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                setHeaderTitle(orgaInstrument.orgaNombre, Colors.white),
                setHeaderTitle(instrument.instNombre, Colors.white),
                setHeaderSubTitle(variable.variNombre, Colors.white),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        body: body);
  }

  Widget _viewImage(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
              'Foto #1',
            textAlign: TextAlign.center, // Centra el texto
            style: TextStyle(
              fontWeight: FontWeight.bold, // Texto en negrita
              fontSize: 18.0, // Tamaño de fuente 14
            ),
          ),
          _viewImageByType(imagePhoto1, typeImage_1),
          SizedBox(
            height: 16,
          ),

          if (info.moduleSelected == ModuleSelect.NO_SYSTEM)
          _value1Text(context),

          SizedBox(
            height: 16,
          ),

          if (info.moduleSelected == ModuleSelect.NO_SYSTEM)
            Column(
              children: <Widget>[
                Text(
                  'Foto #2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                _viewImageByType(imagePhoto2, typeImage_2),
                SizedBox(
                  height: 16,
                ),

                _value2Text(context),
                SizedBox(
                  height: 16,
                ),

              ],
            ),

        /*  if (info.moduleSelected == ModuleSelect.NO_SYSTEM)
          Text(
            'Foto #2',
            textAlign: TextAlign.center, // Centra el texto
            style: TextStyle(
              fontWeight: FontWeight.bold, // Texto en negrita
              fontSize: 18.0, // Tamaño de fuente 14
            ),
          ),

          if (info.moduleSelected == ModuleSelect.NO_SYSTEM)
          _viewImageByType(imagePhoto2, typeImage_2),

          if (info.moduleSelected == ModuleSelect.NO_SYSTEM)
            _value2Text(context),*/



          _descriptionText(context),
          SizedBox(
            height: 16,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             /* SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Radio de 10.0
                    ),
                    backgroundColor: AppColor.redColor,
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),*/
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Radio de 10.0
                    ),
                    backgroundColor: AppColor.themeColor,
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () {
                    /*if (descriptionValue == null) {
                      showError('Debe seleccionar un Comentario');
                      return;
                    }
                    _saveDescription(context, 2);*/

                    Navigator.pop(context);
                  },
                  child: Text(
                    'Regresar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  Widget _viewImageByType(String  image, int tyeImage){

   if(tyeImage == 1) return   _viewImageUrl(image);

   if(tyeImage == 2) return   _viewImageBase64(image);

   return SizedBox.shrink();

  }

  Widget _viewImageBase64(String  base64){
    return InteractiveViewer(
      minScale: 0.5, // Define el zoom mínimo (opcional)
      maxScale: 3.0, // Define el zoom máximo (opcional)
      child: Image.memory(
        base64Decode(base64),
        height: 500,
        fit: BoxFit.contain, // Importante: Usa BoxFit.contain
      ),
    );
  }

  Widget _viewImageUrl(String  urlImage){
    Util.printInfo("URL IMAGE: ", urlImage);
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Image.network(
        urlImage, // URL de ejemplo
        height: 500,
        fit: BoxFit.contain,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Text('No se pudo cargar la imagen, desde: '+urlImage);
        },
      ),
    );
  }

  Widget _descriptionList(BuildContext context) {
    return  Center(
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                // Define el borde
                borderRadius: BorderRadius.circular(10.0), // Radio de las esquinas
              ),
              filled: true, // Habilita el color de fondo
              fillColor: Colors.white, // Color de fondo
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            ),
            child: DropdownButton<String>(
              value: descriptionValue, // Objeto actual seleccionado
              items: commentPunto.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  descriptionValue = newValue;
                  if (newValue != null) {
                    print('Estado seleccionado: $newValue');
                  }
                });
              },
              hint: const Text(
                'Selección ...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          )
      ),
    );

  }

  Widget _descriptionText(BuildContext context) {

   return Center(
      child: Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0),
          //child: _descriptionList(context)),
          child: TextField(
            controller: TextEditingController(text: descriptionValue),
            enabled: false,
            decoration: InputDecoration(
              labelText: "Comentario",
              labelStyle: TextStyle(
                color: Colors.grey, // El color que desees para el label
                fontSize: 18.0, // El tamaño de fuente que desees
                fontWeight: FontWeight.normal, // El peso de la fuente (negrita, normal, etc.)
                fontStyle: FontStyle.normal, // Estilo de la fuente (cursiva, normal)
                // ... otras propiedades de TextStyle ...
              ),
              border: OutlineInputBorder(),
              disabledBorder: OutlineInputBorder( // Este es el borde para el estado deshabilitado
                borderSide: BorderSide(
                  color: AppColor.themeColor, // El color que deseas para el borde deshabilitado
                  width: 1.0, // El grosor que deseas para el borde deshabilitado
                ),
              ),
            ),

            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black, // O el color que desees
            ),
          )
      ),
    );

  }

  Widget _value1Text(BuildContext context) {

    return  Center(
      child: Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0),
          child: TextField(
            controller: TextEditingController(text: valor1),
            enabled: false,
            decoration: InputDecoration(
              labelText: "Valor 1",
              labelStyle: TextStyle(
                color: Colors.grey, // El color que desees para el label
                fontSize: 18.0, // El tamaño de fuente que desees
                fontWeight: FontWeight.normal, // El peso de la fuente (negrita, normal, etc.)
                fontStyle: FontStyle.normal, // Estilo de la fuente (cursiva, normal)
                // ... otras propiedades de TextStyle ...
              ),
              border: OutlineInputBorder(),
              disabledBorder: OutlineInputBorder( // Este es el borde para el estado deshabilitado
                borderSide: BorderSide(
                  color: AppColor.themeColor, // El color que deseas para el borde deshabilitado
                  width: 1.0, // El grosor que deseas para el borde deshabilitado
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black, // O el color que desees
            ),
          )
      ),
    );

  }

  Widget _value2Text(BuildContext context) {
    return  Center(
      child: Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0),
          child: TextField(
            controller: TextEditingController(text: valor2),
            enabled: false,
            decoration: InputDecoration(
              labelText: "Valor 2",
              labelStyle: TextStyle(
                color: Colors.grey, // El color que desees para el label
                fontSize: 18.0, // El tamaño de fuente que desees
                fontWeight: FontWeight.normal, // El peso de la fuente (negrita, normal, etc.)
                fontStyle: FontStyle.normal, // Estilo de la fuente (cursiva, normal)
                // ... otras propiedades de TextStyle ...
              ),
              border: OutlineInputBorder(),
              disabledBorder: OutlineInputBorder( // Este es el borde para el estado deshabilitado
                borderSide: BorderSide(
                  color: AppColor.themeColor, // El color que deseas para el borde deshabilitado
                  width: 1.0, // El grosor que deseas para el borde deshabilitado
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black, // O el color que desees
            ),
          )
      ),
    );

  }



  @override
  void dispose() {
    super.dispose();
  }
}
