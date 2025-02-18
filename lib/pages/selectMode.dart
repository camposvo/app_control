import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';

import '../helper/common_widgets.dart';
import '../helper/mqttManager.dart';
import '../helper/util.dart';
import '../models/orgaInstrumento.dart';
import 'package:flutter/services.dart';


enum WidgetState { NONE, SHOW_MENU, LOADING, LOADED, SHOW_CODE,  ERROR_MQTT }

class SelectMode extends StatefulWidget {
  const SelectMode({super.key});

  @override
  State<SelectMode> createState() => _SelectModeState();
}

class _SelectModeState extends State<SelectMode> {
  final String TOPIC_ASK = 'TOPIC_ASK';
  final String TOPIC_CONFIRM = 'TOPIC_CONFIRM';
  WidgetState _widgetState = WidgetState.NONE;
  final mqttManager = MqttManager(
    broker: 'manuales.ribe.cl',
    port: 8883,
    username: 'root',
    password: '*R1b3x#99',
  );
  late OrgaInstrumento organization;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOADING;
    setState(() {});

    final info = Provider.of<ProviderPages>(context, listen: false);
    final id = info.orgaId;
    organization = info.organizations.firstWhere((item) => item.orgaId == id);
    await _initMqtt();

    _widgetState = WidgetState.SHOW_MENU;
    setState(() {});

  }

  Future<void> _initMqtt() async {
    try {
      await mqttManager.initialize();
    } catch (e) {
      // Handle connection error, e.g., show a message to the user.
      print("Error initializing MQTT: $e");
    }
  }

  void _subscribeTopic(String topic){
    final info = Provider.of<ProviderPages>(context, listen: false);

    mqttManager.subscribe(topic, (message) {
      if(message == TOPIC_ASK){
        info.connected = "CONNECTED";
        mqttManager.publish(topic, TOPIC_CONFIRM);
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

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
        appBar: setAppBarTwo(context, organization.orgaNombre),
        body: body
    );
  }

  Widget _menu(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final organization = info.organizations.firstWhere((item) => item.orgaId == info.orgaId);
    print(organization.orgaNombre);

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
                  height: 100,
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
                onPressed: () async {
                  String topic = info.mainTopic;
                  if(topic !=""){
                    mqttManager.unsubscribe(topic);
                  }
                  topic = Util.geenerateCode(5);
                 _subscribeTopic(topic);
                  info.mainTopic = topic;
                  info.connected = "";
                  setState(() {});

                },

                child: Text('Generar Nuevo',  style: TextStyle(
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
                  mqttManager.publish(info.mainTopic, TOPIC_ASK);
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
}
