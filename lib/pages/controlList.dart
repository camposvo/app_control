import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../models/variable.dart';
import '../providers/providers_pages.dart';

class ControlList extends StatefulWidget {
  @override
  _ControlListState createState() => _ControlListState();
}

class _ControlListState extends State<ControlList> {
  final client = MqttServerClient('manuales.ribe.cl', '');
  List<DataItem> data = [];
  List<DataItem> _filterList = [];
  int _counter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadData_demo();
    //_loadData();
    //_startTimer();
  }

  Future<void> _loadData() async {
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.secure = true;
    client.port =  8883;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000; // milliseconds

    try {
      final connMessage = await client.connect("root", "*R1b3x#99");
      print("client connecting result $connMessage");
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {

      print(
          'ERROR Mosquitto client connection failed - status is ${client.connectionStatus}');
      client.disconnect();
      //exit(-1);
    }

    print('EXAMPLE::Subscribing to the test/lol topic');
    client.subscribe("B65/#", MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      data = parseData(pt);
      _filterList = parseData(pt);
      _counter = 0;
      setState(() {});
      print('topic is <${c[0].topic}>, payload is <-- $pt -->');
      // Accediendo a los datos
      print(data[0].key); // Imprime "AL1"
      print(data[0].time); // Imprime el objeto DateTime
      print(data[0].value); // Imprime 9.49
    });

    client.published!.listen((MqttPublishMessage message) {
      print(
          'notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });
  }


  Future<void> _loadData_demo() async {
    client.logging(on: true);

    DataItem dataItem1 = DataItem(
      key: 'AL1',
      time: DateTime.now(),
      value: 25.5,
    );

    DataItem dataItem2 = DataItem(
      key: 'AL2',
      time: DateTime.now(),
      value: 28.5,
    );

   data.add(dataItem1);
   data.add(dataItem2);

   _filterList.add(dataItem1);
   _filterList.add(dataItem2);


  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        _counter++;
      }),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void onConnected() {
    print('Connected');
    client.subscribe('mytopic', MqttQos.atLeastOnce);
  }

  void onDisconnected() {
    print('Disconnected');
    print('client disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

  void onMessage(String topic, MqttMessage message) {
    final payload = message;
    print('Received message: $payload from topic: $topic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.containerBody,
        appBar: setAppBarTwo(context, "MQTT Cliente"),
        body: contentBody(context));
  }

  Widget contentBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          SizedBox(
            height: 7,
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
        height: MediaQuery.of(context).size.height - 20,
        child: _filterList.length > 0
            ? ListView.builder(
                itemCount: _filterList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      child: _itemListView(index, context), onTap: () {});
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
    final nombre = data[index].key;
    final valor = data[index].value;
    final hora = data[index].time;
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
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  setCommonText(_counter.toString(), Colors.black, 14.0, FontWeight.w800, 20),
                  setCommonText(nombre, Colors.black, 14.0, FontWeight.w800, 20),
                  setCommonText(
                      hora.toString(), Colors.black, 14.0, FontWeight.w800, 20),
                  setCommonText(
                      valor.toString(), Colors.black, 14.0, FontWeight.w800, 20),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(20.0),
                ),
                onPressed: () async {
                  //await api.testNotify(info.persona.user.pkUsuario);
                  Navigator.pushNamed(context, 'takePhoto');
                },
                child: Text('Ir',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // FIn MAIN WIDGET
