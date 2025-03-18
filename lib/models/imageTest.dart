// To parse this JSON data, do
//
//     final imageTest = imageTestFromJson(jsonString);

import 'dart:convert';

ImageTest imageTestFromJson(String str) => ImageTest.fromJson(json.decode(str));

String imageTestToJson(ImageTest data) => json.encode(data.toJson());

class ImageTest {
  String recuId;
  String recuNombre;
  String recuSize;
  String recuPath;
  String recuMimetype;
  DateTime recuUploadDate;
  String recuExtension;
  String fileFull;
  String fileThumbnail;

  ImageTest({
    required this.recuId,
    required this.recuNombre,
    required this.recuSize,
    required this.recuPath,
    required this.recuMimetype,
    required this.recuUploadDate,
    required this.recuExtension,
    required this.fileFull,
    required this.fileThumbnail,
  });

  factory ImageTest.fromJson(Map<String, dynamic> json) => ImageTest(
    recuId: json["recu_id"],
    recuNombre: json["recu_nombre"],
    recuSize: json["recu_size"],
    recuPath: json["recu_path"],
    recuMimetype: json["recu_mimetype"],
    recuUploadDate: DateTime.parse(json["recu_upload_date"]),
    recuExtension: json["recu_extension"],
    fileFull: json["fileFull"],
    fileThumbnail: json["fileThumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "recu_id": recuId,
    "recu_nombre": recuNombre,
    "recu_size": recuSize,
    "recu_path": recuPath,
    "recu_mimetype": recuMimetype,
    "recu_upload_date": recuUploadDate.toIso8601String(),
    "recu_extension": recuExtension,
    "fileFull": fileFull,
    "fileThumbnail": fileThumbnail,
  };
}
