import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/util.dart';
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

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  int _listos = 0;
  int _total= 0;

  bool _isSaving = false;

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
    final instrumentName = _filterList[index].instNombre;
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
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    setCommonText(instrumentName, fontColor, 16.0, FontWeight.w500, 20),
                    //setCommonText(_filterList[index].instEspaAreaNombre, fontColor, 16.0, FontWeight.w500, 20),
                    Row(
                      children: [
                        setCommonText( _filterList[index].instUbicAreaNombre + " " , fontColor, 16.0, FontWeight.w500, 20),
                        setCommonText( _filterList[index].instUbicPisoNombre , fontColor, 16.0, FontWeight.w500, 20),
                      ],
                    ),
                    setCommonText("Corriente Nominal: ", fontColor, 16.0, FontWeight.w800, 20),

                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await _showEdit(context, instrumentName);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColor.redColor,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void>  _showEdit(BuildContext context, String instrumentName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(instrumentName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _controller1,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                decoration: InputDecoration(labelText: 'Corriente Nominal'),
              ),

            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: AppColor.themeColor,
                padding: EdgeInsets.all(10.0),
              ),
              onPressed: _isSaving
                  ? null // Deshabilita el botón si _isLoading es true
                  : () async {
                setState(() {
                  _isSaving = true; // Activa el estado de carga
                });

                Util.printInfo('Guardando...', _isSaving.toString());
                await Future.delayed(const Duration(seconds: 4));

                // Aquí iría tu lógica para guardar los datos

                Navigator.of(context).pop(); // Ejemplo: cerrar el modal

                setState(() {
                  _isSaving = false; // Desactiva el estado de carga
                });
                Util.printInfo('Guardando...', _isSaving.toString());
              },
              child: _isSaving
                  ? const SizedBox( // Muestra un CircularProgressIndicator si _isLoading es true
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : const Text( // Muestra el texto "Guardar" si _isLoading es false
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: AppColor.redColor,
                padding: EdgeInsets.all(10.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  // Puedes ajustar el estilo del texto para que coincida con tu diseño
                  color: Colors.white,
                  // fontSize: 16,
                ),
              ),
            ),
            /*TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                // Aquí puedes procesar los datos de _controller1.text y _controller2.text
                print('Primer dato: ${_controller1.text}');
                print('Segundo dato: ${_controller2.text}');
                Navigator.of(context).pop();
              },
            ),*/
          ],
        );
      },
    );
  }


}
