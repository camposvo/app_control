import 'package:control/models/organizacion.dart';
import 'package:control/models/resultRevision.dart';
import 'package:control/pages/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';

import '../api/client.dart';
import '../helper/common_widgets.dart';
import '../helper/mqttManager.dart';
import '../helper/util.dart';
import '../models/orgaInstrumento.dart';
import 'package:flutter/services.dart';

enum WidgetState { LOADED, LOADING, ERROR_GRAPHQL }

class ShowRevision extends StatefulWidget {
  const ShowRevision({super.key});

  @override
  State<ShowRevision> createState() => _ShowRevisionState();
}

class _ShowRevisionState extends State<ShowRevision> {

  WidgetState _widgetState = WidgetState.LOADING;

  late OrgaInstrumento orgaInstrument;
  List<OrgaRevisione> _revisions = [];
  List<OrgaRevisione> _filterList = [];
  
  OrgaRevisione? dropdownValue;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final result = await _getOrgaInstrument(info.organization!.orgaId);
    if(!result){
      _widgetState = WidgetState.ERROR_GRAPHQL;
      setState(() {});
      return;
    }

    _widgetState = WidgetState.LOADED;
    setState(() {});

  }

  Future<void> _initSendData() async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    _widgetState = WidgetState.LOADED;
    setState(() {});

    info.resultData.orgaId = info.organization!.orgaId;
    info.resultData.comentarios = [];
    info.resultData.pruebas = [];

/*    for (var item in orgaInstrument.orgaInstrumentos) {
      for (var comment in item.instComentarios) {
        Comentario comentario = new Comentario(
         comeDescripcion: comment.comeDescripcion,
         comeFecha: comment.comeFecha,
         comeId: comment.comeId,
         comeInstId: item.instId,
         comeReviId: comment.comeReviId,
        );
        info.resultData.comentarios.add(comentario);
      }

      for (var variable in item.instVariables) {
        for (var test in variable.puntPrueba) {
          Prueba prueba = new Prueba(
            reviNumero: test.reviNumero,
            prueReviId:test.prueReviId,
            prueRecurso1: test.prueFoto1,
            prueRecurso2: test.prueFoto2,
            pruePuntId: variable.puntId,
            prueFecha: test.prueFecha,
            prueComentario: test.prueDescripcion,
            prueId: test.prueId,

          );
          info.resultData.pruebas.add(prueba);
        }
      }

    }*/

    Util.printInfo("pruebas", api.getPrettyJSONString(info.resultData));

  }

  Future<bool> _getOrgaInstrument(String id) async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final result =await api.getOrganInstruments(id);

    //final result =await  api.getOrganInstrumentsFromJson();

    if(result == null){
      return false;
    }

    final _orgaInstruments = orgaInstrumentoFromJson(result);
    final temp = _orgaInstruments.firstWhere((item) => item.orgaId == id);

    info.mainData.clear();
    info.mainData.add(temp);
    info.mainDataUpdate(info.mainData);

    orgaInstrument = _orgaInstruments.firstWhere((item) => item.orgaId == id);
    _revisions = [...orgaInstrument.orgaRevisiones];
    _filterList = [...orgaInstrument.orgaRevisiones];

    return true;
    
  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {

      case WidgetState.LOADED:
        return _buildScaffold(context,_showList(context) ) ;

      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child:  circularProgressMain(),
        ) ) ;

      case WidgetState.ERROR_GRAPHQL:
        return _buildScaffold(context,Center(
          child: Text("Error con el Servidor Graphql"),
        ) ) ;

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final name = info.organization != null  ? info.organization!.orgaNombre : '';

    return Scaffold(
        drawer: setDrawer(context),
        appBar: setAppBarMain(context, name,"Revisiones"),
        body: body
    );
  }

  _onSearch(String search) {
    _filterList = _revisions.where((item) {
      return item.reviNumero.toLowerCase().contains(search);
    }).toList();

    setState(() {});
  }

  _search() {
    return Container(
      height: 48,
      child: TextField(
        onChanged: (value) => _onSearch(value),
        decoration: setSearchDecoration(),
      ),
    );
  }

  Widget _showList(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          _search(),
          SizedBox(
            height: 7,
          ),
          Expanded(
            child:_createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {

    final info = Provider.of<ProviderPages>(context, listen: false);

    return Container(
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () async {
              info.revision = _filterList[index];
              info.isOrganization = true;

             await _initSendData();

              info.refreshData();

              Navigator.popUntil(context, (route) => route.isFirst);


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
    final name = _filterList[index].reviNumero;

    final widthItem = MediaQuery.of(context).size.width - 80;

    return new Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        color: Colors.grey,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(10),
        child: new Padding(
          padding: new EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: widthItem,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    setCommonText2(name.toUpperCase(), Colors.white, 20.0, FontWeight.w800, 20),

                  ],
                ),
              ),
              /*ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.secondaryColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () {

                  info.revision = _filterList[index];
                  info.isOrganization = true;
                 info.refreshData();

                  Navigator.popUntil(context, (route) => route.isFirst);

                },
                child: Text('Ir',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

}
