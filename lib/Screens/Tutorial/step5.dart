import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Devices/device.dart';
import 'package:flutter_maps/Screens/Devices/device_detail.dart';
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../loading.dart';
import 'step3.dart';
import '../../locator.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:flutter_maps/Services/database.dart';

class Step5 extends StatefulWidget {
  @override
  _Step5State createState() => new _Step5State();
}

class _Step5State extends State<Step5> {
  String? _endDevice = 'Unknown';
  List<Device> _devices = [];
  List<Color> _availableColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red
  ];
  CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  initState() {
    super.initState();
  }

  void completedSetup(bool completed) async {
    await DatabaseService(uid: _firebaseAuth.currentUser!.uid)
        .completedSetup(completed)
        .then((value) => Get.off(Wrapper()));
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference sendersStream = FirebaseFirestore.instance
        .collection('locateDog')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('gateway');

    return StreamBuilder<QuerySnapshot>(
        stream: sendersStream.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          return Material(
              type: MaterialType.transparency,
              child: new Container(
                decoration: BoxDecoration(color: Colors.white),
                child: SafeArea(
                    child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                  child: Column(children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'Step 5 of 5',
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
                    Visibility(
                      visible: snapshot.data!.docs.length < 4,
                      child: Row(
                        children: [
                          Text(
                            'Scan QR Code',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0,
                                fontFamily: 'RobotoMono'),
                          ),
                        ],
                      ),
                      replacement: Row(
                        children: [
                          Text(
                            'You have already configured up to 4 devices',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'RobotoMono'),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: snapshot.data!.docs.length < 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ))),
                              child: Text(
                                'Scan End Device',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              onPressed: () {
                                scanQR();
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              _endDevice!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      replacement: Column(
                        children: [
                          SizedBox(
                            height: 30.0,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                            child: Text(
                              'Continue',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            onPressed: () {
                              completedSetup(true);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: new ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Text(snapshot.data!.docs[index]['name']);
                          }),
                    )
                  ]),
                )),
              ));
        });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await barcode.FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, barcode.ScanMode.QR);
      String newSender = "Sender" + (_devices.length + 1).toString();

      locationDB
          .doc(_firebaseAuth.currentUser!.uid)
          .collection('gateway')
          .doc(newSender)
          .set({
        'Location': {'Latitude': '', 'Longitude': ''},
        'color': AuxFunc().colorNamefromColor(_availableColors[0]),
        'name': newSender
      }, SetOptions(merge: true)).then((value) {
        setState(() {
          _devices.add(Device(
            id: barcodeScanRes,
            name: newSender,
            batteryLevel: null,
            latitude: null,
            longitude: null,
            color: AuxFunc().colorNamefromColor(_availableColors[0]),
            senderNumber: "Sender" + (_devices.length + 1).toString(),
          ));
          _availableColors.removeAt(0);
        });
      }).catchError((error) => print("Failed to add user: $error"));
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _endDevice = barcodeScanRes;
    });
  }
}
