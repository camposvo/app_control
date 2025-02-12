import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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

circularProgress() {
  return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 1.5,
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
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

Widget setCommonText(String title, dynamic color, dynamic fontSize, dynamic fontweight,
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





/*
setAppBarMain(BuildContext context, String title) {
  final info = Provider.of<ProviderPages>(context);
  String img = Util.photoProfile(info.persona.profile);

  return AppBar(
    automaticallyImplyLeading: false,
    centerTitle: true,
    leading: Builder(
      builder: (context) => IconButton(
        icon: new Icon(MdiIcons.dotsVertical),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    backgroundColor: AppColor.themeColor,
    elevation: 1.0,
    actions: setCommonCartNotificationView(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: MemoryImage(Util.dataFromBase64String(img)),
                    fit: BoxFit.cover)),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    ),
  );
}
*/


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
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
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


/*
setAppBarSimple(BuildContext context, String title) {
  return AppBar(
    centerTitle: true,
    backgroundColor: AppColor.themeColor,
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          setHeaderTitle(AppTranslations.of(context).text(title), Colors.white),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    ),
  );
}
*/

void showError(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    gravity: ToastGravity.CENTER,
  );
}

void showMsg(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    fontSize: 16,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: AppColor.secondaryColor,
    textColor: Colors.white,
    gravity: ToastGravity.CENTER,
  );
}
