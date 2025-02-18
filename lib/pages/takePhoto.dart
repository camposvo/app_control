import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../models/orgaInstrumento.dart';
import '../providers/providers_pages.dart';

class TakePhoto extends StatefulWidget {
  @override
  _TakePhotoState createState() => _TakePhotoState();
}

enum WidgetState { NONE, LOADING, LOADED, CAPTURE, ERROR_CAMERA, ERROR_MQTT }

enum ImageState { RECEIVED, WAITING }

class _TakePhotoState extends State<TakePhoto> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  final client = MqttServerClient('manuales.ribe.cl', '');
  XFile? _image;
  WidgetState _widgetState = WidgetState.NONE;
  ImageState imageState = ImageState.WAITING;

  String imageBase64_1 = "";
  String imageBase64_2 = "";
  String comment = '';

  String errorMqtt = '';

  String topicTake = '/TAKE_PHOTO';
  String topicSending = '/SENDING_PHOTO';

  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento organization;
  late InstVariable variable;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

    final info = Provider.of<ProviderPages>(context, listen: false);

    organization =
        info.organizations.firstWhere((item) => item.orgaId == info.orgaId);
    instrument = organization.orgaInstrumentos
        .firstWhere((item) => item.instId == info.instId);
    variable = instrument.instVariables
        .firstWhere((item) => item.variId == info.varId);

    final mainTopic = info.mainTopic;
    topicTake = mainTopic + topicTake;
    topicSending = mainTopic + topicSending;

    final resultCamera = await _initializeCamera();
    if (resultCamera == 0) {
      _widgetState = WidgetState.ERROR_CAMERA;
      setState(() {});
      return;
    }

    final resultMqtt = await _initMQTT();

    if (resultMqtt == 0) {
      _widgetState = WidgetState.ERROR_MQTT;
      setState(() {});
      return;
    }

    _widgetState = WidgetState.LOADED;
    setState(() {});
  }

  Future<int> _initializeCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.high,
      );
      await _controller!.initialize();

      if (_controller!.value.hasError) {
        return 0;
      }
    }

    return 1;
  }

  Future<int> _initMQTT() async {
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.secure = true;
    client.port = 8883;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000; // milliseconds

    try {
      final connMessage = await client.connect("root", "*R1b3x#99");
      print("client connecting result $connMessage");
    } on NoConnectionException catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
      errorMqtt = e.toString();
      _widgetState = WidgetState.ERROR_MQTT;
      setState(() {});
      return 0;
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      print(
          'ERROR Mosquitto client connection failed - status is ${client.connectionStatus}');
      client.disconnect();
      return 0;
      //exit(-1);
    }

    client.subscribe(topicTake, MqttQos.atLeastOnce);
    client.subscribe(topicSending, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('topic is <${c[0].topic}>, payload is <-- $pt -->');

      final _topic = c[0].topic;

      if (_topic == topicTake) {
        _takePicture();
      }

      if (_topic == topicSending) {
        imageBase64_2 = pt;
        imageState = ImageState.RECEIVED;
        setState(() {});
      }
    });

    return 1;
  }

  Future<void> _publishMessage(String msg) async {
    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      print('ERROR Mosquitto client connection ${client.connectionStatus}');
      client.disconnect();
      //exit(-1);
    }

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(msg);

    if (builder.payload != null) {
      client.publishMessage(topicTake, MqttQos.atLeastOnce, builder.payload!);
    } else {}
  }

  void onConnected() {
    print('Connected');
    client.subscribe('mytopic', MqttQos.atLeastOnce);
  }

  void onDisconnected() {
    print('Disconnected');
    print('client disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

  void onMessage(String topic, MqttMessage message) {
    final payload = message;
    print('Received message: $payload from topic: $topic');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
      // Convertir la imagen a Base64
      print(image.path);
      final base64Image = await _convertImageToBase64(image.path);

      if (base64Image != null) {
        imageBase64_1 = base64Image;
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
      case WidgetState.NONE:
        return _buildScaffold(
            context,
            Center(
              child: CircularProgressIndicator(),
            ));

      case WidgetState.LOADING:
        return _buildScaffold(
            context,
            Center(
              child: CircularProgressIndicator(),
            ));

      case WidgetState.LOADED:
        return previewCamera(context);

      case WidgetState.CAPTURE:
        return _buildScaffold(context, _capture(context));

      case WidgetState.ERROR_CAMERA:
        return Center(
          child: Text("La cámara No se pudo Cargar. Reincie la App"),
        );

      case WidgetState.ERROR_MQTT:
        return _buildScaffold(
            context,
            Center(
              child: Text("Error con MQTT: $errorMqtt"),
            ));
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
                setHeaderTitle(organization.orgaNombre, Colors.white),
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

  Widget previewCamera(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.themeColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              setHeaderTitle(organization.orgaNombre, Colors.white),
              setHeaderTitle(instrument.instNombre, Colors.white),
              setHeaderSubTitle(variable.variNombre, Colors.white),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
      body: Scaffold(
          body: Stack(children: [
        SizedBox(
          // Usamos SizedBox para controlar el tamaño
          width: size.width,
          height: size.height,
          child: RotatedBox(
            // Rotamos *dentro* del SizedBox
            quarterTurns: 1, // 1 para 90 grados, 2 para 180, etc.
            child: CameraPreview(_controller!),
          ),
        ),
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          _widgetState = WidgetState.LOADING;
          setState(() {});
          _publishMessage("TAKE_PHOTO_CAMARA_2");
        }),
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _capture(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Cámara Principal',
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
            'Cámara Testigo',
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
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
              ),
              IconButton(
                onPressed: () {
                  // Lógica para deshacer
                  setState(() {
                    comment = '';
                  });
                },
                icon: const Icon(Icons.undo),
              ),
              IconButton(
                onPressed: () {
                  // Lógica para rechazar
                  print('Comentario rechazado: $comment');
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
