import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:get/get.dart';

class AddNewDevice extends StatelessWidget {
  AddNewDevice(this.senderID, this.colorString);

  late final int senderID;
  late final String colorString;

  final CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> scanQR() async {
    String barcodeScanRes;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await barcode.FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, barcode.ScanMode.QR);
      String newSender = "Sender" + senderID.toString();

      locationDB
          .doc(_firebaseAuth.currentUser!.uid)
          .collection('gateway')
          .doc(newSender)
          .set({
        'Location': {'Latitude': '', 'Longitude': ''},
        'color': colorString,
        'name': newSender
      }, SetOptions(merge: true)).then((value) {
        Get.back();
        // setState(() {
        //   _devices.add(Device(
        //     id: barcodeScanRes,
        //     name: newSender,
        //     batteryLevel: null,
        //     latitude: null,
        //     longitude: null,
        //     color: AuxFunc().colorNamefromColor(_availableColors[0]),
        //     senderNumber: "Sender" + (_devices.length + 1).toString(),
        //   ));
        //   _availableColors.removeAt(0);
        // });
      }).catchError((error) => print("Failed to add user: $error"));
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _endDevice = barcodeScanRes;
    // });
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
            child: Column(
              children: <Widget>[
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
                  height: 30.0,
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
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ))),
                        child: Text(
                          'Scan End Device',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onPressed: () {
                          scanQR();
                        },
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //   child: Text(
                //     _endDevice!,
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
