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

import 'editPhoto.dart';


enum WidgetState { LOADING, SHOW_LIST }

class ResultError {
  final String message;
  final double? numericValue;

  ResultError(this.message, this.numericValue);
}

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
  PuntComentario? prueComment;


  bool enabledAddBtn = false;
  bool cumulativeIsComplete = false;
  int itemNumber = 0;

  bool _isSaving = false;
  bool isLoading = true;

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

    getPrueComment(context);

  /*  prueComment = variable.getComentarioByReviId(info.revision!.reviId);

    if (prueComment != null){
      Util.printInfo("comentaria: ", prueComment!.comeDescripcion);
      Util.printInfo("comentaria id: ", prueComment!.comeId.toString());
    }*/

    _puntPruebas = variable.getPruebasByReviId(info.revision!.reviId);
    _puntPruebas.sort((a, b) => a.prueActivo.compareTo(b.prueActivo));

    _filterList = variable.getPruebasByReviId(info.revision!.reviId);
    _filterList.sort((a, b) => b.prueActivo.compareTo(a.prueActivo));

    enabledAddBtn = getStateAddBtn();

    _widgetState = WidgetState.SHOW_LIST;
    setState(() {});

  }

  void getPrueComment(BuildContext context){
    final info = Provider.of<ProviderPages>(context, listen: false);
    prueComment = variable.getComentarioByReviId(info.revision!.reviId);

    if (prueComment != null){
      Util.printInfo("comentaria: ", prueComment!.comeDescripcion);
      Util.printInfo("comentaria id: ", prueComment!.comeId.toString());
    }
  }

  bool getStateAddBtn(){
    if(variable.variTipo == 'instantanea' && variable.countActivePruebas() == 0){
      return true;
    }

    if(variable.variTipo == 'acumulativa' && variable.countActivePruebas() < 2){
      return true;
    }

    return false;
  }

  void _addCommentPrueba(BuildContext context, String comment) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    PuntComentario puntComentario = PuntComentario(
        comeFecha: DateTime.now(),
        comeActivo: 1,
        comeReviId: info.revision!.reviId,
        comeDescripcion: comment,
        comeEnviado: 2,
    );

    variable.addComentario(puntComentario);

    info.pendingData = true;
    info.mainDataUpdate(info.mainData);

    getPrueComment(context);
  }

  void _updateCommentPrueba(BuildContext context, String commentId, DateTime dateTime, String comment) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    Util.printInfo("paso", "actualizar");

    PuntComentario puntComentario = PuntComentario(
        comeId: commentId,
        comeFecha: dateTime,
        comeActivo: 1,
        comeReviId: info.revision!.reviId,
        comeDescripcion: comment,
        comeEnviado: 2,
    );


    //Util.printInfo("comentario: ", puntComentario.toJson().toString());

    variable.updateComentario(commentId, puntComentario );

    info.pendingData = true;
    info.mainDataUpdate(info.mainData);

    getPrueComment(context);
  }

  bool _deletePuntPrueba(BuildContext context, String prueId) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final index = findIndexByOrgaId(info.mainData, info.organization!.orgaId);
    if(index == null){
      //fallo el update
      return false;
    }

    final result = info.mainData[index].deletePuntPrueba(prueId);
    if(!result){
      print('No se encontró ninguna variable con el puntId en la organización');
      return false;
    }

    info.pendingData = true;
    info.mainDataUpdate(info.mainData);

    return true;
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

  Widget _topButtons(BuildContext context){
    final info = Provider.of<ProviderPages>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                onPressed:  () {

                  Navigator.pop(context);

                },
                /* icon: Icon(
                  Icons.arrow_back_ios, // Usa el icono de cámara que prefieras
                  color: Colors.white, // Ajusta el color del icono si es necesario
                ),*/
                label: Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              )
          ),
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
                onPressed:  () {
                  _dialogAddComment(context);
                },
                label: Text(
                  'Comentario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              )
          ),
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
                onPressed: enabledAddBtn ? () {

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

                }: null,
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

  Widget showTestingList(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final resultError = getErrorCumulative();

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
            height: 0,
          ),
          setCommonText( '(${variable.variTipo})' , Colors.black, 18.0, FontWeight.w400, 20),
          _topButtons(context),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: _createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
          //if(variable.variTipo == 'acumulativa' && info.moduleSelected == ModuleSelect.NO_SYSTEM)
          if(variable.variTipo == 'acumulativa')
            showErrorCumulative(context, resultError),

        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {

    itemNumber = 0;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {

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
    final prueEnviado = _filterList[index].prueEnviado;
    final prueId = _filterList[index].prueId;
    final valor1 = _filterList[index].prueValor1;
    final valor2 = _filterList[index].prueValor2;

    final dateTest = Util.formatDateTime(_filterList[index].prueFecha);
    Color bgColor = Colors.white;
    Color fontColor = Colors.black;
    bool testLoaded = false;
    int prueActivo = _filterList[index].prueActivo;
    String msg='';
    bool showItemNumber = true;

    final resultError = getErrorInstant(valor1, valor2);

    final valor1Txt = valor1?.toString().replaceAll('.', ',');
    final valor2Txt = valor2?.toString().replaceAll('.', ',');

    if(prueActivo == 0){
      bgColor = Colors.grey;
      fontColor = Colors.white;
      showItemNumber = false;
    }


    itemNumber++;
    if(itemNumber > 2)showItemNumber = false;

   final actives =  _filterList.where((prueba) => prueba.prueActivo == 1).length;
    if( actives > 2)showItemNumber = false;

    return  Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        color:  bgColor,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                        if(showItemNumber)
                          setCommonText('LECTURA $itemNumber', Colors.green, 24.0, FontWeight.w800, 20),

                        setCommonText(dateTest, fontColor, 16.0, FontWeight.w800, 20),

                        //if(info.moduleSelected == ModuleSelect.WITH_SYSTEM)
                        setCommonText("Valor Patrón: $valor1Txt", fontColor, 16.0, FontWeight.w800, 20),

                        //if(info.moduleSelected == ModuleSelect.WITH_SYSTEM)
                        setCommonText("Valor Medidor: $valor2Txt", fontColor, 16.0, FontWeight.w800, 20),

                        //if(variable.variTipo == 'instantanea' && info.moduleSelected == ModuleSelect.WITH_SYSTEM)
                        if(variable.variTipo == 'instantanea')
                          showErrorInstant(context, resultError)

                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _btnEditPhoto(context, fontColor, prueId),
                  _btnViewPhoto(context, fontColor, prueId),
                  if(prueActivo == 1)_btnUpdatePrueba(context, fontColor, prueId),
                  if(prueActivo == 1)_btnDeletePrueba(context, fontColor,prueId),
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

  Widget _btnEditPhoto(BuildContext context, Color fontColor,String prueId){
    return     IconButton(
      onPressed: () async {

        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EditPhoto(
              prueId: prueId),
        )).then((_) async{
          await _loadData();
        });

      },
      icon: Icon(
        Icons.edit,
        color: fontColor,
        size: 24.0,
      ),
    );
  }

  Widget _btnUpdatePrueba(BuildContext context, Color fontColor,  String prueId){

    final info = Provider.of<ProviderPages>(context, listen: false);
    return  IconButton(
      padding: EdgeInsets.zero,
      onPressed: () async {

        if(info.moduleSelected == ModuleSelect.WITH_SYSTEM ){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TakePhotoSystem(
                prueId: prueId,
            ),
          )).then((_) async{
            await _loadData();
          });

        }

        if(info.moduleSelected == ModuleSelect.NO_SYSTEM ){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TakePhoto(
                prueId: prueId,
            ),
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

  Widget _btnDeletePrueba(BuildContext context, Color fontColor,  String prueId){

    final info = Provider.of<ProviderPages>(context, listen: false);
    return  IconButton(
      padding: EdgeInsets.zero,
      onPressed: () async {

        final confirm = await showConfirmDelete(context);

        if(!confirm ){
          return;
        }

        final result = _deletePuntPrueba(context, prueId);

        if(result){
          showMsg("Registro Borrado Existosamente");
          _loadData();
          return;
        }

        showError("Error al Borrar el Registro");

      },
      icon: Icon(
        Icons.delete,
        color: fontColor,
        size: 24.0,
      ),
    );
  }

  ResultError getErrorInstant(dynamic valor1, dynamic valor2){

    double? numericValue;
    String message ='';

    final resultVal1 = Util.parseDynamicToDouble(valor1);
    if(resultVal1 == null){

      message = 'Valor 1 NaN';
      numericValue = null;
      return   ResultError(message, numericValue);
    }

    final resultVal2 = Util.parseDynamicToDouble(valor2);
    if(resultVal2 == null){

      message = 'Valor 2 NaN';
      numericValue = null;
      return   ResultError(message, numericValue);

    }

    if(resultVal2 == 0){
      message = 'Falla por División por 0';
      numericValue = null;
      return   ResultError(message, numericValue);
   }

    final error = (((resultVal1-resultVal2)/resultVal1)*100).abs();

    message = 'ok';
    numericValue = error;
    return   ResultError(message, numericValue);

  }

  ResultError getErrorCumulative(){
    double? numericValue;
    String message ='';

    final puntPruebaActivo = _puntPruebas.where((prueba) => prueba.prueActivo == 1).toList();

    if(puntPruebaActivo.length != 2) {
      message = 'Deben existir dos pruebas para el Calculo';
      numericValue = null;
      return   ResultError(message, numericValue);
    }

    //Se ordena la lista desde el mas antiguo hasta el mas reciente
    puntPruebaActivo.sort((a, b) => a.prueFecha.compareTo(b.prueFecha));

    final valor1a = Util.parseDynamicToDouble(puntPruebaActivo[0].prueValor1);
    final valor2a = Util.parseDynamicToDouble(puntPruebaActivo[0].prueValor2);
    final valor1b = Util.parseDynamicToDouble(puntPruebaActivo[1].prueValor1);
    final valor2b = Util.parseDynamicToDouble(puntPruebaActivo[1].prueValor2);

    if(valor1a == null || valor2a == null  || valor1b == null || valor2b == null ){

      message = 'Existe un valor Invalido en el Calculo';
      numericValue = null;
      return   ResultError(message, numericValue);
    }

    final valor1Result = valor1b - valor1a;
    final valor2Result = valor2b - valor2a;

    if(valor2Result == 0){

      message = 'Error al Dividor por 0';
      numericValue = null;
      return   ResultError(message, numericValue);
    }


    message = 'OK';
    numericValue = (((valor1Result-valor2Result)/valor1Result)*100).abs();
    return   ResultError(message, numericValue);

  }

  Widget showErrorInstant(BuildContext context, ResultError resultError){
    Color bgColor = Colors.grey;
    Color fontColor = Colors.white;
    String msg='';


    if(resultError.numericValue == null){
      bgColor = Colors.grey;
      msg = resultError.message;

    }else{
      msg = '${resultError.numericValue!.toStringAsFixed(3).replaceAll('.', ',')}%';

      if(resultError.numericValue! >= 5.0){
        bgColor = Colors.red;
      }

      if(resultError.numericValue! < 5.0){
        bgColor = Colors.green;
      }

    }

    return Container(
      padding:  EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'Error: ',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
              color: fontColor, // Un color para el título
            ),
          ),
          // Espacio entre el título y el segundo texto
          Text(
            msg,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: fontColor, // Un color más suave para el cuerpo del texto
            ),
          ),
        ],
      ),
    );

  }

  Widget showErrorCumulative(BuildContext context, ResultError resultError){
    Color bgColor = Colors.white;
    Color fontColor = Colors.black;

    String msg = '';

    if(resultError.numericValue == null){
      msg = resultError.message;
      bgColor = Colors.white;
    }else{
      msg = '${resultError.numericValue!.toStringAsFixed(3).replaceAll('.', ',')}%';

      if(resultError.numericValue! > 5.0){
        bgColor = Colors.red;

      }

      if(resultError.numericValue! <= 5.0){
        bgColor = Colors.green;

      }

    }

    return Container(
      padding:  EdgeInsets.all(20.0),
      margin: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Error Acumulada',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Un color para el título
            ),
          ),
          SizedBox(height: 8.0), // Espacio entre el título y el segundo texto
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.black54, // Un color más suave para el cuerpo del texto
            ),
          ),
        ],
      ),
    );

  }

  Future<void>  _dialogAddComment(BuildContext context) async {
    final info = Provider.of<ProviderPages>(context, listen: false);
    String text = '';
    String? comeId;
    DateTime dateTime = DateTime.now();

    if(prueComment != null){
      text = prueComment!.comeDescripcion;
      comeId = prueComment!.comeId;
      dateTime = prueComment!.comeFecha;

    }


    TextEditingController _controller1 = TextEditingController(text: text);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog)
          {
            return AlertDialog(
              title: Text('Comentario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _controller1,
                    keyboardType: TextInputType.text,
                    inputFormatters: <TextInputFormatter>[
                      //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    //decoration: InputDecoration(labelText: 'Comentario'),
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
                  onPressed: ()  {

                    String newText = _controller1.text;
                    
                    if(comeId != null){
                      _updateCommentPrueba(context, comeId, dateTime, newText);
                      Navigator.of(context).pop();
                      return;
                    }
                    
                    _addCommentPrueba(context, newText);
                    Navigator.of(context).pop();

                    return;
                  },
                  child: const Text( // Muestra el texto "Guardar" si _isLoading es false
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
  


} 
