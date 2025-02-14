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

class Instrument extends StatefulWidget {
  @override
  _InstrumentState createState() => _InstrumentState();
}

class _InstrumentState extends State<Instrument> {
  List<OrgaInstrumentoElement> _instruments = [];
  List<OrgaInstrumentoElement> _filterList = [];
  late OrgaInstrumento organization;

  bool isLoading = true;
  String orgaId = '';

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map;

      final info = Provider.of<ProviderPages>(context, listen: false);
      final id = arguments["id"];
      print(id);
      organization = info.organizations.firstWhere((item) => item.orgaId == id);
      print(organization.orgaNombre);
      _instruments = organization.orgaInstrumentos;
      _filterList = organization.orgaInstrumentos;

      setState(() {});
      isLoading = false;




    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.containerBody,
      appBar: setAppBarTwo(context, organization.orgaNombre),
      body: contentBody(context)
    );
  }


  onSearch(String search) {
    _filterList = _instruments.where((item) {
      return item.instNombre.toLowerCase().contains(search);
    }).toList();

    setState(() {});
  }

  _search() {
    return Container(
      height: 48,
      child: TextField(
        onChanged: (value) => onSearch(value),
        decoration: setSearchDecoration(),
      ),
    );
  }

  Widget contentBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          _search(),
          SizedBox(
            height: 7,
          ),
          Expanded(
            child: (isLoading)
                ? Center(child: CircularProgressIndicator())
                : _createListView(context),
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
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {
              Navigator.pushNamed(context, 'variable',
                  arguments: {'id': _filterList[index].instNombre})
                  .then((_) async {

              });

            });
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
    final nombre = _filterList[index].instNombre;
    final instrument = _filterList[index].instEspaAreaNombre;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  setCommonText(nombre, Colors.black, 14.0, FontWeight.w800, 20),
                  setCommonText(instrument.length.toString(), Colors.black, 14.0, FontWeight.w800, 20),


                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  //await api.testNotify(info.persona.user.pkUsuario);
                  Navigator.pushNamed(context, 'takePhoto');
                },
                child: Text('Ir',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // FIn MAIN WIDGET
