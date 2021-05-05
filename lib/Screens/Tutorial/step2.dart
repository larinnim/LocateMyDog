import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Tutorial/step3.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:flutter_maps/Screens/Tutorial/step5.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/permissionChangeBuilder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../Services/bluetooth_conect.dart';

class Step2 extends StatefulWidget {
  @override
  _Step2State createState() => new _Step2State();
}

class _Step2State extends State<Step2> {
  String? _gatewayDevice = '';
  late String _barcodeScanRes;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  initState() {
    requestLocation();

    super.initState();
  }

  void requestLocation() async {
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PermisisonChangeBuilder(
          permission: Permission.camera,
          builder: (context, status) {
            if (status != PermissionStatus.granted) {
              return new Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150.0,
                  ),
                  Image.asset(
                    'assets/images/denied.png',
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'You need to allow camera to continue to use this app',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  ElevatedButton(
                      child: Text("OK".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                  side: BorderSide(color: Colors.red)))),
                      onPressed: () => AppSettings.openAppSettings())
                ],
              ));
            } else {
              return Material(
                  type: MaterialType.transparency,
                  child: new Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: SafeArea(
                        child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 40.0),
                      child: Column(children: <Widget>[
                        Row(
                          children: [
                            Text(
                              'Step 2 of 5',
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
                              'Scan QR Code',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                  fontFamily: 'RobotoMono'),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(
                                            Colors.blue),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0),
                                    ))),
                                child: Text(
                                  'Scan Gateway Device',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  scanQR();
                                },
                              ),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(
                            //       horizontal: 16.0, vertical: 8.0),
                            //   child: Text(
                            //     _gatewayDevice!,
                            //     textAlign: TextAlign.center,
                            //   ),
                            // ),
                          ],
                        ),
                      ]),
                    )),
                  ));
            }
          }),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(barcodeScanRes);
      setState(() {
        _barcodeScanRes = barcodeScanRes;
      });
      if (_barcodeScanRes == '-1') {
        AppSettings.openAppSettings();
      } else {
        sendGatewayID(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _gatewayDevice = barcodeScanRes;
      // FirestoreSetUp.instance.endDevice = _gatewayDevice;
    });
  }

  Future<void> sendGatewayID(String gatewayMac) async {
    await DatabaseService(uid: _firebaseAuth.currentUser!.uid)
        .createGateway(gatewayMac)
        .then((value) => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Step3(_gatewayDevice!),
            )));
  }
}
