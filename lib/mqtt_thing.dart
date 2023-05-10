import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';



class Mqtt_Thing{

  final client = MqttServerClient ('mqtt3.thingspeak.com', '');
  var pongCount = 0;


  Future<void> doThePub() async {
    client.logging(on: false);
    client.setProtocolV311();
    client.keepAlivePeriod = 10;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('NSknBzkFHwQWEDoWFgIJIRM')
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .authenticateAs('NSknBzkFHwQWEDoWFgIJIRM', 'nHXYny36uXGGwOdDlKc+Cb+H')
        .withWillQos(MqttQos.atMostOnce);
    print('client connecting....');
    client.connectionMessage = connMess;

    print("222222222222222222222");
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('CONNECTED!!!  =================');
    } else {
      print('EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }


    const pubTopic = 'channels/1704368/publish/fields/field1';
    final builder = MqttClientPayloadBuilder();
    builder.addString("-20");

    print('>>>>>> Publishing .............');
    client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);

    /// Wait for the unsubscribe message from the broker if you wish.
    await MqttUtilities.asyncSleep(2);
    print('EXAMPLE::Disconnecting');
    client.disconnect();
    print('EXAMPLE::Exiting normally');

    pongCount=0;//just resetting it

  return;
  }//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('OnDisconnected() client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==  MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    }
    if (pongCount == 3) {
      print('EXAMPLE:: Pong count is correct');
    } else {
      print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }


  void onConnected() {print('OnConnected() client callback - Client connection was successful');}


  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }



}