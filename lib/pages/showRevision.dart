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


enum WidgetState { NONE, SHOW_MENU, LOADING, LOADED, SHOW_CODE,  ERROR_MQTT, ERROR_GRAPHQL }

class SelectMode extends StatefulWidget {
  const SelectMode({super.key});

  @override
  State<SelectMode> createState() => _SelectModeState();
}

class _SelectModeState extends State<SelectMode> {

  final String msgACK = 'ACK';
  final String msgConfirm = 'CONFIRM_TOKEN';
  WidgetState _widgetState = WidgetState.NONE;
  final mqttManager = MqttManager(
    broker: 'manuales.ribe.cl',
    port: 8883,
    username: 'root',
    password: '*R1b3x#99',
  );
  late OrgaInstrumento orgaInstrument;
  bool isActive = true;

  late List<OrgaRevisione> revisions;
  OrgaRevisione? dropdownValue;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

    final info = Provider.of<ProviderPages>(context, listen: false);

    //dropdownValue = info.revision;

    final result = await _getOrgaInstrument(info.organization.orgaId);
    if(!result){
      _widgetState = WidgetState.ERROR_GRAPHQL;
      setState(() {});
      return;
    }

    final resultmQTT = await _initMqtt();
    if(!resultmQTT){
      _widgetState = WidgetState.ERROR_MQTT;
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

    print(revisions);

    return true;
  }


  Future<bool> _initMqtt() async {
    try {
      await mqttManager.initialize();
      return true;
    } catch (e) {
      // Handle connection error, e.g., show a message to the user.
      print("Error initializing MQTT: $e");
      return false;
    }
  }

  void _subscribeTopic(String topic){
    final info = Provider.of<ProviderPages>(context, listen: false);

    mqttManager.subscribe(topic, (message) {
      if(message == msgACK){
        isActive = true;
        setState(() {});
        info.connected = "CONNECTED";
        mqttManager.publish(topic, msgConfirm);
        Navigator.pushNamed(context, 'instrument');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.NONE:
        return _buildScaffold(context,Center(
          child: CircularProgressIndicator(),
        ) ) ;

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

      case WidgetState.SHOW_CODE:
        return  _buildScaffold(context,_showCode(context) ) ;

      case WidgetState.ERROR_MQTT:
        return _buildScaffold(context,Center(
          child: Text("Error con MQTT"),
        ) ) ;

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
                    if(info.revision == null){
                      showMsg("Debe Seleccionar una Revisión");
                      return;
                    }
                    final _code = info.mainTopic;
                    _subscribeTopic(_code);
                    _widgetState= WidgetState.SHOW_CODE;
                    setState(() {

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
                    if(info.reviId == ""){
                      showMsg("Debe Seleccionar una Revisión");
                      return;
                    }
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

  Widget _showCode(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final code = info.mainTopic;

    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 24, // Tamaño de letra grande
                      fontWeight: FontWeight.bold, // Texto en negrita
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code)); // Copia el texto al portapapeles
                      ScaffoldMessenger.of(context).showSnackBar( // Muestra un mensaje de confirmación
                        const SnackBar(content: Text('Texto copiado')),
                      );
                    },
                    icon: const Icon(Icons.copy), // Icono de copiar
                  ),
                ],
              ),
              SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.themeColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: isActive
                    ? () async {
                  isActive = false; // Deshabilita el botón mientras se ejecuta la acción
                  String topic = info.mainTopic;
                  if (topic != "") {
                    mqttManager.unsubscribe(topic);
                  }
                  topic = Util.geenerateCode(5);
                  _subscribeTopic(topic);
                  info.mainTopic = topic;
                  info.connected = "";
                  setState(() {});

                }
                    : null,

                child: Text(isActive?'Generar Nuevo':'Esperando Conexión',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.redColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  if (info.mainTopic != "") {
                    mqttManager.unsubscribe(info.mainTopic);
                    info.mainTopic ="";
                  }
                  isActive = true;
                  setState(() {});
                },
                child: Text('Cancelar',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              SizedBox(height: 20,),

              (info.connected == '') ? SizedBox.shrink() : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.themeColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, 'instrument');
                },
                child: Text('Continuar',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.redColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  mqttManager.publish(info.mainTopic, msgACK);
                },
                child: Text('Simular ASK',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              Spacer(),

              Center(
                child: Text(
                  'Espere a que el Disposivo asociado este listo para continuar con la toma de la Foto',
                  style: const TextStyle(
                    fontSize: 14, // Tamaño de letra grande
                    fontWeight: FontWeight.normal, // Texto en negrita
                  ),
                  textAlign: TextAlign.center,
                ),
              ),


            ],
          ),
        )
    );
  }

  Widget  _revisionList(BuildContext context){
    final info = Provider.of<ProviderPages>(context);

    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder( // Define el borde
          //borderSide: BorderSide(color: Colors.grey), // Color del borde
          borderRadius: BorderRadius.circular(10.0), // Radio de las esquinas
        ),
        filled: true, // Habilita el color de fondo
        fillColor: Colors.white, // Color de fondo
      ),
      child: DropdownButton<OrgaRevisione>(
        value: dropdownValue, // Objeto actual seleccionado
        items: revisions.map<DropdownMenuItem<OrgaRevisione>>((OrgaRevisione value) {
          return DropdownMenuItem<OrgaRevisione>(
            value: value,
            child: Text(value.reviNumero,  style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),), //, // Muestra el nombre del objeto
          );
        }).toList(),
        onChanged: (OrgaRevisione? newValue) {
          setState(() {
            dropdownValue = newValue; // Actualiza el objeto seleccionado
            if (newValue != null) {
              info.revision = newValue;
              print('ID seleccionado: ${newValue.reviId}'); // Accede al ID del objeto
            }
          });
        },
        hint: const Text('Selecciona una Revisión', style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),),
      ),
    );

  }


}
