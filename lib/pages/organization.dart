import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../models/orgaInstrumento.dart';
import '../models/variable.dart';
import '../providers/providers_pages.dart';

class Organization extends StatefulWidget {
  @override
  _OrganizationState createState() => _OrganizationState();
}

class _OrganizationState extends State<Organization> {
  List<OrgaInstrumento> data = [];
  List<OrgaInstrumento> _filterList = [];
  int _counter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
     _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    String jsonString  = await rootBundle.loadString('assets/json/data.json');
    print(jsonString);
    setState(() {
      data = orgaInstrumentoFromJson(jsonString);
      _filterList = orgaInstrumentoFromJson(jsonString);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.containerBody,
        appBar: setAppBarTwo(context, "Edificios"),
        body: contentBody(context));
  }

  Widget contentBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          SizedBox(
            height: 7,
          ),
          Expanded(
            child: _createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height - 20,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {});
          },
        )
            : Center(
          child: Text(
            "No Encontrado",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ));
  }

  Widget _itemListView(int index, BuildContext context) {
    final nombre = data[index].orgaNombre;
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return new Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        color: Colors.white,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(10),
        child: new Padding(
          padding: new EdgeInsets.all(8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  setCommonText(_counter.toString(), Colors.black, 14.0, FontWeight.w800, 20),
                  setCommonText(nombre, Colors.black, 14.0, FontWeight.w800, 20),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(20.0),
                ),
                onPressed: () async {
                  //await api.testNotify(info.persona.user.pkUsuario);
                  Navigator.pushNamed(context, 'takePhoto');
                },
                child: Text('Ir',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // FIn MAIN WIDGET
