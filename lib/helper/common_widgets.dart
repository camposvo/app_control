import 'package:auto_size_text/auto_size_text.dart';
import 'package:control/pages/dashboard/dashboard.dart';
import 'package:control/pages/sendData.dart';
import 'package:control/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:control/providers/providers_pages.dart';
import 'package:control/helper/constant.dart';
import 'package:control/helper/shared_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'util.dart';

spaceForm({double height = 14.0}) {
  return SizedBox(
    height: height,
  );
}

paddingMain() {
  return EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0);
}

paddingContent() {
  return EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0);
}

paddingItemList() {
  return EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8);
}

formDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
  );
}

setSearchDecoration() {
  return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.all(0),
      prefixIcon: Icon(
        Icons.search,
        color: Colors.grey.shade500,
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      hintText: "Buscar");
}

setInputDecoration(
    {String hinttext = '',
    String helpertext = '',
    String labeltext = '',
   }) {
  return InputDecoration(
    // filled: true,
    // fillColor: Colors.white,
    labelText: labeltext == '' ? hinttext : labeltext,
    labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    border: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Colors.grey),
      borderRadius: BorderRadius.circular(10.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Colors.grey),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: AppColor.themeColor),
      borderRadius: BorderRadius.circular(10.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: AppColor.redColor),
      borderRadius: BorderRadius.circular(10.0),
    ),
    hintText: hinttext,
    helperText: helpertext,
    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
    suffixIcon: Icon(
      Icons.email,
      color: AppColor.secondaryColor,
      size: 18,
    ),
    prefixIcon: Icon(
      Icons.person,
      color: AppColor.secondaryColor,
      size: 18,
    ),
  );
}

setStyle({double size = 16.0}) {
  return TextStyle(
    color: Colors.black,
    fontSize: size,
  );
}

setStyleH1({double size = 24.0}) {
  return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: AppColor.secondaryColor);
}

setStyleH6({double size = 18.0}) {
  return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: AppColor.secondaryColor);
}

setNumberStyle() {
  return TextStyle(
      color: Colors.black, // Color de la fuente del texto que el usuario ingresa
      fontSize: 20.0,             // Tamaño de la fuente
      fontWeight: FontWeight.bold, // Peso de la fuente (ej. negrita)
      fontStyle: FontStyle.normal, // Estilo de la fuente (ej. cursiva)
      letterSpacing: 1,
  );
}


btnStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
      minimumSize: Size(MediaQuery.of(context).size.width, 60),
      shape: StadiumBorder(),
);
}

btnStyleSimple() {
  return ElevatedButton.styleFrom(
      shape: StadiumBorder(), backgroundColor: AppColor.themeColor);
}

btnSmall(bool state){
  if( state )// Accept
  return ElevatedButton.styleFrom(
      minimumSize: Size(100, 40),
      shape: StadiumBorder(),
      backgroundColor: AppColor.themeColor,
      textStyle: TextStyle(
          color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)
  );

  //Cancel
  return ElevatedButton.styleFrom(
      minimumSize: Size(100, 40),
      shape: StadiumBorder(),
      backgroundColor: Colors.white,
      textStyle: TextStyle(
        inherit: true,
          color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)
  );

}

btnStyleSimpleCancel() {
  return ElevatedButton.styleFrom(
      shape: StadiumBorder(), backgroundColor: Colors.white);
}

btnTextStyle() {
  return TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500);
}

btnTextCancel() {
  return TextStyle(
      color: AppColor.redColor, fontSize: 14, fontWeight: FontWeight.w500);
}

svgNoData(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
        ),
        SvgPicture.asset(
          "assets/login/no_data.svg",
          semanticsLabel: 'SVG Picture',
          width: MediaQuery.of(context).size.width - 80,
        ),
        spaceForm(),
        Text("No hay data", style: setStyleH6())
      ],
    ),
  );
}

circularProgress(Color color) {
  return SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 6,
      ));
}

circularProgressMain() {
  return SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(
        color: AppColor.themeColor,
        strokeWidth: 6,
      ));
}

verticalDiv(double height) {
  return Container(
    margin: EdgeInsets.only(right: 10, left: 10),
    height: height,
    color: Colors.grey[300],
    width: 2,
  );
}

setHeaderTitle(String title, dynamic color) {
  return new AutoSizeText(
    title,
    textDirection: SharedManager.shared.direction,
    style: new TextStyle(
      color: color,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

setHeaderSubTitle(String title, dynamic color) {
  return new AutoSizeText(
    title,
    textDirection: SharedManager.shared.direction,
    style: new TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

Widget setCommonText(String title, dynamic color, dynamic fontSize, dynamic fontWeight,
    dynamic noOfLine) {
  return  AutoSizeText(
    title,
    textDirection: SharedManager.shared.direction,
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
    maxLines: noOfLine,
    minFontSize: 12,
    maxFontSize: 24,
    overflow: TextOverflow.ellipsis,
  );
}

setCommonText2(String title, dynamic color, dynamic fontSize, dynamic fontweight,
    dynamic noOfLine) {
  return  AutoSizeText(
    title,
    textDirection: SharedManager.shared.direction,
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontweight,
    ),
    maxLines: noOfLine,
    minFontSize: 16,
    maxFontSize: 24,
    overflow: TextOverflow.ellipsis,
  );
}

setDrawer(BuildContext context) {
  return Drawer(
    width: 200.0,
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Menú',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        /*ListTile(
          leading: Icon(Icons.send),
          title: Text('Enviar'),
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SendData()),);
          },
        ),*/
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () async {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    ),
  );
}

setAppBarTwo(BuildContext context, String title) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white, // Cambia el color del icono a blanco
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
    backgroundColor: AppColor.themeColor,
    elevation: 1.0,
    //actions: setCommonCartNotificationView(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          setHeaderTitle(title, Colors.white),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    ),
  );
}

Future<bool> showConfirm(BuildContext context) async {
  final info = Provider.of<ProviderPages>(context, listen: false);

  return showDialog<bool>( // Cambia el tipo de retorno a Future<bool>
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmación'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('¿Estás seguro de que quieres Borrar Todo?'),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton( // Usamos ElevatedButton para el botón de cancelar
            child: const Text('Cancelar',style: TextStyle(
              color: Colors.white, // Color del texto
              // Puedes agregar más propiedades de TextStyle aquí
            )),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0), // Radio de 10.0
              ),
              backgroundColor: AppColor.redColor,
              padding: EdgeInsets.all(10.0),
            ),
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna falso al cancelar
            },
          ),
          const SizedBox(width: 8.0), // Opcional: Espacio entre los botones
          ElevatedButton( // Usamos ElevatedButton para el botón de confirmar
            child: const Text('Confirmar', style: TextStyle(
              color: Colors.white, // Color del texto
              // Puedes agregar más propiedades de TextStyle aquí
            ),),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0), // Radio de 10.0
              ),
              backgroundColor: AppColor.themeColor,
              padding: EdgeInsets.all(10.0),
            ),
            onPressed: () async {
              Navigator.of(context).pop(true); // Retorna verdadero al confirmar
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Maneja el caso en que el diálogo se cierra sin seleccionar una opción
}

Future<bool> showConfirmDelete(BuildContext context) async {
  final info = Provider.of<ProviderPages>(context, listen: false);

  return showDialog<bool>( // Cambia el tipo de retorno a Future<bool>
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmación'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('¿Estás seguro de borrar el Registro?'),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton( // Usamos ElevatedButton para el botón de cancelar
            child: const Text('Cancelar',style: TextStyle(
              color: Colors.white, // Color del texto
              // Puedes agregar más propiedades de TextStyle aquí
            )),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0), // Radio de 10.0
              ),
              backgroundColor: AppColor.redColor,
              padding: EdgeInsets.all(10.0),
            ),
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna falso al cancelar
            },
          ),
          const SizedBox(width: 8.0), // Opcional: Espacio entre los botones
          ElevatedButton( // Usamos ElevatedButton para el botón de confirmar
            child: const Text('Confirmar', style: TextStyle(
              color: Colors.white, // Color del texto
              // Puedes agregar más propiedades de TextStyle aquí
            ),),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0), // Radio de 10.0
              ),
              backgroundColor: AppColor.themeColor,
              padding: EdgeInsets.all(10.0),
            ),
            onPressed: () async {
              Navigator.of(context).pop(true); // Retorna verdadero al confirmar
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Maneja el caso en que el diálogo se cierra sin seleccionar una opción
}

Future<bool> showConfirmAccept(BuildContext context) async {
  final info = Provider.of<ProviderPages>(context, listen: false);

  return showDialog<bool>( // Cambia el tipo de retorno a Future<bool>
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmación'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('¿Estás seguro de Descartar las Fotos?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna falso al cancelar
            },
          ),
          TextButton(
            child: const Text('Confirmar'),
            onPressed: () async {
              Navigator.of(context).pop(true); // Retorna verdadero al confirmar
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Maneja el caso en que el diálogo se cierra sin seleccionar una opción
}

Future<void> showDialogMsg(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // No permitir cerrar tocando fuera
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message, textAlign: TextAlign.center, // Centrar el texto
                  style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton( // Usamos ElevatedButton para el botón de confirmar
            child: const Text('Aceptar', style: TextStyle(
              color: Colors.white, // Color del texto
              // Puedes agregar más propiedades de TextStyle aquí
            ),),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0), // Radio de 10.0
              ),
              backgroundColor: AppColor.themeColor,
              padding: EdgeInsets.all(10.0),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),

        ],
      );
    },
  );
}

setAppBarSubTitle(BuildContext context, String title, String subTitle) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white, // Cambia el color del icono a blanco
    ),
    centerTitle: true,
    leading: Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          //tooltip: MaterialLocalizations.of(context).menuBarMenuLabel,
        );
      },
    ),
    backgroundColor: AppColor.themeColor,
    elevation: 1.0,
    //actions: setCommonCartNotificationView(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
    ),
    bottom: PreferredSize(

      preferredSize: Size.fromHeight(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          setHeaderTitle(title, Colors.white),
          setHeaderSubTitle(subTitle, Colors.white),
          SizedBox(
            height: 0,
          ),
        ],
      ),
    ),
  );
}

AppBar setAppBarMain(BuildContext context, String title, String subTitle) {
  return AppBar(
    toolbarHeight: 80.0,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    centerTitle: false, // Alinea el título a la izquierda
    leading: Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      },
    ),
    backgroundColor: AppColor.themeColor,
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
    ),
    title: Column( // Usamos Column dentro de title para título y subtítulo
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda dentro de la columna.
      children: [
        setHeaderTitle(title, Colors.white),
        setHeaderSubTitle(subTitle, Colors.white),

      ],
    ),
  );
}

Future<void> showError(String msg) async {
  await Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    timeInSecForIosWeb: 2,
    gravity: ToastGravity.CENTER,
  );
}

Future<void> showMsg(String msg) async {
  await Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: AppColor.secondaryColor,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

void showWarning(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.orangeAccent,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

void showMsgCamera(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black.withAlpha(51),
      textColor: Colors.white,
      fontSize: 16.0
  );
}
