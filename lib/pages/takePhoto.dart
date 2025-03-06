import 'dart:convert';
import 'dart:io';
import 'package:control/models/tramaDatos.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/mqttManager.dart';
import '../models/orgaInstrumento.dart';
import '../providers/providers_pages.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

enum WidgetState { LOADING, LOADED, CAPTURE, ERROR_CAMERA, ERROR_MQTT }
enum ImageState { RECEIVED, WAITING }
const String infoPrefix = 'MyAPP ';

class TakePhoto extends StatefulWidget {
  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  var logger = Logger();




  late List<CameraDescription> _cameras;
  CameraController? _controller;
  final mqttManager = MqttManager(
    broker: 'manuales.ribe.cl',
    port: 8883,
    username: 'root',
    password: '*R1b3x#99',
  );

  final TramaDatos _tramaDatos = new TramaDatos(
    tipoMensaje: "",
    orgaId: "",
    orgaNombre: "",
    instId: "",
    instNombre: "",
    variId: "",
    variNombre: "",
    subuAbreviatura: "",
    imagen: "",
  );

  XFile? _image;
  WidgetState _widgetState = WidgetState.LOADING;
  ImageState imageState = ImageState.WAITING;

  String imageBase64_1 = "";
  String imageBase64_2 = "";
  String comment = '';

  String errorMqtt = '';

  String masterMqtt = '/TAKE_PHOTO';
  String slaveMqtt = '/SENDING_PHOTO';

  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento orgaInstrument;
  late InstVariable variable;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

    // Load Data
    final info = Provider.of<ProviderPages>(context, listen: false);
    orgaInstrument = info.orgaInstrument;
    instrument = orgaInstrument.orgaInstrumentos
        .firstWhere((item) => item.instId == info.instId);
    variable = instrument.instVariables
        .firstWhere((item) => item.variId == info.varId);

    final mainTopic = info.mainTopic;
    masterMqtt = mainTopic + masterMqtt;
    slaveMqtt = mainTopic + slaveMqtt;

    // Initialize Camera
    final resultCamera = await _initCamera();
    if (resultCamera == 0) {
      _widgetState = WidgetState.ERROR_CAMERA;
      setState(() {});
      return;
    }

    // Initialize Mqtt
    final resultMqtt = await _initMQTT();
    if (resultMqtt == 0) {
      _widgetState = WidgetState.ERROR_MQTT;
      setState(() {});
      return;
    }

    _tramaDatos.instNombre = instrument.instNombre;
    _tramaDatos.orgaNombre = orgaInstrument.orgaNombre;
    _tramaDatos.variNombre = variable.variNombre;
    _tramaDatos.subuAbreviatura = variable.subuAbreviatura;


    _widgetState = WidgetState.LOADED;
    setState(() {});
  }

  Future<int> _initCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) await Permission.camera.request();

    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.high,
      );
      await _controller!.initialize();

      if (_controller!.value.hasError) return 0;
    }

    return 1;
  }

  Future<int> _initMQTT() async {
    try {
      await mqttManager.initialize();
      _subscribeMaster();
      _subscribeSlave();
    } catch (e) {
      print("Error initializing MQTT: $e");
      return 0;
    }
    return 1;
  }

  void _savePuntoPrueba(BuildContext context, int value){
    final info = Provider.of<ProviderPages>(context, listen: false);

    developer.log('$infoPrefix Información general');
    logger.i('$infoPrefix: orgaId: ${info.orgaInstrument.orgaId}');



    for (var j = 0; j < info.orgaInstrument.orgaInstrumentos.length; j++) {
          if (info.orgaInstrument.orgaInstrumentos[j].instId == info.instId) {
            for (var k = 0; k < info.orgaInstrument.orgaInstrumentos[j].instVariables.length; k++) {
              if (info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntId == info.puntId) {
                for (var l = 0; l < info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba.length; l++) {
                  if (info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueReviId == info.revision?.reviId) {
                    // Modificar el elemento directamente en la lista
                    info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueDescripcion = comment;
                    info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueFecha = DateTime.now();
                    info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueFoto1 = imageBase64_1;
                    info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueFoto2 = imageBase64_2;
                    info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueEnviado = value;
                    setState(() {
                    });
                    logger.i(info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l].prueEnviado);
                   // logger.i(info.orgaInstrument.orgaInstrumentos[j].instVariables[k].puntPrueba[l]);
                   return; // Elemento encontrado y modificado
                  }
                }
              }
            }
          }
        }



  }

  void _subscribeMaster() {
    mqttManager.subscribe(masterMqtt, (message) {
      final data = tramaDatosFromJson(message);

      switch (data.tipoMensaje) {
        case "IMAGE_CAMERA_1":
          return;
        case "TAKE_PHOTO":
          _takePicture();
          return;
      }
    });
  }

  void _subscribeSlave() {
    mqttManager.subscribe(slaveMqtt, (message) {
      final data = tramaDatosFromJson(message);

      switch (data.tipoMensaje) {
        case "IMAGE_CAMERA_2":
          imageBase64_2 = data.imagen;
          imageState = ImageState.RECEIVED;
          setState(() {});
          return;

        case "TAKE_PHOTO":
          _takePicture();
          return;
      }
    });
  }

  Future<void> _publishMessage(String topic, TramaDatos message) async {
    final jsonData = jsonEncode(message);
    mqttManager.publish(masterMqtt, jsonData);
  }

  Future<String?> _convertImageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      return base64Image;
    } catch (e) {
      print('Error al convertir la imagen a Base64: $e');
      return null;
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final XFile image = await _controller!.takePicture();
      final base64Image = await _convertImageToBase64(image.path);

      if (base64Image != null) {
        imageBase64_1 = base64Image;

        _tramaDatos.tipoMensaje = "IMAGE_CAMERA_1";
        _tramaDatos.imagen = imageBase64_1;
        _publishMessage(masterMqtt, _tramaDatos);

        _widgetState = WidgetState.CAPTURE;
        setState(() {
          _image = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case WidgetState.LOADED:
        return _previewCamera(context);

      case WidgetState.CAPTURE:
        return _buildScaffold(context, _viewImage(context));

      case WidgetState.ERROR_CAMERA:
        return Scaffold(
          body: Center(
            child: Text("La cámara No se pudo Cargar. Reincie la App"),
          ),
        );

      case WidgetState.ERROR_MQTT:
        return Scaffold(
          body: Center(
            child: Text("Error con MQTT: $errorMqtt"),
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

  Widget _previewCamera(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
          body: Stack(children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: RotatedBox(
                // Rotamos *dentro* del SizedBox
                quarterTurns: 1, // 1 para 90 grados, 2 para 180, etc.
                child: CameraPreview(_controller!),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black.withAlpha(51), // Fondo semitransparente
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          _widgetState = WidgetState.LOADING;
          setState(() {});

          _tramaDatos.tipoMensaje = "TAKE_PHOTO";
          _publishMessage(masterMqtt, _tramaDatos);
        }),
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
            'Cámara Local',
            textAlign: TextAlign.center, // Centra el texto
            style: TextStyle(
              fontWeight: FontWeight.bold, // Texto en negrita
              fontSize: 18.0, // Tamaño de fuente 14
            ),
          ),
          InteractiveViewer(
            minScale: 0.5, // Define el zoom mínimo (opcional)
            maxScale: 3.0, // Define el zoom máximo (opcional)
            child: Image.memory(
              base64Decode(imageBase64_1),
              height: 500,

              fit: BoxFit.contain, // Importante: Usa BoxFit.contain
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Cámara Remota',
            textAlign: TextAlign.center, // Centra el texto
            style: TextStyle(
              fontWeight: FontWeight.bold, // Texto en negrita
              fontSize: 18.0, // Tamaño de fuente 14
            ),
          ),
          // Imágenes Base64
          (imageState == ImageState.WAITING)
              ? SizedBox(
                  height: 500,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : InteractiveViewer(
                  minScale: 0.5, // Define el zoom mínimo (opcional)
                  maxScale: 3.0, // Define el zoom máximo (opcional)
                  child: Image.memory(
                    base64Decode(imageBase64_2),
                    height: 500,
                    fit: BoxFit.contain, // Importante: Usa BoxFit.contain
                  ),
                ),

          // Cuadro de entrada para comentarios
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Agrega un comentario...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    comment = value;
                  });
                },
              ),
            ),
          ),
          // Botones de iconos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.redColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),),
              ),
              CircleAvatar(
                backgroundColor: Colors.green, // Color del círculo (puedes cambiarlo)
                child:  IconButton(
                  onPressed: () {
                    print("AQUI VA");
                    _savePuntoPrueba(context, 2);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, color: Colors.white,),
                ),
              ),

              CircleAvatar(
                backgroundColor: AppColor.redColor, // Color del círculo (puedes cambiarlo)
                child:   IconButton(
                  onPressed: () {
                    _savePuntoPrueba(context, 3);
                  },
                  icon: const Icon(Icons.close, color: Colors.white,),
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
