import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
//import 'package:flutter_bluetooth_serial/FlutterBluetoothSerial.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './main.dart';

class BtSelector extends StatefulWidget {
  BtSelector({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _BtSelectorState createState() => _BtSelectorState();
}

Map<String, String> deviceList = {};

BluetoothConnection connection;

FlutterBluetoothSerial fbs = FlutterBluetoothSerial.instance;

bool _isLooking = false;

class _BtSelectorState extends State<BtSelector> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
  }

  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  BluetoothConnection connection;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: new Icon(_isLooking ? Icons.cancel : Icons.refresh),
              onPressed: () {
                setState(() {
                  deviceList.clear();
                });
              },
            ),
            IconButton(
              icon: new Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  fbs.openSettings();
                  //print("settings");
                });
              },
            )
          ],
        ),
        body: new Container(
            child: new ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return new GestureDetector(
                      child: Card(
                        child: Container(
                          margin: EdgeInsets.all(20),
                          child: Text('${_devicesList[index].name}'),
                        ),
                        elevation: 10,
                      ),
                      onTap: () {
                        setState(() {
                          print(_devicesList);
                          MyHomePage().address = _devicesList[index].address;
                          try {
                            thisConnectionFunction(
                                _devicesList[index].address.toString());
                            isConnected = true;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage(
                                      title:
                                      "Bluetooth RemoteControl : Connected",
                                      isConnected: true,
                                    )));
                          } catch (exception) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage(
                                      title:
                                      "Bluetooth RemoteControl : Erreur",
                                      isConnected: false,
                                    )));
                          }
                        });
                      });
                })));
  }
}

thisConnectionFunction(String address) async {
  await BluetoothConnection.toAddress(address).then((myConnection) {
    connection = myConnection;
  });
}
