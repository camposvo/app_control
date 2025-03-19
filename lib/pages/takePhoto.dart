import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:control/models/tramaDatos.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/mqttManager.dart';
import '../models/orgaInstrumento.dart';
import '../providers/providers_pages.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:control/helper/util.dart';

enum WidgetState { LOADING, LOADED, VIEW_IMAGE, ERROR_CAMERA, ERROR_MQTT }

enum ImageState { RECEIVED, WAITING }

const String infoPrefix = 'MyAPP ';

class TakePhoto extends StatefulWidget {
  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  var logger = Logger();

  static const List<String> commentPunto = [
    'La prueba esta correcta',
    'La prueba esta incorrecta'
  ];

  late List<CameraDescription> _cameras;
  CameraController? _controller;

  String? dropdownValue;

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
  bool _ready = false;
  bool _shoot = false;
  int _contador = 0;
  final int temporizador = 5;

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

    orgaInstrument = info.mainData
        .firstWhere((item) => item.orgaId == info.organization!.orgaId);

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

  void _savePuntoPrueba(BuildContext context, int value) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    bool found = false;

    PuntPrueba puntPrueba = new PuntPrueba(
      prueId: Util.generateUUID(),
      prueFecha: DateTime.now(),
      prueFoto1: imageBase64_1,
      prueFoto2: imageBase64_2,
      reviNumero: info.revision!.reviNumero,
      prueEnviado: 2,
      prueReviId: info.revision!.reviId,
      reviEntiId: info.revision!.reviEntiId,
      prueDescripcion: dropdownValue!,
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
                      info.revision?.reviId) {
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
                        .puntPrueba[l].prueFoto1 = puntPrueba.prueFoto1;

                    info.mainData[i].orgaInstrumentos[j].instVariables[k]
                        .puntPrueba[l].prueFoto2 = puntPrueba.prueFoto2;

                    info.mainData[i].orgaInstrumentos[j].instVariables[k]
                        .puntPrueba[l].prueEnviado = puntPrueba.prueEnviado;

                    info.mainDataUpdate(info.mainData);

                    return; // Elemento encontrado y modificado
                  }
                }

                if (!found)
                  info.mainData[i].orgaInstrumentos[j].instVariables[k]
                      .puntPrueba
                      .add(puntPrueba);
              }
            }
          }
        }
      }
    }

    info.pendingData = true;
    info.mainDataUpdate(info.mainData);
  }

  void _subscribeMaster() {
    mqttManager.subscribe(masterMqtt, (message) {
      final data = tramaDatosFromJson(message);

      switch (data.tipoMensaje) {
        case "IMAGE_CAMERA_1":
          break;
        case "TAKE_PHOTO":
          _contador = temporizador;
          _shoot = true;
          setState(() {});
          Timer.periodic(Duration(seconds: 1), (timer) {
            _contador--;
            setState(() {});
            if (_contador == 0) {
              _shoot = false;
              setState(() {});
              timer.cancel();
              _takePicture();
            }
          });

          break;

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
          break;

        case "TAKE_PHOTO":
          _contador = temporizador;
          _shoot = true;
          setState(() {});
          Timer.periodic(Duration(seconds: 1), (timer) {
            _contador--;
            setState(() {});
            if (_contador == 0) {
              _shoot = false;
              setState(() {});
              timer.cancel();
              _takePicture();
            }
          });

          break;

        case "READY":
          _ready = true;
          setState(() {});
          break;

        case "NO_READY":
          _ready = false;
          setState(() {});
          break;
      }
    });
  }

  Future<void> _publishMessage(String topic, TramaDatos message) async {
    final jsonData = jsonEncode(message);
    mqttManager.publish(masterMqtt, jsonData);
  }

  void sendState(bool ready){
    _tramaDatos.tipoMensaje = ready ? "READY": "NO_READY";
    _publishMessageAndRetain(masterMqtt, _tramaDatos );
  }

  Future<void> _publishMessageAndRetain(String topic, TramaDatos message ) async {
    final jsonData = jsonEncode(message);
    mqttManager.publishAndRetain(masterMqtt, jsonData);
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
    sendState(false);
    
    if (_controller != null && _controller!.value.isInitialized) {
      final XFile image = await _controller!.takePicture();
      final base64Image = await _convertImageToBase64(image.path);

      if (base64Image != null) {
        imageBase64_1 = base64Image;

        _tramaDatos.tipoMensaje = "IMAGE_CAMERA_1";
        _tramaDatos.imagen = imageBase64_1;
        _publishMessage(masterMqtt, _tramaDatos);

        _widgetState = WidgetState.VIEW_IMAGE;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return Scaffold(
          body: Center(child: circularProgressMain(),),
        );

      case WidgetState.LOADED:
        return _previewCamera(context);

      case WidgetState.VIEW_IMAGE:
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
      return Center(child: circularProgressMain());
    }

    final size = MediaQuery.of(context).size;

    sendState(true);

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
          top: 30,
          left: 10,
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black.withAlpha(51), // Fondo semitransparente
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    setHeaderTitle(orgaInstrument.orgaNombre, Colors.white),
                    setHeaderTitle(instrument.instNombre, Colors.white),
                    setHeaderSubTitle(variable.variNombre, Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 20,
          child: _ready ? Icon(
            MdiIcons.lanConnect,
            color: Colors.green,
            size: 36.0,
          ): Icon(
            MdiIcons.lanDisconnect,
            color: Colors.red,
            size: 36.0,
          ),
        ),

        _shoot? Center(
          child: Text(
            '$_contador',
            style: TextStyle(
              fontSize: 140, // Ajusta el tamaño del texto según tus necesidades
              fontWeight: FontWeight.bold,
              color: Colors.white, // Cambia el color del texto si es necesario
            ),
          ),
        ): SizedBox.shrink(),

      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          if(!_ready){
            showMsg("  SIN CONEXIÓN  ");
            return;
          }
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
            'Foto #1',
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
            'Foto #2',
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
                    child: circularProgressMain(),
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
          Center(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _commentList(context)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
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
              ),
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
                    if (dropdownValue == null) {
                      showError('Debe seleccionar un Comentario');
                      return;
                    }
                    _savePuntoPrueba(context, 2);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Aceptar',
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

  Widget _commentList(BuildContext context) {
    return InputDecorator(
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
        value: dropdownValue, // Objeto actual seleccionado
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
            dropdownValue = newValue;
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
    );
  }

  @override
  void dispose() {
    sendState(false);
    _controller?.dispose();
    super.dispose();
  }
}
