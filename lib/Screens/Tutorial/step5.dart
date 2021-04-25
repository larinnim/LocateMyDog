import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'step3.dart';
import '../../locator.dart';

class Step5 extends StatefulWidget {
  @override
  _Step5State createState() => new _Step5State();
}

class _Step5State extends State<Step5> {
  String? _endDevice = 'Unknown';

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: new Container(
          decoration: BoxDecoration(color: Colors.white),
          child: SafeArea(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
            child: Column(children: <Widget>[
              Row(
                children: [
                  Text(
                    'Step 4 of 3',
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        splashColor: Colors.blueGrey,
                        onPressed: scanQR,
                        // onPressed: ,

                        child: const Text('SCAN End Device')),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      _endDevice!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ]),
          )),
        ));
  }

  Future<void> scanQR() async {
    String? barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    //       "#ff6666", "Cancel", true, ScanMode.QR);
    //   print(barcodeScanRes);
    //   createRecord();
    // } on PlatformException {
    //   barcodeScanRes = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _endDevice = barcodeScanRes;
      FirestoreSetUp.instance.endDevice = _endDevice;
    });
  }

  //Create Firestore record
  void createRecord() async {
    await FirebaseFirestore.instance
        .collection("locateDog")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("gateway")
        .doc(FirestoreSetUp.instance.gateway).set({
          "timestamp": ""
        },  SetOptions(merge: true)).then((value) async => {
  await FirebaseFirestore.instance
    .collection("locateDog")
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection("endDevice")
    .doc(FirestoreSetUp.instance.endDevice).set({
      'latitude': 0.0,
      'longitude': 0.0,
      'rssi': 0,
      'ssid': "",
      "timestamp": ""}, SetOptions(merge: true)).then((value) {
      print("New struture on Firebase");
        Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ));
    }).catchError((error, stackTrace) {
      print("Error setting up new Firebase structure: $error");
    })}) .catchError((error, stackTrace) {
      print("Error setting up new Firebase structure: $error");
    });
  }
}
