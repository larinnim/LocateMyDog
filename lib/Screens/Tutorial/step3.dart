import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_test/flutter_test.dart';

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
  String _gateway = 'Unknown';
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
                        // onPressed: ,

                        child: const Text('Scan Gateway')),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      _gateway,
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
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Step4(),
      ));
      // createRecord();
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _gateway = barcodeScanRes;
      FirestoreSetUp.instance.gateway = _gateway;
    });
  }

  // void createRecord() async {
  //   await FirebaseFirestore.instance.collection("locateDog").doc(_firebaseAuth.currentUser.uid).collection(_gateway);
  // .doc(uid)
  // .set(_scanBarcode);

  // await FirebaseFirestore.instance
  //     .collection('locateDog')
  //     .doc('ifYourIdCostumized')
  //     .update({field: _scanBarcode});
  // .then(function () {
  //     console.log("Document successfully updated!");
  // }).catch(function (error) {
  //     // console.error("Error removing document: ", error);

  // });
  // .set({
  //   'title': 'Mastering Flutter',
  //   'description': 'Programming Guide for Dart'
  // });

  // DocumentReference ref =
  //     await FirebaseFirestore.instance.collection("books").add({
  //   'title': 'Flutter in Action',
  //   'description': 'Complete Programming Guide to learn Flutter'
  // });
  // print(ref.documentID);
  // }
}
