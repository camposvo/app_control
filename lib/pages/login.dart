
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control/helper/shared_manager.dart';
import 'package:control/helper/constant.dart';



import 'package:control/api/client.dart';
import 'package:control/providers/providers_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/common_widgets.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool value = false;
  bool isLoading = false;
  bool _isHiddenPassword = true;
  bool _chkRemember = false;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  TextEditingController _passwd = TextEditingController();


  @override
  void initState() {
    _username = new TextEditingController();
    _passwd = new TextEditingController();
    loadPreferences();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final info = Provider.of<ProviderPages>(context, listen: false);
    });
  }

  loadPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if(_prefs != null){
      _username.text= _prefs.getString('username')??"";
      _passwd.text= _prefs.getString('passwd')??"";
      _chkRemember= _prefs.getBool('chkRemember')??_chkRemember;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.blue, ),
              ),
            ),
            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width - 200) / 2,
              child: new Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image:
                        DecorationImage(image: AssetImage(AppImage.appLogo))),
              ),
            ),
            Positioned(
              top: 220,
              child: Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 440,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5),
                      ]),
                  child: new ListView(
                    children: <Widget>[
                      _setLogin(context),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _setLogin(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    return new Container(
      padding: new EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _setEmail("Username", context),
            SizedBox(
              height: 25,
            ),
            _setPasswd("password", context),
            SizedBox(
              height: 25,
            ),
            _setSignIn(context, info),
            SizedBox(
              height: 10,
            ),


            SizedBox(
              height: 25,
            ),

          ],
        ),
      ),
    );
  }

  _setEmail(String hinttext, BuildContext context) {
    return TextFormField(
      controller: _username,
      textDirection: SharedManager.shared.direction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "inputEmail";
        }
        return null;
      },
      decoration: setInputDecoration(hinttext: hinttext ),
      style: setStyle(),

    );
  }

  _setPasswd(String hinttext, BuildContext context) {
    return TextFormField(
      obscureText: _isHiddenPassword,
      controller: _passwd,
      textDirection: SharedManager.shared.direction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "inputEmail";
        }
        return null;
      },
      decoration: InputDecoration(
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
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
        prefixIcon: Icon(
          Icons.lock,
          color: AppColor.secondaryColor,
          size: 18,
        ),
        suffixIcon: InkWell(
          child: Icon(
              _isHiddenPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColor.secondaryColor),
          onTap: () {
            setState(() {
              _isHiddenPassword = !_isHiddenPassword;
            });
          },
        ),
      ),
     // style: setStyle(),
    );
  }

  _setSignIn(BuildContext context, ProviderPages info) {
    return InkWell(
        child: new Container(
          height: 45,
          width: MediaQuery.of(context).size.width,
          child: new Material(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(22.5),
            elevation: 5.0,
            child: new Center(
              child: (isLoading)
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.5,
                      ))
                  : Text(
                     "Aceptar",
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
            ),
          ),
        ),
        onTap: () async {
          _signIn();
        });
  }


/*
_signIn() {

    api.getBachas()
        .then((value) async {
          print(value);

    }).catchError((error) {

    });
  }
  */

  _signIn() {
    //isLoading = true;
    setState(() {});
    //Navigator.pushNamed(context, 'tabbarpage');
    Navigator.pushNamed(context, 'welcome');

  }
}
