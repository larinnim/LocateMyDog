import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../Services/bluetooth_conect.dart';

// class FirestoreSetUp {
//   static final FirestoreSetUp _singleton = FirestoreSetUp._internal();

//   factory FirestoreSetUp() {
//     return _singleton;
//   }

//   FirestoreSetUp._internal();
// }

// class FirestoreSetUp {
//   String gateway = "";
//   String endDevice = "";

//   FirestoreSetUp._privateConstructor();

//   static final FirestoreSetUp _instance = FirestoreSetUp._privateConstructor();

//   static FirestoreSetUp get instance => _instance;
// }

class Step3 extends StatefulWidget {
  @override
  _Step3State createState() => new _Step3State();
}

class _Step3State extends State<Step3> {
  String _endDevice = 'Unknown';
  // String _endDevice = 'Unknown';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
                    'Step 3 of 3',
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
                        child: const Text('Scan End Deivce')),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      _endDevice,
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
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(barcodeScanRes);

      writeData(barcodeScanRes);
      
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _endDevice = barcodeScanRes;
      FirestoreSetUp.instance.endDevice = _endDevice;
    });
  }

  Future<void> writeData(String data) async {
    if (context.read<BleModel>().characteristics.elementAt(3) == null)
      return; //End Device Characteristic

    List<int> bytes = utf8.encode(data);
    await context
        .read<BleModel>()
        .characteristics
        .elementAt(3)
        .write(bytes); //Write End Device to ESP32

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Wrapper(),
      ));
  }
}
