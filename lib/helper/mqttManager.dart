import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class MqttManager {
  final client = MqttServerClient('manuales.ribe.cl', '');
  final String broker;
  final int port;
  final String username;
  final String password;
  final Map<String, Stream<List<MqttReceivedMessage<MqttMessage?>>?>> _topicStreams = {};

  MqttManager({
    required this.broker,
    required this.port,
    required this.username,
    required this.password,
  });

  Future<void> initialize() async {
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.secure = true;
    client.port = 8883;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000; // milliseco

    try {
      await client.connect(username, password);
      print('MQTT client connected');
    } on NoConnectionException catch (e) {
      print('MQTT client connection exception - $e');
      client.disconnect();
      throw e; // Re-throw the exception for handling elsewhere
    }

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      print('ERROR: MQTT client connection failed - status is ${client.connectionStatus}');
      client.disconnect();
      throw Exception('MQTT connection failed'); // Throw exception
    }
  }


  void subscribe(String topic, Function(String) messageCallback) {
    if (!_topicStreams.containsKey(topic)) {
      client.subscribe(topic, MqttQos.atLeastOnce);

      _topicStreams[topic] = client.updates!.where((messages) => messages != null).map((messages) => messages!.where((message) => message.topic == topic).toList());

      _topicStreams[topic]!.listen((messages) {
        if (messages != null && messages.isNotEmpty) {
          for (var message in messages) {
            final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
            final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
            messageCallback(pt);
          }
        }
      });
    } else {
      print("Ya estas suscrito a este topico");
    }
  }


  void publish(String topic, String message) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      print('ERROR: MQTT client is not connected. Cannot publish.');
    }
  }

  void publishAndRetain(String topic, String message) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: true);
    } else {
      print('ERROR: MQTT client is not connected. Cannot publish.');
    }
  }

  void unsubscribe(String topic) {
    client.unsubscribe(topic);
    _topicStreams.remove(topic);
  }

  void disconnect() {
    client.disconnect();
  }

  void _onConnected() {
    print('MQTT client connected');
  }

  void _onDisconnected() {
    print('MQTT client disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

}