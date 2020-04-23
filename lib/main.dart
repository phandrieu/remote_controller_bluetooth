import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:control_pad/control_pad.dart';
import './bt_selector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(new MyApp());
  });
}

bool _connected = false;
bool handOpened = true;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(
        title: 'Bluetooth RemoteControl',
        isConnected: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, isConnected}) : super(key: key);
  BluetoothConnection connection01;
  String address;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

int j1Direction;
int j2Direction;
int j1Force;
int j2Force;

bool isConnected = false;
bool timedOutPassed = true;
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    JoystickDirectionCallback onDirectionChangedJ1(
        double degrees, double distance) {if(isConnected) {
          double degrees2 = (degrees/360)*8;
          int direction = degrees2.round();
          j1Direction = direction;
          j1Force = (distance*100).toInt();
          parseAndSend();
    }}

    JoystickDirectionCallback onDirectionChangedJ2(
        double degrees, double distance) {if(isConnected) {
        double degrees2 = (degrees/360)*8;
        int direction = degrees2.round();
        j2Direction = direction;
        j2Force = (distance*100).toInt();
        parseAndSend();
    }}

    return Scaffold(
        appBar: AppBar(
          leading: Icon(isConnected ? Icons.cast_connected : Icons.cast),
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Center(
            child: Text(
              isConnected
                  ? "Roboti'Cse RemoteControl : Connected"
                  : "Roboti'Cse RemoteControl : Disconnected",
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon: new Icon(Icons.bluetooth),
                onPressed: isConnected
                    ? null
                    : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BtSelector(
                            title:
                            "Sélection du périphérique Bluetooth",
                          )));
                }),
            IconButton(
              icon: new Icon(Icons.bluetooth_disabled),
              onPressed: isConnected
                  ? () {
                setState(() {
                  connection.close();
                  isConnected = false;
                });
              }
                  : null,
            )
          ],
        ),
        body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Container(child: new JoystickView(onDirectionChanged: onDirectionChangedJ1,interval: Duration(milliseconds: 1), innerCircleColor: ThemeData.dark().accentColor,),margin: EdgeInsets.all(20),),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new FloatingActionButton(
                      heroTag: "btnStop",
                      onPressed: () {
                        setState(() {
                          connection.output.add(ascii.encode("stop\n\r"));
                        });
                      },
                      child: new Icon(Icons.new_releases),
                    ),

                    new FloatingActionButton(
                      heroTag: "btnHand",
                      onPressed: handOpened?
                          (){
                              setState(() {
                                  connection.output.add(ascii.encode("close\n\r"));
                                  handOpened = false;
                              });
                      }:
                          (){
                              setState(() {
                                  connection.output.add(ascii.encode("open\n\r"));
                                  handOpened = true;
                              });
                      },
                      child: new Icon(Icons.pan_tool),
                      backgroundColor: handOpened?ThemeData.dark().accentColor:Colors.blue,
                    ),
                    new FloatingActionButton(
                        heroTag: "btnReset",
                        onPressed: (){
                          setState(() {
                            connection.output.add(ascii.encode("reset\n\r"));
                          });
                        },
                        child: new Icon(Icons.find_replace)
                    ),
                  ]
              ),
              new Container(child: new JoystickView(onDirectionChanged: onDirectionChangedJ2,interval: Duration(milliseconds: 1), innerCircleColor: ThemeData.dark().accentColor,),margin: EdgeInsets.all(20),)
            ]));
  }
}



void parseAndSend(){
  int b = 0;
  int x = 0;
  int y = 0;
  int z = 0;
  switch (j1Direction){
    case 0:
      x = j1Force;
      b = 0;
      break;
    case 1:
      x = j1Force;
      b = j1Force;
      break;
    case 2:
      b = j1Force;
      x = 0;
      break;
    case 3:
      b = j1Force;
      x = (-1)* j1Force;
      break;
    case 4:
      x = (-1)*j1Force;
      b = 0;
      break;
    case 5:
      x = (-1)*j1Force;
      b = (-1)*j1Force;
      break;
    case 6:
      b = (-1)*j1Force;
      x = 0;
      break;
    case 7:
      b = (-1)*j1Force;
      x = j1Force;
      break;
    case 8:
      x = j1Force;
      b = 0;
      break;
  }
  switch (j2Direction){
    case 0:
      y = (-1)*j2Force;
      z = 0;
      break;
    case 1:
      y = (-1)*j2Force;
      z = j2Force;
      break;
    case 2:
      z = j2Force;
      y = 0;
      break;
    case 3:
      z = j2Force;
      y = j2Force;
      break;
    case 4:
      y = j2Force;
      z = 0;
      break;
    case 5:
      y = j2Force;
      z = (-1)*j2Force;
      break;
    case 6:
      z = (-1)*j2Force;
      y = 0;
      break;
    case 7:
      z = (-1)*j2Force;
      y = (-1)*j2Force;
      break;
    case 8:
      y = (-1)*j2Force;
      z = 0;
      break;
  }
  String data = "move ${b.toString()},${x.toString()},${y.toString()},${z.toString()}\n\r";
  connection.output.add(ascii.encode(data));
  print(data);
}