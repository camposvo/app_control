import 'package:control/models/ingrediente.dart';
import 'package:control/models/procedimiento.dart';
import 'package:control/models/receta.dart';
import 'package:flutter/material.dart';
import 'package:control/helper/common_widgets.dart';
import 'package:control/helper/constant.dart';
import 'package:intl/intl.dart';

class ProcedimientoList extends StatefulWidget {
  const ProcedimientoList({Key? key}) : super(key: key);
  @override
  _ProcedimientoListState createState() => _ProcedimientoListState();
}

class _ProcedimientoListState extends State<ProcedimientoList> {
  List<Procedimiento> procedimientos = [
    Procedimiento(
        proceId: "a6df4fb0-aa8a-43c4-954d-0b026592c6c9",
        proceDescripcion:
            "Colocar todos los ingredientes en una Juguera, sacar a un molde, mesclar por 5 minutos, a alta velocidad con una paleta"),
    Procedimiento(
        proceId: "a6df4fb0-aa8a-43c4-954d-0b026592c6c9",
        proceDescripcion: "Luego colocar dentro de un colgelador por 8 horas"),
  ];

  List<Procedimiento> _filterList = [
    Procedimiento(
        proceId: "a6df4fb0-aa8a-43c4-954d-0b026592c6c9",
        proceDescripcion:
            "Colocar todos los ingredientes en una Juguera, sacar a un molde, mesclar por 5 minutos, a alta velocidad con una paleta"),
    Procedimiento(
        proceId: "a6df4fb0-aa8a-43c4-954d-0b026592c6c9",
        proceDescripcion: "Luego colocar dentro de un colgelador por 8 horas"),
  ];

  bool isLoading = false;
  TextEditingController _endDay = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

  String dropdownValue = 'Hoy';
  String estado = '1'; //1 para las que faltan procesar 0: para las procesadas

  @override
  void initState() {
    super.initState();

    /* WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadData(estado, DateTime.now(), false).then((value) {});
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.containerBody,
        appBar: setAppBarTwo(context, "MQTT Cliente"),
        body: contentBody(context)
    );
  }

  Widget contentBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          SizedBox(
            height: 7,
          ),
          _setMainInformationView(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: (isLoading)
                ? Center(child: CircularProgressIndicator())
                : _createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
          _setContinueButton(context),
        ],
      ),
    );
  }

  Widget _setMainInformationView() {
    return new Container(
      child: Material(
        color: AppColor.secondaryColor,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: new EdgeInsets.all(20),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              setCommonText("HELADO DE FRUTILLA Y FRAMBUESA", Colors.black,
                  20.0, FontWeight.w500, 3),
              setCommonText2("Pasos para la Elaboración", Colors.black, 16.0,
                  FontWeight.w400, 8),
            ],
          ),
        ),
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
                      child: _itemListView(index, _filterList, context),
                      onTap: () {});
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

  Widget _itemListView(
      int index, List<Procedimiento> procedimientos, BuildContext context) {
    final nombre = _filterList[index].proceDescripcion;


    return new Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),

      child: Material(
        color: Colors.white,
        elevation: 2.0,

        borderRadius: BorderRadius.circular(10),
        child: new Padding(
          padding: new EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              stepNumber(context, index),
              SizedBox(
                width: 10,
              ),
              Expanded(child: setCommonText(nombre, Colors.black, 14.0, FontWeight.w800, 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setContinueButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width - 20, 40),
        shape: StadiumBorder(),
        backgroundColor: AppColor.backgroundBtnColor,
        padding: EdgeInsets.all(20.0),
      ),
      onPressed: () async {
        Navigator.pushNamed(context, 'dashboard');
      },
      child: Text(
        'Inicio',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget stepNumber(BuildContext context, int valor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.themeColor,
      ),
      child: Center(
        child: Text(
          valor.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _loadData(String estado, DateTime fecha, bool isAll) async {
    isLoading = true;
    setState(() {});
    /* recetas = await api.getPedidos(estado, fecha, isAll);
    _filterList = recetas;*/
    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
