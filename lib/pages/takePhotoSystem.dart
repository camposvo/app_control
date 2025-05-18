import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:control/models/resultRevision.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/mqttManager.dart';
import '../models/orgaInstrumento.dart';
import '../providers/providers_pages.dart';
import 'dart:developer' as developer;
import 'package:control/helper/util.dart';
import 'package:path/path.dart' show join;

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

enum WidgetState { LOADED, VIEW_IMAGE, ERROR_CAMERA, ERROR_MQTT }

enum ImageState { RECEIVED, WAITING }

const String infoPrefix = 'MyAPP ';

class TakePhotoSystem extends StatefulWidget {
  final String? prueId;

  const TakePhotoSystem({super.key, this.prueId});


  @override
  _TakePhotoSystemState createState() => _TakePhotoSystemState();
}

class _TakePhotoSystemState extends State<TakePhotoSystem> {

  bool isLoading = true;
  bool isFinish = false;

  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento orgaInstrument;
  late InstVariable variable;
  double valueMqtt = 0.0;
  DateTime dateMqtt = DateTime.now();
  DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
  String formattedDate ="NO DATA";
  String formattedValue ="NO DATA";

  Timer? _timerOut;
  int setTimeOut = 20;
  int maxTimeOut = 20;




  static const List<String> commentPunto = [
    'La prueba esta correcta',
    'La prueba esta incorrecta'
  ];

   late List<CameraDescription> _cameras;
  CameraController? _controller;
  ScreenshotController screenshotController = ScreenshotController();

  WidgetState _widgetState = WidgetState.LOADED;
  ImageState imageState = ImageState.WAITING;
  String imageBase64_1 = "";
  String comment = '';
  String? dropdownValue;

  final mqttManager = MqttManager(
    broker: 'manuales.ribe.cl',
    port: 8883,
    username: 'root',
    password: '*R1b3x#99',
  );


  String errorMqtt = '';

  //topic for General Message Interchange
  String masterMqtt = '';

  String? prueId = null;


  @override
  void initState() {
    super.initState();
    prueId = widget.prueId;
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

    masterMqtt = info.organization!.orgaPrefijo +'/'+ instrument.instAbreviatura;

    //masterMqtt = "A55/M45";

/*    Util.printInfo("VARIABLE", jsonEncode(variable));
    Util.printInfo("TOPIC", masterMqtt);*/

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
    } catch (e) {
      print("Error initializing MQTT: $e");
      return 0;
    }
    return 1;
  }

  void _saveResult(BuildContext context, int value) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    bool found = false;

    //Guarda los datos en la variable para Enviarlos
   /* Prueba test = Prueba(
      prueId: Util.generateUUID(),
      pruePuntId: variable.puntId,
      prueFecha: DateTime.now(),
      prueRecurso1: imageBase64_1,
      prueRecurso2: "",
      reviNumero: info.revision!.reviNumero,
      prueReviId: info.revision!.reviId,
      prueComentario: dropdownValue!,
      prueValor1: null,
      prueValor2: null,
    );
    info.resultData.pruebas.add(test);
    info.resultDataUpdate(info.resultData);*/

    //Guarda los datos en la estructura de datos principal
    PuntPrueba puntPrueba = new PuntPrueba(
      prueId: Util.generateUUID(),
      prueFecha: DateTime.now(),
      prueFoto1: imageBase64_1,
      prueFoto2: "",
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

  tz.TZDateTime convertUtcASantiago(DateTime utcDate) {
    tzdata.initializeTimeZones();

    tz.Location santiago = tz.getLocation('America/Santiago');
    tz.TZDateTime santiagoDate = tz.TZDateTime.from(utcDate, santiago);

    return santiagoDate;
  }

  void _subscribeMaster() {
    mqttManager.subscribe(masterMqtt, (message) {
/*      Util.printInfo("MENSAJE", message);
      Util.printInfo("VARIABLE", variable.variAbreviatura);*/

      final index = variable.variAbreviatura;

      try {
      final Map<String, dynamic> jsonData = jsonDecode(message);

      valueMqtt = jsonData[index]["value"].toDouble();
      dateMqtt = DateTime.parse(jsonData[index]["fecha"]);

      final santiagoDate = convertUtcASantiago(dateMqtt);

      formattedValue = valueMqtt.toString();
      formattedDate = formatter.format(santiagoDate);

      setState(() {});


      } on FormatException catch (e) {
        formattedValue = "NO DATA";
        formattedDate = "NO DATA";
        setState(() {});
        // Manejar el error de formato JSON
        Util.printInfo("Error al decodificar JSON", e.toString());
      } catch (e) {

        formattedValue = "NO DATA";
        formattedDate = "NO DATA";
        setState(() {});
        // Manejar otros errores (por ejemplo, claves faltantes)
        Util.printInfo("Error al procesar JSON", e.toString());
      }


    });
  }

  void preTimeTakePhoto(){
    _takePicture();
  }

  Future<void> _takePicture() async {


    if (_controller != null && _controller!.value.isInitialized) {



      try {
        screenshotController.capture().then((capturedImage) async {
          if (capturedImage != null) {
            final directory = await getApplicationDocumentsDirectory();
            final imagePath = join(directory.path, '${DateTime.now()}.png');
            final imageFile = File(imagePath);
            await imageFile.writeAsBytes(capturedImage); //Write Image in File

            String base64Image = base64Encode(capturedImage);

            if (base64Image != null) {
              imageBase64_1 = base64Image;

              _widgetState = WidgetState.VIEW_IMAGE;
              setState(() {});
            }

          }
        });
      } catch (e) {
        print(e);
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
      body: Screenshot(
        controller: screenshotController,
        child: Stack(children: [
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
                      setHeaderSubTitle("Valor: "+formattedValue, Colors.white),
                      setHeaderSubTitle("Fecha: "+formattedDate, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          _takePicture();

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
    mqttManager.unsubscribe(masterMqtt);
    _controller?.dispose();
    super.dispose();
  }
}
