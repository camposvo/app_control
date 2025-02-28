import 'package:control/models/organizacion.dart';
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

enum WidgetState { SHOW_MENU, LOADING, LOADED, ERROR_GRAPHQL }

class ShowRevision extends StatefulWidget {
  const ShowRevision({super.key});

  @override
  State<ShowRevision> createState() => _ShowRevisionState();
}

class _ShowRevisionState extends State<ShowRevision> {

  WidgetState _widgetState = WidgetState.LOADING;

  late OrgaInstrumento orgaInstrument;
  late List<OrgaRevisione> revisions;
  OrgaRevisione? dropdownValue;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final result = await _getOrgaInstrument(info.organization.orgaId);
    if(!result){
      _widgetState = WidgetState.ERROR_GRAPHQL;
      setState(() {});
      return;
    }

    _widgetState = WidgetState.SHOW_MENU;
    setState(() {});

  }

  Future<bool> _getOrgaInstrument(String id) async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final result =await api.getOrganInstruments(id);
    if(result == null){
      return false;
    }

    final _orgaInstruments = orgaInstrumentoFromJson(result);

    info.orgaInstrument = _orgaInstruments.firstWhere((item) => item.orgaId == id);
    orgaInstrument = _orgaInstruments.firstWhere((item) => item.orgaId == id);
    revisions = orgaInstrument.orgaRevisiones;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {

      case WidgetState.SHOW_MENU:
        return _buildScaffold(context,_menu(context) ) ;

      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child: CircularProgressIndicator(),
        ) ) ;

      case WidgetState.LOADED:
        return Center(
          child: Text("La cámara No se pudo Cargar. Reincie la App"),
        );


      case WidgetState.ERROR_GRAPHQL:
        return _buildScaffold(context,Center(
          child: Text("Error con el Servidor Graphql"),
        ) ) ;

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return Scaffold(
        appBar: setAppBarTwo(context, info.organization.orgaNombre),
        body: body
    );
  }

  Widget _menu(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 20,
                ),
                _revisionList(context),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(width -20, 40),
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                    ),
                    backgroundColor: AppColor.themeColor,
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {
                    if(dropdownValue == null){
                      showMsg("Debe Seleccionar una Revisión");
                      return;
                    }

                    info.revision = dropdownValue;
                    Navigator.pushNamed(context, 'selectMode')
                        .then((_) async {
                    });

                  },
                  child: Text('Sin Sistema',  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),),
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(width -20, 40),
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                    ),
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {
                   /* if(info.reviId == ""){
                      showMsg("Debe Seleccionar una Revisión");
                      return;
                    }*/
                    //await api.testNotify(info.persona.user.pkUsuario);
                    //Navigator.pushNamed(context, 'Automatico');
                  },
                  child: Text('Con Sistema',  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget  _revisionList(BuildContext context){
    final info = Provider.of<ProviderPages>(context);

    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder( // Define el borde
          borderRadius: BorderRadius.circular(10.0), // Radio de las esquinas
        ),
        filled: true, // Habilita el color de fondo
        fillColor: Colors.white, // Color de fondo
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      ),
      child: DropdownButton<OrgaRevisione>(
        value: dropdownValue, // Objeto actual seleccionado
        items: revisions.map<DropdownMenuItem<OrgaRevisione>>((OrgaRevisione value) {
          return DropdownMenuItem<OrgaRevisione>(
            value: value,
            child: Text(value.reviNumero,  style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),), //, // Muestra el nombre del objeto
          );
        }).toList(),
        onChanged: (OrgaRevisione? newValue) {
          setState(() {
            if (newValue != null) {
              dropdownValue = newValue;
              print('ID seleccionado: ${newValue.reviId}'); // Accede al ID del objeto
            }
          });
        },
        hint: const Text('Selecciona una Revisión', style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),),
      ),
    );

  }

}
