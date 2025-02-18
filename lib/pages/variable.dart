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


enum WidgetState { LOADING, SHOW_LIST }

class Variable extends StatefulWidget {
  const Variable({super.key});

  @override
  _VariableState createState() => _VariableState();
}

class _VariableState extends State<Variable> {
  List<InstVariable> _variables = [];
  List<InstVariable> _filterList = [];
  late OrgaInstrumentoElement instrument;
  late OrgaInstrumento organization;
  int _indiceSeleccionado = 0; // Índice del botón activo
  String comentario = '';

  WidgetState _widgetState = WidgetState.LOADING;

  String orgaId = '';

  @override
  void initState() {
    super.initState();
    _loadData();

  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

    final info = Provider.of<ProviderPages>(context, listen: false);
    organization = info.organizations.firstWhere((item) => item.orgaId == info.orgaId);
    instrument = organization.orgaInstrumentos.firstWhere((item) => item.instId == info.instId);

    _variables = instrument.instVariables;
    _filterList = _variables.where((item) {
      return item.variNombre.toLowerCase().contains("energia");
    }).toList();

    _widgetState = WidgetState.SHOW_LIST;
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child: CircularProgressIndicator(),
        ) ) ;

      case WidgetState.SHOW_LIST:
        return _buildScaffold(context,contentBody(context) ) ;

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
        backgroundColor: AppColor.containerBody,
        appBar: setAppBarSubTitle(context, organization.orgaNombre, "Variables"),
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
          onChangeBoton();
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

  onChangeBoton() {
    switch(_indiceSeleccionado) {
      case 0:
        _filterList = _variables.where((item) {
          return item.variNombre.toLowerCase().contains("energia");
        }).toList();

      case 1:
        _filterList = _variables.where((item) {
          return item.variNombre.toLowerCase().contains("potencia");
        }).toList();

      case 2:
        _filterList = [..._variables];

    }
    setState(() {});
  }

  onSearch(String search) {
    _filterList = _variables.where((item) {
      return item.variNombre.toLowerCase().contains(search);
    }).toList();

    setState(() {});
  }

  _search() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
      height: 48,
      child: TextField(
        onChanged: (value) => onSearch(value),
        decoration: setSearchDecoration(),
      ),
    );
  }

  Widget contentBody(BuildContext context) {
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
          Container(
            color: AppColor.color1,
            padding: const EdgeInsets.only(top: 20.0, bottom: 20, left: 18, right: 18), // Espacio alrededor del Row (opcional)
            child: Column(
              children: [
                TextField(
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      comentario = value; // Actualiza la variable con el nuevo valor
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white, // Color de fondo gris claro
                    filled: true, // Habilita el color de fondo
                    hintText: 'Escribe tu comentario aquí...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 0.0// Color del borde
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                        ),
                        backgroundColor: AppColor.themeColor,
                        padding: EdgeInsets.all(10.0),
                      ),
                      onPressed: () async {

                      },
                      child: Text('Finalizar',  style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    setCommonText("Listos", Colors.white, 16.0, FontWeight.w800, 20),
                    setCommonText("Pendientes", Colors.white, 16.0, FontWeight.w800, 20),
                  ],
                ),
              ],
            ),
          )
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
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    setCommonText(nombre, Colors.black, 16.0, FontWeight.w800, 20),
                    setCommonText(abbreviation, Colors.black, 16.0, FontWeight.w800, 20),


                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.secondaryColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  setState(() {
                    info.varId = _filterList[index].variId;
                  });
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
