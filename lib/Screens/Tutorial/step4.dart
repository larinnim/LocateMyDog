import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/task_route.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/wifi_settings.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:flutter_maps/Screens/Tutorial/step5.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../loading.dart';

class Step4 extends StatefulWidget {
  @override
  _Step4State createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult? result;
  bool isBroad = true;
  TextEditingController password = TextEditingController();
  TextEditingController deviceCount = TextEditingController(text: "1");
  bool _obscureText = false;
  String _espIP = "";
  bool _isDisconnected = true;
  late PermissionStatus _locationPermissionStatus;

  void espIPReceived(String receivedIP) {
    setState(() {
      _espIP = receivedIP;
      _isDisconnected = false;
    });
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new Step5()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((e) {
      setState(() {});
    });
    // getLocationPermission();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // void getLocationPermission() async {
  //   final status = await Permission.location.request();
  //   setState(() {
  //     _locationPermissionStatus = status;
  //   });
  // }

  void goToTaskRoute(String ssid, String bssid) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => TaskRoute(
                ssid, bssid, password.text, deviceCount.text, isBroad)))
        .then((value) {
      password.clear();
      espIPReceived(value);
    });
  }

  Widget normalState(BuildContext context, String ssidName, String bssidName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 50.0,
        ),
        Visibility(
            visible: _isDisconnected,
            child: Image.asset(
              'assets/images/wifi_disconnected.png',
              fit: BoxFit.cover,
            ),
            replacement: Image.asset(
              'assets/images/wifi_connected.png',
              // fit: BoxFit.fill,
            )),
        SizedBox(
          height: 30.0,
        ),
        Visibility(
            visible: _isDisconnected,
            child: Text(
              'disconnected'.tr,
              style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[300]),
            ),
            replacement: Text(
              'connected'.tr,
              style: TextStyle(
                  fontSize: 72.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreen),
            )),
        SizedBox(
          height: 30.0,
        ),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "ssid".tr + " : \t ",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: ssidName,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ])),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "ip_address".tr + ' : \t',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: _espIP,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ])),
        SizedBox(
          height: 60,
        ),
        Visibility(
          visible: _isDisconnected,
          child: disconnectedPasswordRequest(context, ssidName, bssidName),
          replacement: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Step5()));
            },
          ),
        ),
      ],
    );
  }

  Widget disconnectedPasswordRequest(
      BuildContext context, String ssidName, String bssidName) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextField(
            obscureText: _obscureText,
            controller: password,
            cursorColor: Colors.black,
            decoration: InputDecoration(
                labelText: "password".tr + ' :',
                suffixIcon: IconButton(
                  icon: _obscureText
                      ? Icon(Icons.visibility, color: Colors.grey)
                      : Icon(Icons.visibility_off, color: Colors.grey),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.red),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.black),
                )),
          ),
        ),
        SizedBox(
          height: 60,
        ),
        SizedBox(
          width: 150.0,
          height: 50.0,
          child: ElevatedButton(
              onPressed: () async {
                if (password.text.isEmpty) {
                  Get.dialog(SimpleDialog(
                    title: Text(
                      "Required Fields",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    titlePadding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),
                    children: [
                      Text('Password field cannot be empty',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0)),
                    ],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ));
                } else {
                  print(password.text);
                  print(deviceCount.text);
                  // goToTaskRoute(ssidName, bssidName); //TODO enable when arina finishes the ESP32
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Step5()));
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red[300],
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
              ),
              child: Text("confirm".tr)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConnectivityWidgetWrapper(
      stacked: false,
      alignment: Alignment.topCenter,
      disableInteraction: true,
      message:
          "You are offline. Please connect to an active internet connection!",
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: _connectivity.checkConnectivity(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else if (snapshot.data == ConnectivityResult.wifi) {
                return FutureBuilder<Map<String, String>?>(
                    future: EsptouchSmartconfig.wifiData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 50.0,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text(
                                    'Step 4 of 5',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 20.0,
                                        fontFamily: 'RobotoMono'),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            // SizedBox(
                            //   height: 50.0,
                            // ),
                            Text(
                              "Now, Let's connect the Gateway to WiFi.",
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            normalState(context, snapshot.data!['wifiName']!,
                                snapshot.data!['bssid']!),
                          ],
                        ));

                        // return WifiPage(snapshot.data!['wifiName']!,
                        //     snapshot.data!['bssid']!);
                      } else
                        return Container();
                    });
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3),
                      Icon(
                        Icons.wifi_off_sharp,
                        size: 200,
                        color: Colors.red,
                      ),
                      Text(
                        "wifi_not_connected".tr,
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      )
                    ],
                  ),
                );
              }
            }),
      ),
    ));
  }
}
