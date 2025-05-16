import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:control/models/tramaDatos.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/mqttManager.dart';
import '../models/orgaInstrumento.dart';
import '../models/resultRevision.dart';
import '../providers/providers_pages.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:control/helper/util.dart';

enum WidgetState { LOADED, VIEW_IMAGE, ERROR_CAMERA, ERROR_MQTT }

enum ImageState { RECEIVED, WAITING }

const String infoPrefix = 'MyAPP ';

class TakePhoto extends StatefulWidget {

  final String? idTest;

  const TakePhoto({super.key, this.idTest});

  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {

  bool isLoading = true;
  bool isFinish = false;

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  Timer? _timerConnection;

  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento orgaInstrument;
  late InstVariable variable;
  static const List<String> commentPunto = [
    'La prueba esta correcta',
    'La prueba esta incorrecta'
  ];

  late List<CameraDescription> _cameras;
  CameraController? _controller;

  WidgetState _widgetState = WidgetState.LOADED;
  ImageState imageState = ImageState.WAITING;
  String imageBase64_1 = "";
  String imageBase64_2 = "";
  String comment = '';
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
      cameraReady: false,
      connetionReady: false,
      countDown: 0,
      isApproved: false,
  );

  int _contador = 0;
  int _countDown = 0;
  bool _showCounter = false;
  bool _cameraLocalReady = false;
  bool _cameraRemoteReady = false;
  bool _connRemoteReady = false;
  String errorMqtt = '';

  //topic for General Message Interchange
  String masterMqttFinish = '_MASTER_FINISH';
  String masterMqtt = '_MASTER';
  String slaveMqtt = '_SLAVE';

  //Special topic for Connection Message Interchange
  String masterConnMqtt = '_MASTER_CONN';
  String slaveConnMqtt = '_SLAVE_CONN';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {

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

    masterConnMqtt = mainTopic + masterConnMqtt;
    slaveConnMqtt = mainTopic + slaveConnMqtt;

    masterMqttFinish =  mainTopic + masterMqttFinish;

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
    _tramaDatos.orgaId = info.organization!.orgaId;
    _tramaDatos.instId =  info.instId;
    _tramaDatos.variNombre = variable.variNombre;
    _tramaDatos.variId = info.varId;
    _tramaDatos.subuAbreviatura = variable.subuAbreviatura;
    _tramaDatos.cameraReady = _cameraLocalReady;
    _tramaDatos.countDown = _countDown;

    _tramaDatos.tipoMensaje = "START_CONNECTION";
    _publishMessage(masterMqtt, _tramaDatos);

    _timerConnection = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      sendStateConnection(true, _cameraLocalReady);
    });

    isLoading = false;
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
      _subscribeMasterFinish();
      //_subscribeSlaveConn();
      //_subscribeMasterConn();
    } catch (e) {
      print("Error initializing MQTT: $e");
      return 0;
    }
    return 1;
  }

  void _saveResult(BuildContext context, int value) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    bool found = false;


   /* Prueba test = new Prueba(
      prueId: Util.generateUUID(),
      pruePuntId: variable.puntId,
      prueFecha: DateTime.now(),
      prueRecurso1: imageBase64_1,
      prueRecurso2: "",
      reviNumero: info.revision!.reviNumero,
      prueReviId: info.revision!.reviId,
      prueComentario: dropdownValue!,

    );
    info.resultData.pruebas.add(test);

    info.resultDataUpdate(info.resultData);*/

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
      prueActivo: 1,
      prueValor1: 2.0,
      prueValor2: 2.0,
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

/*  void sendStateConnection(bool value){
    _tramaDatos.tipoMensaje = "STATE_CONNECTION";
    _tramaDatos.connetionReady = value;

    Util.printInfo("topio", masterConnMqtt);
    Util.printInfo("tipo", _tramaDatos.tipoMensaje);
    Util.printInfo("tipo", _tramaDatos.connetionReady.toString());

    _publishMessageAndRetain(masterConnMqtt, _tramaDatos );
  }*/

  void sendStateConnection(bool conn, bool cameraState){
    _tramaDatos.tipoMensaje = "STATE_CONNECTION";
    _tramaDatos.connetionReady = conn;
    _tramaDatos.cameraReady = cameraState;

    _publishMessage(masterMqtt, _tramaDatos );
  }

  void sendCountDown(int countDown){
    _tramaDatos.tipoMensaje = "TIMER";
    _tramaDatos.countDown = _countDown;
    _publishMessage(masterMqtt, _tramaDatos );
  }

  void sendCameraReady(bool  value){
    _tramaDatos.tipoMensaje = "CAMERA_READY";
    _tramaDatos.cameraReady = value;
    _publishMessage(masterMqtt, _tramaDatos );
  }

  Future<void> sendFinishPhoto(bool  value) async {
    Util.printInfo("Publico el Mensaje", "PASO") ;

    final String message = value ? 'APPROVE': 'REJECTED';
    mqttManager.publish(masterMqttFinish, message);
  }

  void _subscribeMaster() {
    mqttManager.subscribe(masterMqtt, (message) {
      final data = tramaDatosFromJson(message);


      switch (data.tipoMensaje) {
        case "IMAGE_CAMERA_1":
          break;
        case "TAKE_PHOTO":
          preTimeTakePhoto();
          break;

        case "FINISH_PHOTO":

          break;

      }
    });
  }

  void _subscribeSlave() {
    mqttManager.subscribe(slaveMqtt, (message) {
      final data = tramaDatosFromJson(message);


      switch (data.tipoMensaje) {

        case "START_CONNECTION":
          if (mounted) {
            setState(() {
              _countDown = data.countDown;
              _cameraRemoteReady = data.cameraReady;
              _connRemoteReady = true;
            });
          }
          break;

        case "STATE_CONNECTION":
          if(_cameraRemoteReady != data.cameraReady || _connRemoteReady != data.connetionReady ){

            if (mounted) {
              setState(() {

                _cameraRemoteReady = data.cameraReady;
                _connRemoteReady = data.connetionReady;
              });
            }
          }

          break;

        case "TIMER":
          if (mounted) {
            setState(() {
              _countDown = data.countDown;
            });
          }
          break;

        case "CAMERA_READY":
          if (mounted) {
            setState(() {
              _cameraRemoteReady = data.cameraReady;
            });
          }
          break;

        case "IMAGE_CAMERA_2":
          if (mounted) {
            setState(() {
              imageBase64_2 = data.imagen;
              imageState = ImageState.RECEIVED;
            });
          }
          break;

        case "TAKE_PHOTO":
          preTimeTakePhoto();
          break;



       
      }
    });
  }

  void _subscribeMasterFinish() {
    mqttManager.subscribe(masterMqttFinish, (message) {

      Util.printInfo("Entro a Salir", "SALIR");


      switch (message) {

        case "APPROVE":

          break;

        case "REJECTED":

          break;
      }
    });
  }

  void _subscribeSlaveConn() {
    mqttManager.subscribe(slaveConnMqtt, (message) {
      final data = tramaDatosFromJson(message);

      switch (data.tipoMensaje) {
        case 'STATE_CONNECTION' :
          if (data.connetionReady == _connRemoteReady) {
            Util.printInfo("mallllllllllll", _connRemoteReady.toString());
            break;
          }

          _connRemoteReady = data.connetionReady;
          setState(() {});
          Util.printInfo("paso", _connRemoteReady.toString());
          break;

        default:
          Util.printInfo("CAYO EN DEFAULT", data.tipoMensaje);
      }

    });
  }

  void _subscribeMasterConn() {
    mqttManager.subscribe(masterConnMqtt, (message) {
      final data = tramaDatosFromJson(message);


      switch (data.tipoMensaje) {
        case 'STATE_CONNECTION' :
          if (data.connetionReady == _connRemoteReady) {

            break;
          }

          _connRemoteReady = data.connetionReady;
          setState(() {});
          Util.printInfo("paso", _connRemoteReady.toString());
          break;

        default:
          Util.printInfo("CAYO EN DEFAULT", data.tipoMensaje);
      }

    });
  }


  Future<void> _publishMessage(String topic, TramaDatos message) async {
    final jsonData = tramaDatosToJson(message);
    mqttManager.publish(masterMqtt, jsonData);
  }

  Future<void> _publishMessageAndRetain(String topic, TramaDatos message ) async {
    final jsonData = tramaDatosToJson(message);
    mqttManager.publishAndRetain(masterConnMqtt, jsonData);
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

  void preTimeTakePhoto(){

    if(_countDown == 0){
      _takePicture();
      return;
    }

    _contador = _countDown;
    _showCounter = true;
    setState(() {});
    Timer.periodic(Duration(seconds: 1), (timer) {

      if (_contador == 0) {
        timer.cancel();
        _showCounter = false;
        setState(() {});
        _takePicture();
      }

      _contador--;
      setState(() {});

    });
  }

  Future<void> _takePicture() async {
    _timerConnection?.cancel();

    if (_controller != null && _controller!.value.isInitialized) {
      final XFile image = await _controller!.takePicture();
      final base64Image = await _convertImageToBase64(image.path);

      if (base64Image != null) {
        imageBase64_1 = base64Image;

        _widgetState = WidgetState.VIEW_IMAGE;
        setState(() {});

        _tramaDatos.tipoMensaje = "IMAGE_CAMERA_1";
        _tramaDatos.imagen = imageBase64_1;
        _publishMessage(masterMqtt, _tramaDatos);


      }
    }
  }

  @override
  Widget build(BuildContext context) {

    switch (_widgetState) {

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
      return Center(child: circularProgress(Colors.white));
    }
    final size = MediaQuery.of(context).size;
    //sendStateConnection(true);
    double? marginRight = 20;

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
          top: 40,
          right: marginRight,
          child: Icon(
            _cameraRemoteReady ? MdiIcons.accountCheck : MdiIcons.accountOff,
            color: _cameraRemoteReady ? Colors.white : Colors.red ,
            size: 36.0,
          )
        ),
        Positioned(
          top: 40,
          right: marginRight + 40,
          child: Icon(
            _connRemoteReady? MdiIcons.lanConnect:MdiIcons.lanDisconnect ,
            color: _connRemoteReady ? Colors.white : Colors.red ,
            size: 36.0,
          )
        ),
        _showCounter? Center(
          child: Text(
            '$_contador',
            style: TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ): SizedBox.shrink(),
        Positioned(
          bottom: 115,
          right: marginRight + 110,
          child: Text(_countDown.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),),
        ),
        Positioned(
          bottom: 100,
          right: marginRight + 70,
          child: _showTimer(context),
        ),
        Positioned(
            bottom: 107,
            right: marginRight,
            child: IconButton(
                onPressed: () {
                  _cameraLocalReady = ! _cameraLocalReady;
                  setState(() {});
                  if(_cameraLocalReady) showMsgCamera("  CAMARA ACTIVADA !!  ");
                  else showMsgCamera("CAMARA DESACTIVADA !!");

                  sendCameraReady( _cameraLocalReady);
                },
                icon: Icon(
                  _cameraLocalReady ? MdiIcons.camera : MdiIcons.cameraOff,
                  color: Colors.white,
                  size: 36.0,
                )
            )
        ),
        if(isLoading)
          Stack( // Usamos otro Stack para superponer el loader sobre ModalBarrier
            children: [
              ModalBarrier( // Bloquear la interacción
                color: Colors.black.withValues(alpha: 0.5),
                dismissible: false,
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
      ]),

      floatingActionButton: FloatingActionButton(
        onPressed: (() {
     /*     if(!_connRemoteReady){
            showMsgCamera("  SIN CONEXIÓN  !!");
            return;
          }

          if(!_cameraLocalReady){
            showMsgCamera("  CAMARA LOCAL NO ESTA ACTIVADA!!  ");
            return;
          }

          if(!_cameraRemoteReady){
            showMsgCamera("CAMARA REMOTA NO ESTA ACTIVA !!");
            return;
          }*/

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
          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller1,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              decoration: InputDecoration(labelText: 'Valor Foto #1'),
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
          (imageState == ImageState.WAITING)
              ? SizedBox(
                  height: 500,
                  child: Center(
                    child: circularProgressMain(),
                  ),
                )
              : Column(
                children: [
                  InteractiveViewer(
                      minScale: 0.5, // Define el zoom mínimo (opcional)
                      maxScale: 3.0, // Define el zoom máximo (opcional)
                      child: Image.memory(
                        base64Decode(imageBase64_2),
                        height: 500,
                        fit: BoxFit.contain, // Importante: Usa BoxFit.contain
                      ),
                    ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _controller2,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      decoration: InputDecoration(labelText: 'Valor Foto #2'),
                    ),
                  ),
                ],
              ),
          _showCalculate(context),
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
                  onPressed: () async {
                    final result = await showConfirmAccept(context);

                    if (!result){
                      return;
                    }

                    sendFinishPhoto(false);
                    showError("Fotos Descartada");
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
                    _saveResult(context, 2);
                    sendFinishPhoto(true);
                    showMsg("Fotos Aceptadas");
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

  Widget _showCalculate(BuildContext context ){

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Calculo: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(" #####.###",  style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),),
      ],
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

  Widget _showTimer(BuildContext context){
    return Column(
      children: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String opcion) {
            setState(() {
              _countDown = int.parse(opcion);
              sendCountDown(_countDown);
              setState(() {});
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: '3',
              child: Center(child: Text('3')),
            ),
            const PopupMenuItem<String>(
              value: '0',
              child: Center(
                child: Text('0',
                ),
              ),
            ),
          ],
          offset: Offset(0, -120), // Ajusta el desplazamiento vertical
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: BoxConstraints(
            minWidth: 40, // Usa el ancho del botón
            maxWidth: 40,
          ),
          child:  Icon(
            MdiIcons.cameraTimer,
            color: Colors.white,
            size: 36.0,
          ),
        ),

        SizedBox(height: 16),
        //Text('Opción seleccionada: $opcionSeleccionada'),
      ],
    );
  }

  @override
  void dispose() {
    _timerConnection?.cancel();
    sendStateConnection(false, false);
    _controller?.dispose();
    super.dispose();
  }
}
