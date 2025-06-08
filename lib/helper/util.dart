import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

const String infoPrefix = 'MyAPP ';

class Util {

  Util() {}

  static Future<String?> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String? deviceId;

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidDeviceInfo =
        await deviceInfoPlugin.androidInfo;
        deviceId = androidDeviceInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosDeviceInfo.identifierForVendor;
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }

    return deviceId;

  }


  static void printInfo(String title, String msg) {
    var logger = Logger(
      printer: PrettyPrinter(),
    );

    logger.i('$infoPrefix $title: $msg');

    return;
  }

  static String formatearFecha(DateTime fecha) {
    // Crear un nuevo objeto DateTime con la hora a las 00:00:00
    DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

    // Formatear la fecha en el formato deseado (yyyy-MM-dd HH:mm:ss)
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String fechaFormateada = formatter.format(fechaSinHora);

    return fechaFormateada;
  }

  static String getPrettyJSONString(Object jsonObject) {
    dynamic result = JsonEncoder.withIndent('  ').convert(jsonObject);

    if (result == 'null') return '';

    return result;
  }

  static String formatDate(DateTime fecha) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formatted = formatter.format(fecha);
    return formatted;
  }

  static String formatDateTime(DateTime fecha) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy - H:mm');
    final String formatted = formatter.format(fecha);
    return formatted;
  }

   static String formatTime(DateTime fecha) {
    final DateFormat formatter = DateFormat('H:mm');
    final String formatted = formatter.format(fecha);
    return formatted;
  }

  static String formatDatePg(DateTime fecha) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(fecha);
    return formatted;
  }

  static String formatDateTimePg(DateTime fecha) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd H:mm:ss');
    final String formatted = formatter.format(fecha);
    return formatted;
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  static Future<String> imagetoBase64(String imagepath) async {
    File imagefile = File(imagepath); //convert Path to File
    Uint8List imagebytes = await imagefile.readAsBytes();
    String header = "data:image/png;base64,";//convert to bytes
    String base64string = base64.encode(imagebytes); //convert bytes to base64 string
    return header + base64string;
  }

  static Uint8List dataFromBase64String(String base64String) {
    // Convert to UriData
    final UriData? data = Uri.parse(base64String).data;
    // You can check if data is normal base64 - should return true
    // Will returns your image as Uint8List
    Uint8List myImage = data!.contentAsBytes();
    return myImage;
  }

  static String generateUUID() {
    var uuid = Uuid();
    return uuid.v4(); // Genera un UUID versión 4 (aleatorio)
  }

  static int isUrlOrBase64(String cadena) {
    if (cadena.startsWith('http://') || cadena.startsWith('https://')) {
      // Es una URL
      return 1;
    }

    try {
      // Intenta decodificar como Base64
      base64Decode(cadena);
      // Si no hay excepción, es Base64 válido
      return 2;
    } catch (e) {
      // No es Base64 válido
      return -1;
    }
  }

  static String geenerateCode(int longitud) {
    const caracteres =
        'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    Random random = Random();
    return String.fromCharCodes(
      List.generate(longitud, (index) => caracteres.codeUnitAt(
          random.nextInt(caracteres.length))),
    );
  }

  static double? parseDynamicToDouble(dynamic value) {
    if (value == null) {
      return null; // O puedes lanzar una excepción o devolver un valor por defecto
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble(); // Los enteros también son válidos para operaciones con double
    }

    if (value is String) {
      try {
        final parsedValue = double.parse(value);
        if (parsedValue.isNaN || parsedValue.isInfinite) {
          return null; // No es un double válido (NaN o infinito)
        }
        return parsedValue;
      } catch (e) {
        return null; // La cadena no se pudo parsear a double
      }
    }

    return null; // No es un tipo que podamos convertir a double de forma segura
  }

  static tz.TZDateTime convertUtcASantiago(DateTime utcDate) {
    tzdata.initializeTimeZones();

    tz.Location santiago = tz.getLocation('America/Santiago');
    tz.TZDateTime santiagoDate = tz.TZDateTime.from(utcDate, santiago);

    return santiagoDate;
  }

  static double? parsedDouble( String inputText) {
    double? parsedValue;
    String? errorMessage;

    // Eliminar caracteres no numéricos o no comas (si los hubiera, aunque el formatter ya ayuda)
    String cleanedText = inputText.replaceAll(RegExp(r'[^\d,]'), '');

    // Reemplazar la coma por un punto para que double.tryParse lo entienda
    String dotSeparatedText = cleanedText.replaceAll(',', '.');

    if (dotSeparatedText.isEmpty) {
      parsedValue = null;
      errorMessage = null;
    } else {
      parsedValue = double.tryParse(dotSeparatedText);
      if (parsedValue == null) {
        // Si no se pudo parsear pero hay texto, significa un formato inválido
        errorMessage = 'Formato numérico inválido (ej: 123,45)';
      } else {
        errorMessage = null;
      }
    }

    return parsedValue;
  }

}

