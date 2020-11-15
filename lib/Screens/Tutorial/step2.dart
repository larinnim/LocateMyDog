import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Screens/Tutorial/step3.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/setWiFiConf.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wifi/wifi.dart';
import '../../Services/custom_expansion_tile.dart' as custom;

class Step2 extends StatefulWidget {
  @override
  _Step2State createState() => new _Step2State();
}

class _Step2State extends State<Step2> {
  List<WifiResult> ssidList = [];
  String _wifiName = '';
  String ssid = '', password = '';
  dynamic _percentage = 0.8;
  bool _loading = true;
  bool _visible = true;
  var timestampWifiLocal;

  @override
  initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: new Container(
            child: SafeArea(
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Column(children: <Widget>[
                          Row(
                            children: [
                              Text(
                                'Step 2 of 3',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20.0,
                                    fontFamily: 'RobotoMono'),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              Text(
                                'Connect Gateway to WiFi',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                    fontFamily: 'RobotoMono'),
                              )
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: ssidList.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                // return ListTile(
                                //   title: Text('Hello'),
                                // );
                                return itemSSID(index);
                              },
                            ),
                          ),
                        ]))))));
  }

  Widget itemSSID(index) {
    if (index == 0) {
      return Column(children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Visibility(
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          icon: Icon(Icons.wifi),
                          hintText:
                              _wifiName == "" ? "Tap your network" : _wifiName,
                        ),
                        keyboardType: TextInputType.text,
                        readOnly: true,
                      ),
                      TextField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          icon: Icon(Icons.lock_outline),
                          hintText: 'Your wifi password',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      SizedBox(height: 40.0),
                      MaterialButton(
                        color: Colors.orange,
                        child: Text('Submit',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          submitAction();
                        },
                      ),
                      SizedBox(height: 20.0),
                    ])),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: _visible,
              ),
            ),
          ],
        )
      ]);
    } else {
      return Consumer<WiFiModel>(builder: (_, wifiProvider, child) {
        return ssidList[index - 1].ssid != ""
            ? Container(
                color: Color(0xffd3d3d3),
                child: Column(children: <Widget>[
                  Visibility(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(children: <Widget>[
                        Flexible(
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _wifiName = ssidList[index - 1].ssid;
                              });
                            },
                            tileColor: Colors.white,
                            leading: Image.asset(
                                'assets/images/wifi${ssidList[index - 1].level}.png',
                                width: 28,
                                height: 21),
                            title: Text(
                              ssidList[index - 1].ssid,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16.0,
                              ),
                            ),
                            trailing: wifiProvider.ssid.toString() ==
                                    ssidList[index - 1].ssid.toString()
                                ? Wrap(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Connected",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      Icon(
                                        LineAwesomeIcons.check_circle_1,
                                        color: Colors.green,
                                      )
                                    ],
                                  )
                                : Wrap(),
                            dense: true,
                          ),
                        ),
                        Divider(),
                      ]),
                    ),
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _visible,
                  )
                ]),
              )
            : Column();
      });
      // }
    }
  }

  Future<void> submitAction() async {
    // var wifiData = '${wifiNameController.text},${wifiPasswordController.text}';
    var wifiData = '$_wifiName,$password';
    writeData(wifiData);
    timestampWifiLocal = DateTime.now();
    var document = await FirebaseFirestore.instance
        .collection('locateDog')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {})
        .catchError((e) {
      print("Error retrieving from Firebase $e");
    });
    FirestoreSetUp.instance.gateway = document.data["gateway"];
    //after 2 seconds verify if timestamp of Wifi is newer on the database
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (DateTime.fromMillisecondsSinceEpoch(
              document.data['wifiTimestamp'] * 1000)
          .isAfter(timestampWifiLocal)) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Step3(),
        ));
      }
    });
  }

  void loadData() async {
    Wifi.list('').then((list) {
      setState(() {
        List<WifiResult> resArr = [];
        list.forEach((item) {
          var i = resArr.indexWhere((x) => x.ssid == item.ssid);
          if (i <= -1) {
            resArr.add(item);
            print(item.ssid);
          }
        });
        ssidList = resArr;
      });
    });
  }

  getPercentageIndicator(context, var1, var2) {
    return LinearPercentIndicator(
      width: MediaQuery.of(context).size.width - 50,
      animation: true,
      lineHeight: 20.0,
      animationDuration: 2000,
      percent: var1,
      center: Text(var2),
      linearStrokeCap: LinearStrokeCap.roundAll,
      progressColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.2),
    );
  }

  Future<void> writeData(String data) async {
    if (context.read<BleModel>().characteristics.elementAt(2) == null)
      return; //WiFi Characteristic

    List<int> bytes = utf8.encode(data);
    await context
        .read<BleModel>()
        .characteristics
        .elementAt(2)
        .write(bytes); //Write WiFi to ESP32
  }
}
