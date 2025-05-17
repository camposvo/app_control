import 'dart:async';
import 'dart:convert';

import 'package:control/pages/takePhoto.dart';
import 'package:control/pages/takePhotoSystem.dart';
import 'package:control/pages/viewPhoto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../api/client.dart';
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

class ShowTesting extends StatefulWidget {
  const ShowTesting({super.key});

  @override
  _ShowTestingState createState() => _ShowTestingState();
}

class _ShowTestingState extends State<ShowTesting> {
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
  List<PuntPrueba> _filterList = [];
  List<PuntPrueba> _puntPruebas = [];
  late OrgaInstrumentoElement instrument;
  late InstVariable variable ;
  late OrgaInstrumento orgaInstrument;
  int _indiceSeleccionado = 0; // Índice del botón activo

  WidgetState _widgetState = WidgetState.LOADING;

  String orgaId = '';
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

    variable = instrument.instVariables.firstWhere((item) => item.variId == info.varId);



    _puntPruebas =  [...variable.puntPrueba];
    _filterList =  [...variable.puntPrueba];

    Util.printInfo("Total Pruebas", variable.variNombre);
    Util.printInfo("Total Pruebas", variable.puntPrueba.length.toString());

    _widgetState = WidgetState.SHOW_LIST;
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child:circularProgressMain(),
        ) ) ;

      case WidgetState.SHOW_LIST:
        return _mainScaffold(context,showTestingList(context) ) ;

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
        appBar: setAppBarMain(context, '$name ', instrument.instNombre),
        body: body
    );
  }

  _onSearch(String search) {
    _filterList = _puntPruebas.where((item) {
      return item.reviNumero.toLowerCase().contains(search);
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

  Widget showTestingList(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(

        children: [
          SizedBox(
            width: 16,
          ),

          SizedBox(
            height: 16,
          ),
          setCommonText("PRUEBAS", Colors.black, 18.0, FontWeight.w800, 20),
          SizedBox(
            height: 0,
          ),
          setCommonText(variable.variNombre, Colors.black, 18.0, FontWeight.w400, 20),
          SizedBox(
            height: 8,
          ),
          _btnAddPrueba(context),
          SizedBox(
            height: 8,
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
    final description = _filterList[index].prueDescripcion;
    final prueId = _filterList[index].prueId;
    final dateTest = Util.formatearFecha(_filterList[index].prueFecha);
    Color bgColor = AppColor.secondaryColor;
    Color fontColor = Colors.white;
    bool testLoaded = false;

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
                    setCommonText(description, fontColor, 16.0, FontWeight.w800, 20),
                    setCommonText(dateTest, fontColor, 16.0, FontWeight.w800, 20),

                  ],
                ),
              ),
              Row(
                children: [
                  _btnViewPhoto(context, fontColor, prueId),
                  _btnUpdatePrueba(context, fontColor, prueId),
                ],
              ),

            ],
          ),
        ),
      ),
    );

  }

  Widget _btnViewPhoto(BuildContext context, Color fontColor,String prueId){

    return     IconButton(
      onPressed: () async {

        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ViewPhoto(
              prueId: prueId),
        )).then((_) async{
          await _loadData();
        });    
        
      },
      icon: Icon(
        Icons.search,
        color: fontColor,
        size: 24.0,
      ),
    );
  }

  Widget _btnAddPrueba(BuildContext context){
    final info = Provider.of<ProviderPages>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 100,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: AppColor.themeColor,
                padding: EdgeInsets.all(10.0),
              ),
              onPressed: () {

                if(info.moduleSelected == ModuleSelect.WITH_SYSTEM ){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => TakePhotoSystem(
                        prueId: null),
                  )).then((_) async{
                    await _loadData();
                  });

                }

                if(info.moduleSelected == ModuleSelect.NO_SYSTEM ){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => TakePhoto(
                        prueId: null),
                  )).then((_) async {
                    await _loadData();
                  });
                }
              },
              icon: Icon(
                Icons.camera_alt, // Usa el icono de cámara que prefieras
                color: Colors.white, // Ajusta el color del icono si es necesario
              ),
              label: Text(
                'Nuevo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            )
          ),

        ],
      ),
    );
  }

  Widget _btnUpdatePrueba(BuildContext context, Color fontColor,  String prueId){

    final info = Provider.of<ProviderPages>(context, listen: false);
    return  IconButton(
      onPressed: () async {

        if(info.moduleSelected == ModuleSelect.WITH_SYSTEM ){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TakePhotoSystem(
                prueId: prueId),
          )).then((_) async{
            await _loadData();
          });

        }

        if(info.moduleSelected == ModuleSelect.NO_SYSTEM ){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TakePhoto(
                prueId: prueId),
          )).then((_) async {
            await _loadData();
          });
        }


      },
      icon: Icon(
        Icons.camera_alt,
        color: fontColor,
        size: 24.0,
      ),
    );
  }

} 
