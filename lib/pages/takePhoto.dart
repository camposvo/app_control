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

class TakePhoto extends StatefulWidget {
  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  final client = MqttServerClient('manuales.ribe.cl', '');
  XFile? _image;


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Solicitar permisos de cámara
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
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.secure = true;
    client.port =  8883;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000; // milliseconds

    try {
      final connMessage = await client.connect("root", "*R1b3x#99");
      print("client connecting result $connMessage");
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {

      print(
          'ERROR Mosquitto client connection failed - status is ${client.connectionStatus}');
      client.disconnect();
      //exit(-1);
    }

    print('EXAMPLE::Subscribing to the test/lol topic');
    client.subscribe("B65/#", MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {});
      print('topic is <${c[0].topic}>, payload is <-- $pt -->');

    });

    client.published!.listen((MqttPublishMessage message) {
      print(
          'notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('Este es mi mensaje publicado');

// Publica el mensaje
    final String topic = 'your/topic'; // Replace with your topic
    if (builder.payload != null) {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }else{

    }


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
        // Guardar la cadena Base64 (puedes guardarla en una variable, enviarla a un servidor, etc.)
        //print(base64Image);
        developer.log(base64Image);

        // Mostrar la imagen (opcional)
        setState(() {
          _image = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    print("orientation");
    print(orientation);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cámara'),
      ),
      body: Scaffold(
          body: Stack(children: [
            SizedBox( // Usamos SizedBox para controlar el tamaño
              width: size.width,
              height: size.height,
              child: RotatedBox( // Rotamos *dentro* del SizedBox
                quarterTurns: 1, // 1 para 90 grados, 2 para 180, etc.
                child: CameraPreview(_controller!),
              ),
            ),
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }
}
