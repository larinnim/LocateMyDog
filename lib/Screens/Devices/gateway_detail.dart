import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Screens/Devices/device.dart';
import 'package:flutter_maps/Screens/Devices/device_detail.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';
import './functions_aux.dart';

// ignore: must_be_immutable
class GatewayDetails extends StatefulWidget {
  String title;
  GatewayDetails({Key key, @required this.title}) : super(key: key);

  @override
  _GatewayDetailsState createState() => _GatewayDetailsState();
}

class _GatewayDetailsState extends State<GatewayDetails> {
  CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _renameController = TextEditingController();
  String _scanBarcode = 'Unknown';
  List<String> _senders = [];
  List<Device> _devices = [];
  List<Color> _availableColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red
  ];

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  void updateName() async {
    await DatabaseService(uid: _firebaseAuth.currentUser.uid)
        .updateGatewayName(_renameController.text);
  }

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.BARCODE)
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      String newSender = "Sender" + (_devices.length + 1).toString();

      locationDB.doc(_firebaseAuth.currentUser.uid).set({
        newSender: {
          'ID': barcodeScanRes,
          'LastRequestedWifiSSID': '',
          'Location': {'Latitude': '', 'Longitude': ''},
          'LocationTimestamp': '',
          'RSSI': 0,
          'battery': 0,
          'color': AuxFunc().colorNamefromColor(_availableColors[0]),
          'name': newSender
        },
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

      // String newSender = "Sender" + _devices.length.toString();

      // locationDB.doc(_firebaseAuth.currentUser.uid).set({
      //   newSender: {
      //     'ID': barcodeScanRes,
      //     'LastRequestedWifiSSID': '',
      //     'Location': [
      //       {'Latitude': '', 'Longitude': ''}
      //     ],
      //     'LocationTimestamp': '',
      //     'RSSI': '',
      //     'battery': '',
      //     'color': _availableColors[0],
      //     'name': newSender
      //   },
      // }, SetOptions(merge: true)).then((value) {
      //   setState(() {
      //     _availableColors.removeAt(0);
      //     _devices.add(Device(
      //       id: barcodeScanRes,
      //       name: newSender,
      //       batteryLevel: null,
      //       latitude: null,
      //       longitude: null,
      //       color: null,
      //       senderNumber: (_devices.length + 1).toString(),
      //     ));
      //   });
      // }).catchError((error) => print("Failed to add user: $error"));

      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  void _getDevices() async {
    locationDB
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        documentSnapshot.data().forEach((key, value) {
          if (key.startsWith('Sender')) {
            Color devColor = AuxFunc().getColor(value['color']);
            _availableColors
                .removeWhere((colorAvailable) => devColor == colorAvailable);
            setState(() {
              _devices.add(Device(
                id: value['ID'],
                name: value['name'],
                batteryLevel: value['battery'],
                latitude: value['Location']["Latitude"],
                longitude: value['Location']["Longitude"],
                color: value['color'],
                senderNumber: key,
              ));
            });
          }
        });
        print('Document exists on the database');
      }
    });

    // _devices.map((deviceColor) {
    //   Color devColor = AuxFunc().getColor(deviceColor.color);
    //   _availableColors
    //       .removeWhere((colorAvailable) => devColor == colorAvailable);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              }),
        ),
        body: Center(
            child: Column(
          children: [
            SizedBox(
              height: 30.0,
            ),
            Icon(
              Icons.router_outlined,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ))),
              child: Text(
                'Rename'.toUpperCase(),
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed: () {
                _displayTextInputDialog(context);
              },
            ),
            SizedBox(
              height: 30.0,
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    tileColor: Colors.white70,
                    leading: Icon(LineAwesomeIcons.wifi),
                    title: Text('Wifi Connection Status'),
                    trailing: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                      child: Text(
                        'Connected'.toUpperCase(),
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  ListTile(
                      tileColor: Colors.white70,
                      leading: Icon(LineAwesomeIcons.bluetooth),
                      title: Text('Bluetooth Connection Status'),
                      trailing: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                        child: Text(
                          'Connected'.toUpperCase(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {},
                      )),
                  ListTile(
                    tileColor: Colors.white70,
                    leading: Icon(LineAwesomeIcons.battery_1_2_full),
                    title: Text('Baterry Level'),
                    trailing: Text('50%'),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  ListTile(
                    tileColor: Colors.white70,
                    title: Text('Manufacturer'),
                    trailing: Text('Majel Tecnologies'),
                  ),
                  ListTile(
                    tileColor: Colors.white70,
                    title: Text('Model'),
                    trailing: Text('1.0'),
                  ),
                  ListTile(
                    tileColor: Colors.white70,
                    title: Text('Serial Number'),
                    trailing: Text('ABCD12345'),
                  ),
                ],
              ),
            ),
          ],
        )),
        endDrawer: SafeArea(
            child: Drawer(
          child: Column(
            children: [
              Container(
                height: 80.0,
                width: 500,
                child: DrawerHeader(
                  child: Text('Devices'.toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  decoration: BoxDecoration(color: Colors.red[300]),
                ),
                // margin: EdgeInsets.all(0.0),
                // padding: EdgeInsets.all(0.0)
              ),
              // Container(
              //     // height: 80.0,
              //     child: DrawerHeader(
              //       child: Text('Devices'.toUpperCase(),
              //           style: TextStyle(color: Colors.white, fontSize: 20)),
              //       decoration: BoxDecoration(color: Colors.red[300]),
              //     ),
              //     margin: EdgeInsets.all(0.0),
              //     padding: EdgeInsets.all(0.0)),

              // ExpansionTile(
              // title: new Text(
              //   'Gateway ' + widget.title,
              //   style: new TextStyle(
              //       fontSize: 20.0,
              //   ),
              // ),
              // children: <Widget>[
              //   new ListView.builder(
              //       itemCount: _devices.length,
              //       // padding: EdgeInsets.zero,
              //       shrinkWrap: true,
              //       scrollDirection: Axis.vertical,
              //       itemBuilder: (context, index) {
              //         // children:
              //         // <Widget>[
              //         return new Column(
              //           children: _buildExpandableContent(_devices[index]),
              //         );
              //         // ];
              //       })
              // ]),
              ListTile(
                title: Text('Gateway: ' + widget.title.toUpperCase(),
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                leading: Icon(Icons.router_outlined),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              new ListView.builder(
                  itemCount: _devices.length,
                  // padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    // children:
                    // <Widget>[
                    return new Column(
                      children: <Widget>[
                        new ListTile(
                          title: Text(_devices[index].name.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w300)),
                          leading: Padding(
                            // change left :
                            padding: const EdgeInsets.only(left: 60),
                            child: Icon(
                              LineAwesomeIcons.mobile_phone,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return Material(
                                  child: DeviceDetail(
                                title: _devices[index].name,
                                color:
                                    AuxFunc().getColor(_devices[index].color),
                                battery: _devices[index].batteryLevel,
                                id: _devices[index].id,
                                senderNumber:
                                    _devices[index].senderNumber.toString(),
                                availableColors: _availableColors,
                              ));
                            }));
                          },
                        ),
                      ],
                    );
                    // ];
                  }),
              // ]),
              // Divider(
              //   thickness: 3,
              //   color: Colors.lightGreenAccent,
              // ),
              ListTile(
                tileColor: Colors.red[200],
                title: Text('Add a New Device'.toUpperCase(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.white)),
                leading: Icon(
                  LineAwesomeIcons.plus_circle,
                  color: Colors.white,
                ),
                onTap: () {
                  if (_devices.length < 4) {
                    scanQR(); //Maximum 4 devices
                  } else {
                    Get.dialog(SimpleDialog(
                      title: Text(
                        "Error",
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
                        Text("Maximum number of devices paired",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20.0)),
                      ],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ));
                  }
                },
              ),
            ],
          ),
        )));
  }

  // _buildExpandableContent(Device device) {
  //   List<Widget> columnContent = [];

  //   // for (String content in device.contents)
  //   columnContent.add(
  // new ListTile(
  //   title: Text(device.name.toUpperCase(),
  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
  //   leading: Icon(LineAwesomeIcons.mobile_phone),
  //   onTap: () {
  //     Navigator.pop(context);
  //   },
  // ),
  //   );
  //   return columnContent;
  // }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    locationDB
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((DocumentSnapshot querySnapshot) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rename Gateway'),
            content: TextField(
              controller: _renameController,
              decoration: InputDecoration(
                  hintText: querySnapshot.data()["gateway"]["name"]),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  print(_renameController.text);
                  updateName();
                  setState(() {
                    widget.title = _renameController.text;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
  }
}
