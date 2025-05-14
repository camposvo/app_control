import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../helper/util.dart';
import '../models/orgaInstrumento.dart';
import '../models/resultRevision.dart';
import '../models/variable.dart';
import '../providers/providers_pages.dart';
import 'package:logger/logger.dart';
import 'package:control/helper/util.dart';


enum WidgetState { LOADING, SHOW_LIST }

class Variable extends StatefulWidget {
  const Variable({super.key});

  @override
  _VariableState createState() => _VariableState();
}

class _VariableState extends State<Variable> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  static const List<String> commentInstrument = [
    'El medidor está bien',
    'El medidor está regular',
    'El medidor está malo'
  ];

  String? dropdownValue;

  TextEditingController _controller = TextEditingController(text: '');

  List<InstVariable> variables = [];
  List<InstVariable> _filterList = [];
  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento orgaInstrument;
  int _indiceSeleccionado = 0; // Índice del botón activo

  WidgetState _widgetState = WidgetState.LOADING;

  String orgaId = '';
  int _listos = 0;
  int _total= 0;

  @override
  void initState() {
    super.initState();
    _loadData();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

    final info = Provider.of<ProviderPages>(context, listen: false);

    if(info.revision == null){
      _widgetState = WidgetState.LOADING;
      setState(() {});
      return;
    }

    orgaInstrument = info.mainData.firstWhere((item) => item.orgaId == info.organization!.orgaId);
    instrument = orgaInstrument.orgaInstrumentos.firstWhere((item) => item.instId == info.instId);

    for (var item in instrument.instComentarios) {
      if (item.comeReviId == info.revision!.reviId) {
        if(commentInstrument.contains(item.comeDescripcion)) dropdownValue = item.comeDescripcion;
      }
    }

    variables =  [...instrument.instVariables];
    _filterList =  [...instrument.instVariables];


    _onChangeBoton();
    // Por defecto se muestra solo las Energias
   /* _filterList = variables.where((item) {
      return item.variNombre.toLowerCase().contains("energia");
    }).toList();*/

    //Cantidad de Variables Listos
    _listos = variables.where((elemento) {
      for (var item in elemento.puntPrueba) {
        if (item.prueReviId == info.revision!.reviId ) {
          return true;
        }
      }
      return false;
    }).toList().length;

    //Cantidad de Medidores Total
    _total = variables.length;

    _widgetState = WidgetState.SHOW_LIST;
    setState(() {});

  }

  void _savePuntoPrueba(BuildContext context, int value){
    final info = Provider.of<ProviderPages>(context, listen: false);

    bool found = false;

    InstComentario comment = new InstComentario(
        comeId: Util.generateUUID(),
        comeFecha:  DateTime.now(),
        comeReviId: info.revision!.reviId,
        comeDescripcion:  dropdownValue!,
        reviNumero:  info.revision!.reviNumero,
        comeEnviado: 2,
        reviEntiId: info.revision!.reviEntiId,
    );

    for (var i = 0; i < info.mainData.length; i++) {
      if (info.mainData[i].orgaId == info.organization!.orgaId) {
        for (var j = 0; j < info.mainData[i].orgaInstrumentos.length; j++) {
          if (info.mainData[i].orgaInstrumentos[j].instId == info.instId) {

            for (var k = 0; k <
                info.mainData[i].orgaInstrumentos[j].instComentarios
                    .length; k++) {
              if (info.mainData[i].orgaInstrumentos[j].instComentarios[k]
                  .comeReviId == info.revision?.reviId) {

                found=true;
                info.mainData[i].orgaInstrumentos[j].instComentarios[k]
                    .comeId = Util.generateUUID();
                info.mainData[i].orgaInstrumentos[j].instComentarios[k]
                    .comeEnviado = value;
                info.mainData[i].orgaInstrumentos[j].instComentarios[k]
                    .comeDescripcion = dropdownValue!;
                info.mainData[i].orgaInstrumentos[j].instComentarios[k]
                    .comeFecha = DateTime.now();

              }
            }

            if(!found) info.mainData[i].orgaInstrumentos[j].instComentarios.add(comment);

          }
        }
      }
    }

    info.mainDataUpdate(info.mainData);

  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child:circularProgressMain(),
        ) ) ;

      case WidgetState.SHOW_LIST:
        return _mainScaffold(context,showVariableList(context) ) ;

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    final name = info.isOrganization ? info.organization!.orgaNombre : '';
    return Scaffold(
        backgroundColor: AppColor.containerBody,
        appBar: setAppBarMain(context, name, instrument.instNombre),
        body: body
    );
  }

  Widget _mainScaffold(BuildContext context, Widget body) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    final name = info.isOrganization ? info.organization!.orgaPrefijo : '';
    return Scaffold(
        drawer: setDrawer(context),
        backgroundColor: AppColor.containerBody,
        appBar: setAppBarMain(context, '$name (Sesión: ${info.mainTopic})', instrument.instNombre),
        body: body
    );
  }

  Widget _botons(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribución equitativa
      children: [
        _buildBoton(0, '1'),
        _buildBoton(1, '2'),
        _buildBoton(2, '3'),
      ],
    );
  }

  Widget _buildBoton(int indice, String texto) {
    bool activo = _indiceSeleccionado == indice;
    return GestureDetector(
      onTap: () {
        setState(() {
          _indiceSeleccionado = indice;
          _onChangeBoton();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: activo ? AppColor.secondaryColor : Colors.grey, // Color según estado
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onChangeBoton() {
    switch(_indiceSeleccionado) {
      case 0:
        _filterList = variables.where((item) {
          return item.variNombre.toLowerCase().contains("energia");
        }).toList();

      case 1:
        _filterList = variables.where((item) {
          return item.variNombre.toLowerCase().contains("potencia");
        }).toList();

      case 2:
        _filterList = [...variables];

    }
    setState(() {});
  }

  _onSearch(String search) {
    _filterList = variables.where((item) {
      return item.variNombre.toLowerCase().contains(search);
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

  Widget showVariableList(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          _botons(context),
          SizedBox(
            height: 16,
          ),
          _search(),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: _createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
          _finishInstrument(context),
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {

              /*Navigator.pushNamed(context, 'variable',
                  arguments: {'id': _filterList[index].variNombre})
                  .then((_) async {

              });*/

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
    final nombre = _filterList[index].variNombre;
    final abbreviation = _filterList[index].subuAbreviatura;
    Color bgColor = Colors.grey;
    Color fontColor = Colors.white;
    bool testLoaded = false;


   for (var item in _filterList[index].puntPrueba) {

      if (item.prueReviId == info.revision?.reviId) {
        testLoaded = true;

        if(item.prueEnviado == 1){
          bgColor = Colors.green;
          fontColor = Colors.white;
        }

        if(item.prueEnviado == 2){
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
                width: 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    setCommonText(nombre, fontColor, 16.0, FontWeight.w800, 20),
                    setCommonText(abbreviation, fontColor, 16.0, FontWeight.w800, 20),

                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        info.puntId = _filterList[index].puntId;
                        info.varId = _filterList[index].variId;
                      });

                      Navigator.pushNamed(context, 'showTesting').then((_) async {
                        await _loadData();
                      });


                    },
                    icon: Icon(
                      Icons.list,
                      color: fontColor,
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

  Widget _finishInstrument(BuildContext context){
    final info = Provider.of<ProviderPages>(context, listen: false);
    return  Container(
      color: AppColor.secondaryColor,
      padding: const EdgeInsets.only(top: 20.0, bottom: 20, left: 18, right: 18), // Espacio alrededor del Row (opcional)
      child: Column(
        children: [
          _commentList(context),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                    ),
                    backgroundColor: AppColor.redColor,
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {

                  },
                  child: Text('Cancelar',  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),),
                ),
              ),

              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                    ),
                    backgroundColor: AppColor.themeColor,
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {

                    if(dropdownValue == null) {
                      await showError('Debe seleccionar un Comentario');
                      return;
                    }

                    _savePuntoPrueba(context, 2);
                    info.pendingData = true;
                    setState(() {});
                    await showMsg('Medidor Finalizado');
                    await Future.delayed(Duration(seconds: 2));
                    Navigator.pop(context);

                  },
                  child: Text('Finalizar Medidor',  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              setCommonText("Listos: "+_listos.toString(), Colors.white, 16.0, FontWeight.w800, 20),
              setCommonText("Total: "+_total.toString(), Colors.white, 16.0, FontWeight.w800, 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget  _commentList(BuildContext context){
    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder( // Define el borde
          borderRadius: BorderRadius.circular(10.0), // Radio de las esquinas
        ),
        filled: true, // Habilita el color de fondo
        fillColor: Colors.white, // Color de fondo
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),

      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        items: commentInstrument.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            alignment: Alignment.center,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue;
            if(newValue != null){
              print('Estado seleccionado: $newValue');
            }
          });
        },
        hint: const Text('Selección ...',
          textAlign: TextAlign.center,
          style: TextStyle(
          color: Colors.black,
          fontSize: 18,

        ),),
      ),
    );

  }


} // FIn MAIN WIDGET
