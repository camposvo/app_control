import 'dart:convert';
import 'dart:io';

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
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late Future<void> _initializeCamera;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      _cameras = cameras;
      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      _requestCameraPermission();

    });
  }


  Future<void> _requestCameraPermission() async {
    // Solicita el permiso para la cámara
    final status = await Permission.camera.request();

    if (status == PermissionStatus.granted) {
      // El permiso fue otorgado, puedes inicializar la cámara
      _initializeCamera =  _controller.initialize();
    } else if (status == PermissionStatus.denied) {
      // El permiso fue denegado
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permiso denegado'),
          content: Text('Necesitas otorgar permiso a la cámara para usar esta función.'),
        ),
      );
    } else if (status == PermissionStatus.permanentlyDenied) {
      // El permiso fue denegado permanentemente
      openAppSettings();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    // Asegurarse de que la cámara esté inicializada
    await _initializeCamera;

    // Obtener la ruta donde se guardará la imagen
    final directory = await getApplicationDocumentsDirectory();
    final String imagePath = '${directory.path}/${DateTime.now()}.jpg';

    final image = await _controller.takePicture();
    final File imageFile = File(image.path);

    // Convertir la imagen a base64
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCamera,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Cámara inicializada, mostrar la vista previa
          return CameraPreview(_controller);
        } else {
          // Mostrar un indicador de carga mientras se inicializa la cámara
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}