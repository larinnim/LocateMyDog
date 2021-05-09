import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Screens/Devices/device.dart';
import 'package:flutter_maps/Screens/Devices/device_detail.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';
import '../loading.dart';
import './functions_aux.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GatewayDetails extends StatefulWidget {
  String? title;
  String? gatewayID;
  GatewayDetails({Key? key, required this.title, required this.gatewayID})
      : super(key: key);

  @override
  _GatewayDetailsState createState() => _GatewayDetailsState();
}

class _GatewayDetailsState extends State<GatewayDetails> {
  CollectionReference senderCollection =
      FirebaseFirestore.instance.collection('sender');

  CollectionReference gatewayCollection =
      FirebaseFirestore.instance.collection('gateway');

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _renameController = TextEditingController();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isScanning = false;
  String serviceUUID = "d1acf0d0-0a9b-11eb-adc1-0242ac120002";
  List<Device> _devices = [];
  List<Color> _availableColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red
  ];
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  void updateName() async {
    await DatabaseService(uid: _firebaseAuth.currentUser!.uid)
        .updateGatewayName(_renameController.text);
  }

  startBarcodeScanStream() async {
    barcode.FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, barcode.ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  void scan() async {
    if (!_isScanning) {
      flutterBlue.startScan(
          withServices: [Guid(serviceUUID)],
          timeout: new Duration(seconds: 20)).then((value) {
        new Future.delayed(const Duration(seconds: 5), () {
          // deleayed code here
          setState(() {
            _isScanning = false;
          });
        });
      });
      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          //Check if the device has already been discovered Check by mac address
          var findDevice = context.read<BleModel>().deviceList.any((element) {
            if (element.device.id == r.device.id) {
              element.device = r.device;
              element.advertisementData = r.advertisementData;
              element.rssi = r.rssi;
              return true;
            } else {
              return false;
            }
          });

          //If it is the first device found, add it to the devicelist
          if (!findDevice) {
            print("Scanned Name ${r.device.name}, RSSI ${r.rssi}");
            print("\tidentifier(mac) ${r.device.id}"); //mac address
            print("\tservice UUID : ${r.advertisementData.serviceUuids}");
            print(
                "\tmanufacture Data : ${r.advertisementData.manufacturerData}");
            print("\tTx Power Level : ${r.advertisementData.txPowerLevel}");
            context.read<BleModel>().addDeviceList(
                BleDeviceItem(r.rssi, r.advertisementData, r.device));
            setState(() {
              _isScanning = false;
            });
          }
          // setState(() {});
        }
      });
      setState(() {
        _isScanning = true;
      });
    } else {
      flutterBlue.stopScan();
      setState(() {
        _isScanning = false;
      });
    }
  }

  void connectDev(BluetoothDevice dev) async {
    //sleep(const Duration(seconds: 1));
    // List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    print("Size connected devices: " +
        context.read<BleModel>().connectedDevices.length.toString());
    if (!context.read<BleModel>().connectedDevices.contains(dev)) {
      print("connectDev - Line 243");
      await dev.connect().then((status) async {
        //add connected device to the list
        context.read<BleModel>().addconnectedDevices(dev);

        context.read<BleModel>().services = await dev.discoverServices();
        for (BluetoothService service in await dev.discoverServices()) {
          if (service.uuid.toString() == serviceUUID) {
            for (BluetoothCharacteristic c in service.characteristics) {
              if (c.uuid.toString() == 'c67d4d7e-87c7-4e93-86e4-683cf2af76a0' &&
                  c.properties.read) {
                List<int> value = await c.read().then((value) {
                  print(value);
                  return value;
                });
                print(value);
              }
              context.read<BleModel>().addcharacteristics(c);
            }
          }
        }
        print("Connected");
        setState(() {});
      }).catchError((e) => print("Connection Error $e"));
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await barcode.FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, barcode.ScanMode.QR);
      // String newSender = "Sender" + (_devices.length + 1).toString();
      if (barcodeScanRes != '-1') { 
      senderCollection.doc('SD-' + barcodeScanRes).set({
        'senderMac': barcodeScanRes,
        'userID': _firebaseAuth.currentUser!.uid,
        'Location': {'Latitude': '', 'Longitude': ''},
        'LocationTimestamp': '',
        'batteryLevel': 0,
        'escaped': false,
        'enabled': true,
        'color': AuxFunc().colorNamefromColor(_availableColors[0]),
        'name': barcodeScanRes
      }, SetOptions(merge: true)).then((value) {
        setState(() {
          _devices.add(Device(
            id: 'SD-' + barcodeScanRes,
            name: 'SD-' + barcodeScanRes,
            batteryLevel: 0,
            latitude: null,
            longitude: null,
            color: AuxFunc().colorNamefromColor(_availableColors[0]),
          ));
          _availableColors.removeAt(0);
        });
      }).catchError((error) => print("Failed to add user: $error"));
      print(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _getDevices() async {
    senderCollection
        .where('gatewayID', isEqualTo: widget.gatewayID)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Color devColor = AuxFunc().getColor(doc['color']);
        _availableColors
            .removeWhere((colorAvailable) => devColor == colorAvailable);
        setState(() {
          _devices.add(Device(
            id: doc.id,
            name: doc['name'],
            batteryLevel: doc['batteryLevel'],
            latitude: doc['Location']["Latitude"],
            longitude: doc['Location']["Longitude"],
            color: doc['color'],
          ));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BleModel, WiFiModel>(
        builder: (_, bleProvider, wifiProvider, child) {
      return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text(widget.title!),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                }),
          ),
          body: Center(
            child: _isScanning
                ? Container(
                    color: Colors.red[300],
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFoldingCube(
                            color: Colors.white,
                            size: 50.0,
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            'Scanning...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28.0),
                          )
                        ]),
                  )
                : Column(
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
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
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
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                child: Text(
                                  'connect'.toUpperCase(),
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
                                      backgroundColor: bleProvider
                                                      .deviceList.length ==
                                                  0 &&
                                              !_isScanning
                                          ? MaterialStateProperty.all(
                                              Colors.red[300])
                                          : bleProvider.deviceList.length > 0 &&
                                                  bleProvider.connectedDevices
                                                          .length ==
                                                      0
                                              ? MaterialStateProperty.all(
                                                  Colors.green[300])
                                              : MaterialStateProperty.all(
                                                  Colors.red),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ))),
                                  child: Text(
                                    bleProvider.deviceList.length == 0 &&
                                            !_isScanning
                                        ? 'scan'.tr.toUpperCase()
                                        : bleProvider.deviceList.length > 0 &&
                                                bleProvider.connectedDevices
                                                        .length ==
                                                    0
                                            ? 'connect'.tr.toUpperCase()
                                            : 'disconnect'.tr.toUpperCase(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  onPressed: () {
                                    bleProvider.deviceList.length == 0 &&
                                            !_isScanning
                                        ? scan()
                                        : bleProvider.deviceList.length > 0 &&
                                                bleProvider.connectedDevices
                                                        .length ==
                                                    0
                                            ? connectDev(bleProvider
                                                .deviceList[0]
                                                .device) //Connects to only one gateway
                                            // ignore: unnecessary_statements
                                            : bleProvider.deviceList[0].device
                                                .disconnect()
                                                .then((status) async => {
                                                      context
                                                          .read<BleModel>()
                                                          .removeConnectedDevice(
                                                              bleProvider
                                                                  .deviceList[0]
                                                                  .device),
                                                    });
                                  },
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
                  ),
          ),
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
                ),
                ListTile(
                  title: Text('Gateway: ' + widget.title!.toUpperCase(),
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
                            title: Text(_devices[index].name!.toUpperCase(),
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
                                  senderID: _devices[index].id,
                                  availableColors: _availableColors,
                                ));
                              }));
                            },
                          ),
                        ],
                      );
                    }),
                FutureBuilder(
                    initialData: false,
                    future: mounted
                        ? _connectivity.checkConnectivity()
                        : Future.value(null),
                    builder: (context, connectivitySnap) {
                      if (connectivitySnap.hasData) {
                        return ListTile(
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
                            if (connectivitySnap.data ==
                                ConnectivityResult.none) {
                              showCupertinoDialog(
                                  context: context,
                                  builder: (_) => CupertinoAlertDialog(
                                        title: Text("Error"),
                                        content: Text(
                                            "You are offline. Please connect to an active internet connection."),
                                        actions: [
                                          // Close the dialog
                                          // You can use the CupertinoDialogAction widget instead
                                          CupertinoButton(
                                              child: Text('Dismiss'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }),
                                          // CupertinoButton(
                                          //   child: Text('I agree'),
                                          //   onPressed: () {
                                          //     // Do something
                                          //     print('I agreed');
                                          //   },
                                          // )
                                        ],
                                      ));
                            } else {
                              if (_devices.length < 4) {
                                scanQR(); //Maximum 4 devices
                              } else {
                                Get.dialog(SimpleDialog(
                                  title: Text(
                                    "Error",
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  titlePadding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
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
                            }
                          },
                        );
                      } else {
                        return Loading();
                      }
                    }),
              ],
            ),
          )));
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    gatewayCollection
        .doc(widget.gatewayID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rename Gateway'),
            content: TextField(
              controller: _renameController,
              decoration:
                  InputDecoration(hintText: documentSnapshot.data()!["name"]),
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
