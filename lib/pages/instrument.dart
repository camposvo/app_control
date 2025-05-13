import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../models/orgaInstrumento.dart';

import '../providers/providers_pages.dart';

class Instrument extends StatefulWidget {
  @override
  _InstrumentState createState() => _InstrumentState();
}

class _InstrumentState extends State<Instrument> {
  List<OrgaInstrumentoElement> _instruments = [];
  List<OrgaInstrumentoElement> _filterList = [];
  late OrgaInstrumento orgaInstrument;

  int _listos = 0;
  int _total= 0;

  bool isLoading = true;
  String orgaId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    if(info.revision == null){
      return;
    }

    orgaInstrument = info.mainData.firstWhere((item) => item.orgaId == info.organization!.orgaId);

    _instruments =  [...orgaInstrument.orgaInstrumentos];
    _filterList =  [...orgaInstrument.orgaInstrumentos];


    //Cantidad de Medidores Listos
    _listos = _instruments.where((elemento) {
      for (var item in elemento.instComentarios) {
        if (item.comeReviId == info.revision!.reviId) {
          return true;
        }
      }
      return false;
    }).toList().length;

    //Cantidad de Medidores Total
    _total = _instruments.length;

    setState(() {});
    isLoading = false;

  }

  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    final name = info.isOrganization ? info.organization!.orgaPrefijo : '';

    return Scaffold(
      drawer: setDrawer(context),
      backgroundColor: AppColor.containerBody,
      appBar: setAppBarMain(context,'$name (Sesión: ${info.mainTopic})', 'Medidores'),
      body: showInstrumentList(context)
    );
  }

  _onSearch(String search) {
    _filterList = _instruments.where((item) {
      return item.instNombre.toLowerCase().contains(search) || item.instEspaAreaNombre.toLowerCase().contains(search) ;
    }).toList();

    setState(() {});
  }

  _search() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
      height: 48,
      child: TextField(
        onChanged: (value) => _onSearch(value),
        decoration: setSearchDecoration(),
      ),
    );
  }

  Widget showInstrumentList(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          _search(),
          SizedBox(
            height: 7,
          ),
          Expanded(
            child: (isLoading)
                ? Center(child: circularProgressMain())
                : _createListView(context),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: AppColor.secondaryColor,
            padding: const EdgeInsets.only(top: 20.0, bottom: 20, left: 18, right: 18), // Espacio alrededor del Row (opcional)
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                setCommonText("Listos: "+_listos.toString(), Colors.white, 16.0, FontWeight.w800, 20),
                setCommonText("Total: "+ _total.toString(), Colors.white, 16.0, FontWeight.w800, 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {

    final info = Provider.of<ProviderPages>(context, listen: false);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {
              setState(() {
                info.instId = _filterList[index].instId;
              });

              Navigator.pushNamed(context, 'variable')
                  .then((_) async {
                await _loadData();
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
    final info = Provider.of<ProviderPages>(context, listen: false);
    final nombre = _filterList[index].instNombre;


    Color bgColor = Colors.grey;
    Color fontColor = Colors.white;


    final variables =  [..._filterList[index].instVariables];

    for (var comment in _filterList[index].instComentarios) {
      if(comment.comeReviId == info.revision?.reviId) {
        if(comment.comeEnviado == 1){
          bgColor = AppColor.GreenReady;
          fontColor = Colors.white;
        }

        if(comment.comeEnviado == 2){
          bgColor = AppColor.editColor;
          fontColor = Colors.white;
        }
      }
    }



    return new Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        color:  bgColor,
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

                  setCommonText(nombre, fontColor, 16.0, FontWeight.w500, 20),
                  setCommonText(_filterList[index].instEspaAreaNombre, fontColor, 16.0, FontWeight.w500, 20),
                  Row(
                    children: [
                      setCommonText( _filterList[index].instUbicAreaNombre + " " , fontColor, 16.0, FontWeight.w500, 20),
                      setCommonText( _filterList[index].instUbicPisoNombre , fontColor, 16.0, FontWeight.w500, 20),
                    ],
                  ),

                  setCommonText(variables.length.toString(), fontColor, 16.0, FontWeight.w800, 20),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
