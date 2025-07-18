import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../api/client.dart';
import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/decimalInputFormatter.dart';
import '../helper/util.dart';
import '../models/orgaInstrumento.dart';

import '../providers/providers_pages.dart';

enum WidgetState { LIST, EDIT }

class Instrument extends StatefulWidget {
  @override
  _InstrumentState createState() => _InstrumentState();
}

class _InstrumentState extends State<Instrument> {
  List<OrgaInstrumentoElement> _instruments = [];
  List<OrgaInstrumentoElement> _filterList = [];
  late OrgaInstrumento orgaInstrument;

  WidgetState _widgetState = WidgetState.LIST;

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
      for (var item in elemento.instFinalizados) {
        if (item.reviId == info.revision!.reviId && item.inreFinalizado == 1) {
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

    switch (_widgetState) {

      case WidgetState.LIST:
        return mainInstrument(context);

      case WidgetState.EDIT:
        return mainInstrument(context);
    }
  }

  Widget mainInstrument(BuildContext context) {
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
          _btnSendData(context),
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

  Widget _btnSendData(BuildContext context){
    final info = Provider.of<ProviderPages>(context, listen: false);

    return  Row(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        SizedBox(
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0), // Radio de 10.0
              ),
              backgroundColor: AppColor.themeColor,
              padding: EdgeInsets.all(10.0),
            ),
            onPressed: !info.pendingData ? null: () {
              Navigator.pushNamed(context, 'sendData')
                  .then((_) async {
                await _loadData();
              });



            },
            child: Text(
              'Enviar Datos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.0,
        )
      ],
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
    final protection = _filterList[index].instProteccion;
    Color bgColor = Colors.grey;
    Color fontColor = Colors.white;

    final stateInstrument = _filterList[index].getInreFinalizadoByReviId(info.revision!.reviId);
    final testPending = _filterList[index].getPuntPruebasPending(info.revision!.reviId);
    final ubication = (_filterList[index].instUbicAreaNombre + " "+ _filterList[index].instUbicPisoNombre).trim();


    if(stateInstrument == null ||  stateInstrument == 0){
      bgColor = Colors.grey;
      fontColor = Colors.white;
    }

    if(stateInstrument == 1){
      bgColor = AppColor.GreenReady;
      fontColor = Colors.white;
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
                    if(ubication.isNotEmpty)setCommonText(ubication, fontColor, 16.0, FontWeight.w500, 20),
                   /* Row(
                      children: [
                        setCommonText( _filterList[index].instUbicAreaNombre + " " , fontColor, 16.0, FontWeight.w500, 20),
                        setCommonText( _filterList[index].instUbicPisoNombre , fontColor, 16.0, FontWeight.w500, 20),
                      ],
                    ),*/
                    setCommonText("Protección: "+ protection.toString(), fontColor, 16.0, FontWeight.w800, 20),

                  ],
                ),
              ),
              Row(
                children: [
                  if(testPending > 0 ) Icon(
                    Icons.pending_actions,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  IconButton(
                    onPressed: () async {
                      await _showEdit(context, _filterList[index]);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColor.orangeColor,
                      size: 24.0,
                    ),
                  ),
                /*  Icon(
                    Icons.cloud_done_sharp,
                    color: Colors.white,
                    size: 24.0,
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void>  _showEdit(BuildContext context, OrgaInstrumentoElement selectedInstrument) async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final orgaId = info.organization!.orgaId;

    String originalText = selectedInstrument.instProteccion.toString();
    String resultText = '0,00';

    // Intenta parsear el texto a un double
    double? parsedDouble = double.tryParse(originalText);

    if (parsedDouble != null) {
      // Si es un double, conviértelo a texto con una precisión adecuada
      // (por ejemplo, 2 decimales, ajusta según tu necesidad)
      resultText = parsedDouble.toStringAsFixed(2); // Ejemplo: 2 decimales

      // Reemplaza el punto por una coma
      resultText = resultText.replaceAll('.', ',');
    } else {
      // Si no es un double, puedes devolver el texto original
      // o un mensaje de error, o una cadena vacía, según tu lógica.
      resultText = '0,00'; // O String resultText = "No es un número válido";
    }



    TextEditingController _controller1 = TextEditingController(text: resultText);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog)
        {
          return AlertDialog(
            title: Text(selectedInstrument.instNombre),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _controller1,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    DecimalInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Corriente Nominal',
                    hintText: '0,00', // Sugerencia visual
                    border: OutlineInputBorder( // Este es el borde para el estado deshabilitado
                      borderSide: BorderSide(
                        color: AppColor.themeColor, // El color que deseas para el borde deshabilitado
                        width: 1.0, // El grosor que deseas para el borde deshabilitado
                      ),
                    ),
                  ),

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


                    double? parsedValue = Util.parsedDouble(_controller1.text);

                    if (parsedValue == null) {
                      showError("Entrada no valida en Foto 1");
                      return;
                    }


                  setStateDialog(() {
                    _isSaving = true; // Activa el estado de carga
                  });

                    Util.printInfo('dato...', parsedValue.toString());


                  saveInstrument(context, orgaId,selectedInstrument.instId, parsedValue);

                  Navigator.of(context).pop();



                  setStateDialog(() {
                    _isSaving = false;
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

            ],
          );
          },

        );
      },
    );
  }

  Future<void> saveInstrument(BuildContext context, String orgaId, String instId, double newProtection ) async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final index =  findIndexByOrgaId(info.mainData, orgaId);
    if(index == null) {
      showError("Error Actualizando");
      //error
      return;
    }

    final result = await api.updateIntrument(instId, orgaId, newProtection);


    if(result == null){

      showError("Error Actualizando");
      return;
    }

    info.mainData[index].updateInstProteccion(instId, newProtection);
    _loadData();

  }


}
