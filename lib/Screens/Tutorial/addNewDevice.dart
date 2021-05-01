import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:flutter_maps/Screens/Tutorial/step3.dart';
import 'package:flutter_maps/Services/permissionChangeBuilder.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AddNewDevice extends StatelessWidget {
  AddNewDevice(this.colorString, this.gatewayID);

  late final CollectionReference senderCollection =
      FirebaseFirestore.instance.collection('sender');

  late final CollectionReference gatewayCollection =
      FirebaseFirestore.instance.collection('gateway');

  late final String senderID;
  late final String colorString;
  late final String gatewayID;

  // final CollectionReference locationDB =
  //     FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> scanQR() async {
    String barcodeScanRes;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await barcode.FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, barcode.ScanMode.QR);

      final checkIfAlredySetup =
          await senderCollection.doc('GW-' + barcodeScanRes).get();

      if (checkIfAlredySetup.exists) {
        Get.dialog(AlertDialog(
          title: Text('Whoops'),
          content: Text('You have already setup this sender.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.offAll(Step3(gatewayID));
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(primary: Colors.lightGreen),
            )
          ],
        ));
        //   SimpleDialog(
        //   title: Text(
        //     "Whoops",
        //     textAlign: TextAlign.center,
        //     style: TextStyle(fontWeight: FontWeight.bold),
        //   ),
        //   titlePadding: EdgeInsets.symmetric(
        //     horizontal: 30,
        //     vertical: 20,
        //   ),
        //   shape: RoundedRectangleBorder(
        //       borderRadius: new BorderRadius.circular(10.0)),
        //   children: [
        //     Text('You have already setup this sender',
        //         textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
        //     SimpleDialogOption(
        //       onPressed: () {
        //         Get.offAll(Step3(gatewayID));
        //       },
        //       child: const Text('OK'),
        //     ),
        //   ],
        //   contentPadding: EdgeInsets.symmetric(
        //     horizontal: 40,
        //     vertical: 20,
        //   ),
        // ));
      } else {
        senderCollection.doc('GW-' + barcodeScanRes).set({
          'senderMac': barcodeScanRes,
          'userID': _firebaseAuth.currentUser!.uid,
          'Location': {'Latitude': '', 'Longitude': ''},
          'LocationTimestamp': '',
          'batteryLevel': 0,
          'color': colorString,
          'name': barcodeScanRes,
          'gatewayID': gatewayID,
        }, SetOptions(merge: true)).then((value) {
          Get.back();
        }).catchError((error) => print("Failed to add user: $error"));
        print(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    //   senderCollection
    //       .doc()
    //       .collection('gateway')
    //       .doc(newSender)
    //       .set({
    //     'Location': {'Latitude': '', 'Longitude': ''},
    //     'color': colorString,
    //     'name': newSender,
    //     'batteryLevel' : 0,
    //     'id' : barcodeScanRes,
    //   }, SetOptions(merge: true)).then((value) {
    //     Get.back();
    //     // setState(() {
    //     //   _devices.add(Device(
    //     //     id: barcodeScanRes,
    //     //     name: newSender,
    //     //     batteryLevel: null,
    //     //     latitude: null,
    //     //     longitude: null,
    //     //     color: AuxFunc().colorNamefromColor(_availableColors[0]),
    //     //     senderNumber: "Sender" + (_devices.length + 1).toString(),
    //     //   ));
    //     //   _availableColors.removeAt(0);
    //     // });
    //   }).catchError((error) => print("Failed to add user: $error"));
    //   print(barcodeScanRes);
    // } on PlatformException {
    //   barcodeScanRes = 'Failed to get platform version.';
    // }

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
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  'Step 3 of 5',
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
                                      'Scan End Device',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
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
            }));
  }
}