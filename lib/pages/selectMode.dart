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


enum WidgetState { LOADING, SHOW_CODE,  ERROR_MQTT }

class SelectMode extends StatefulWidget {
  const SelectMode({super.key});

  @override
  State<SelectMode> createState() => _SelectModeState();
}

class _SelectModeState extends State<SelectMode> {

  final String msgACK = 'ACK';
  final String msgConfirm = 'CONFIRM_TOKEN';
  WidgetState _widgetState = WidgetState.LOADING;
  final mqttManager = MqttManager(
    broker: 'manuales.ribe.cl',
    port: 8883,
    username: 'root',
    password: '*R1b3x#99',
  );
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

   final resultmQTT = await _initMqtt();
    if(!resultmQTT){
      _widgetState = WidgetState.ERROR_MQTT;
      setState(() {});
      return;
    }

    _widgetState = WidgetState.SHOW_CODE;
    setState(() {});

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
        info.connected = true;
        mqttManager.publish(topic, msgConfirm);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child: circularProgressMain(),
        ) ) ;

      case WidgetState.SHOW_CODE:
        return  _buildScaffold(context,_showCode(context) ) ;

      case WidgetState.ERROR_MQTT:
        return _buildScaffold(context,Center(
          child: Text("Error con MQTT"),
        ) ) ;

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {

    final info = Provider.of<ProviderPages>(context, listen: false);
    final name = info.isOrganization ? info.organization!.orgaNombre : '';

    return Scaffold(
        drawer: setDrawer(context),
        appBar: setAppBarMain(context, name, "Emparejar Dispositivo"),
        body: body
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
                  info.connected = false;
                  setState(() {});

                }
                    : null,

                child: Text(isActive?'Crear Codigo':'Esperando Conexión',  style: TextStyle(
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

              (!info.connected) ? SizedBox.shrink() : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.themeColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, '/dashboard');
                },
                child: Text('Continuar',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              SizedBox(height: 20,),

             /* ElevatedButton(
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
              ),*/

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


}
