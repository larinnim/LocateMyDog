import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
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
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../loading.dart';
import './functions_aux.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GatewayDetails extends StatefulWidget {
  String? title;
  String? gatewayMAC;
  GatewayDetails({Key? key, required this.title, required this.gatewayMAC})
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
  List<Device> _devicesDisabled = [];
  late BluetoothState state;
  late StreamSubscription<List<ScanResult>>
      scanSubScription; // * StreamSubscription
  // final _onBLELocation = StreamController<List<int>>.broadcast();
  // Stream<List<int>> get onBLELocation => _onBLELocation.stream;

  // late Stream<List<int>> listStream;
  // Stream<List<int>> get onBLELocation => listStream.asBroadcastStream();

  List<Color> _availableColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red
  ];

  final Connectivity _connectivity = Connectivity();
  // late Stream<BluetoothDeviceState> deviceConnectionState = [];
  BluetoothDevice? bleDevice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _getDevices();
    });
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
      flutterBlue
          .startScan(
              // withServices: [Guid(serviceUUID)],
              timeout: new Duration(seconds: 6))
          .then((value) {
        new Future.delayed(const Duration(seconds: 5), () {
          // deleayed code here
          // setState(() {
          // _isScanning = false;
          // });
        });
      });
      // Listen to scan results
      scanSubScription = flutterBlue.scanResults.listen((results) {
        if (results.length > 0) {
          print("found device");
          // do something with scan results
          for (ScanResult r in results) {
            if (r.device.name == 'IAT') {
              //Check if the device has already been discovered Check by mac address
              // var findDevice = context.read<BleModel>().deviceList.any((element) {
              //   if (element.device.id == r.device.id) {
              //     element.device = r.device;
              //     element.advertisementData = r.advertisementData;
              //     element.rssi = r.rssi;
              //     return true;
              //   } else {
              //     return false;
              //   }
              // });

              // //If it is the first device found, add it to the devicelist
              // if (!findDevice) {
              print("Scanned Name ${r.device.name}, RSSI ${r.rssi}");
              print("\tidentifier(mac) ${r.device.id}"); //mac address
              print("\tservice UUID : ${r.advertisementData.serviceUuids}");
              print(
                  "\tmanufacture Data : ${r.advertisementData.manufacturerData}");
              print("\tTx Power Level : ${r.advertisementData.txPowerLevel}");

              // deviceConnectionState = r.device.state;
              bleDevice = r.device;
              context.read<BleModel>().addDeviceList(BleDeviceItem(
                  r.rssi, r.advertisementData, r.device, r.device.state));
              // flutterBlue.stopScan();
              stopScanning();
              connectDev(r.device);
              // setState(() {
              // _isScanning = false;
              // });
              // }
              // setState(() {});
            }
          }
        }
      });
    } else {
      stopScanning();
    }
  }

  void stopScanning() {
    flutterBlue.stopScan();
    scanSubScription.cancel();
  }

  void connectDev(BluetoothDevice dev) async {
    //sleep(const Duration(seconds: 1));
    // List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    print("Size connected devices: " +
        context.read<BleModel>().connectedDevices.length.toString());
    if (!context.read<BleModel>().connectedDevices.contains(dev)) {
      print("connectDev - Line 243");
      await dev.connect().then((status) async {
        dev.state.listen((event) async {
          if (event == BluetoothDeviceState.connected) {
            await dev.requestMtu(512).then((value) async {
              await dev.mtu.first.then((mtu) async {
                print('MTU VALUE: ' + mtu.toString());
                //add connected device to the list
                context.read<BleModel>().addconnectedDevices(dev);

                context.read<BleModel>().services =
                    await dev.discoverServices();

                for (BluetoothService service in await dev.discoverServices()) {
                  if (service.uuid.toString() == serviceUUID) {
                    for (BluetoothCharacteristic c in service.characteristics) {
                      context.read<BleModel>().addcharacteristics(c);
                      if (c.uuid.toString() ==
                              'c67d4d7e-87c7-4e93-86e4-683cf2af76a0' &&
                          c.properties.notify) {
                        // List<int> value = await c.read();
                        // print(value);
                        for (BluetoothDescriptor descriptor in c.descriptors) {
                          print('The descriptor:' + descriptor.uuid.toString());
                        }
                        print(c.descriptors.toString());
                        // List<int> value = await c.read().then((value) {
                        //   print(value.toString());
                        //   // String receivedStr = ascii.decode(value);
                        //   // print("receivedStr: " + receivedStr);
                        //   return value;
                        // });

                        await c.setNotifyValue(true).then((value) {
                          print(value);
                          context
                              .read<BleModel>()
                              .characteristics
                              .elementAt(0)
                              .value
                              .listen((value) async {
                            // final split =
                            //     Utf8Decoder().convert(value).split(',');

                            // final Map<int, String> values = {
                            //   for (int i = 0; i < split.length; i++) i: split[i]
                            // };x
                            // print(values); //

                            // values.forEach((key, value) {
                            //   var parts = value.split(': ');
                            //   var prefix = parts[0].trim();
                            //   var prefix2 = prefix.split(': ');
                            //   print('Prefix: ' + prefix2[0].toString()); //
                            //   // print('sID' + map['sID']);
                            //   // print('lat' + map['lat']);
                            // });
                            if (value.isNotEmpty) {
                              Map<String, dynamic> map = jsonDecode(
                                  Utf8Decoder().convert(
                                      value)); // import 'dart:convert';
                              if (map['sID'] != null) {
                                print('SID: ' + map['sID'].toString());
                              }
                              if (map['lat'] != null) {
                                print('Lat: ' +
                                    map['lat'].toString()); //Come as double
                              }
                              if (map['lng'] != null) {
                                print('Longitude: ' +
                                    map['lng'].toString()); //Come as double
                              }
                              if (map['d'] != null) {
                                print('date: ' + map['d']);
                              }
                              if (map['t'] != null) {
                                print('Time GMT: ' + map['t']);
                              }
                              if (map['gID'] != null) {
                                print('Gateway Mac: ' + map['gID']);
                              }
                              if (map['tBL'] != null) {
                                print('Tracker Battery Level: ' +
                                    map['tBL'].toString()); //Come as double
                              }
                              if (map['gBL'] != null) {
                                print('Gateway Battery Level: ' +
                                    map['gBL'].toString()); //Come as double
                              }
                              final prefs =
                                  await SharedPreferences.getInstance();

                              final colorString = prefs.getString(
                                      'color-' + 'SD-' + map['sID']) ??
                                  "";

                              context.read<IATDataModel>().addIatData(
                                  new IATData(
                                      senderMAC: map['sID'],
                                      latitude: map['lat'],
                                      longitude: map['lng'],
                                      locationTimestamp: DateFormat("dd/MM/yyyy HH:mm:ss").parse(map['d'] + " " + map['t'])
                                          .millisecondsSinceEpoch,
                                      // date: DateTime.parse('1974-03-20 00:00:00.000'),
                                      // date: map['d'],
                                      // time: map['t'],
                                      gatewayMAC: map['gID'],
                                      trackerBatteryLevel: map['tBL'],
                                      gatewayBatteryLevel: map['gBL'],
                                      senderColor: colorString)); //
                            }
                          });
                        }).catchError((e) {
                          print("Error setting the SET Notify $e");
                        });

                        // await c.setNotifyValue(!c.isNotifying);

                        // c.setNotifyValue(!c.isNotifying);

                        // context
                        //     .read<BleModel>()
                        //     .characteristics
                        //     .elementAt(0)
                        //     .value
                        //     .listen((value) {
                        //   final split = Utf8Decoder().convert(value).split(',');
                        //   final Map<int, String> values = {
                        //     for (int i = 0; i < split.length; i++) i: split[i]
                        //   };
                        //   print(values); //

                        //   print(value);
                        // });
                      }
                      print("Connected");
                    }
                  }
                }
              });
            }).catchError((e) {
              print("Error changing MTU $e");
            });
          }
        });
      }).catchError((e) {
        print("Connection Error $e");
      });
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
          'color': AuxFunc().colorNamefromColor(_availableColors[0]),
          'enabled': true,
          'name': barcodeScanRes,
          'gatewayID': widget.gatewayMAC,
          'escaped': false,
          'version': '1.0', // Needs to change this later
        }, SetOptions(merge: true)).then((value) async {
          await DatabaseService(uid: _firebaseAuth.currentUser!.uid)
              .addSenderToGateway(barcodeScanRes, widget.gatewayMAC!)
              .then((value) async {
            final prefs = await SharedPreferences.getInstance();
            // Add color on cache to be used on ble
            prefs.setString('color-' + 'SD-' + barcodeScanRes.toString(),
                AuxFunc().colorNamefromColor(_availableColors[0]));
            setState(() {
              _devices.add(Device(
                  id: 'SD-' + barcodeScanRes,
                  name: 'SD-' + barcodeScanRes,
                  mac: barcodeScanRes,
                  batteryLevel: 0,
                  latitude: null,
                  longitude: null,
                  color: AuxFunc().colorNamefromColor(_availableColors[0]),
                  enabled: true));
              // _devices.add(Device(
              //   id: 'SD-' + barcodeScanRes,
              //   name: 'SD-' + barcodeScanRes,
              //   batteryLevel: 0,
              //   latitude: null,
              //   longitude: null,
              //   color: AuxFunc().colorNamefromColor(_availableColors[0]),
              // ));
              _availableColors.removeAt(0);
            });
          });
        }).catchError((error) {
          print("Failed to add user: $error");
        });
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
        .where('gatewayID', isEqualTo: widget.gatewayMAC)
        .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // if(_devices.length == 0){
        Color devColor = AuxFunc().getColor(doc['color']);
        _availableColors
            .removeWhere((colorAvailable) => devColor == colorAvailable);
        setState(() {
          _devices.add(Device(
              id: doc.id,
              name: doc['name'],
              mac: doc['senderMac'],
              batteryLevel: doc['batteryLevel'] ?? doc['batteryLevel'],
              latitude: (doc['Location']["Latitude"]).toString(),
              longitude: (doc['Location']["Longitude"]).toString(),
              color: doc['color'],
              enabled: doc['enabled']));
          if (doc['enabled'] == false) {
            _devicesDisabled.add(Device(
                id: doc.id,
                name: doc['name'],
                mac: doc['senderMac'],
                batteryLevel: doc['batteryLevel'],
                latitude: (doc['Location']["Latitude"]).toString(),
                longitude: (doc['Location']["Longitude"]).toString(),
                color: doc['color'],
                enabled: doc['enabled']));
          }
        });
      });
    });

    // });
    // return _devices;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleModel>(builder: (_, bleProvider, child) {
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
          // body: Text('Worked'),

          body: StreamBuilder<DocumentSnapshot>(
              stream:
                  gatewayCollection.doc("GW-" + widget.gatewayMAC!).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> docsnapshot) {
                if (docsnapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (docsnapshot.connectionState == ConnectionState.waiting) {
                  return Loading();
                }
                // if (docsnapshot.hasData) {
                //   return Text('Worked');
                // } else {
                //   return Loading();
                // }
                if (docsnapshot.hasData) {
                  return StreamBuilder<Object>(
                      stream: flutterBlue.isScanning,
                      builder: (context, isScanningSnap) {
                        if (isScanningSnap.hasError) {
                          return Text('Scanning went wrong');
                        }
                        if (isScanningSnap.connectionState ==
                            ConnectionState.waiting) {
                          return Loading();
                        }
                        return Center(
                          child: isScanningSnap.data == true
                              ? Container(
                                  color: Colors.red[300],
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              MaterialStateProperty.all(
                                                  Colors.black),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ))),
                                      child: Text(
                                        'Rename'.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
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
                                            leading:
                                                Icon(LineAwesomeIcons.wifi),
                                            title:
                                                Text('Wifi Connection Status'),
                                            trailing: Text(
                                              docsnapshot.data![
                                                          'connectionStatus'] ==
                                                      true
                                                  ? 'connected'.toUpperCase()
                                                  : 'disconnected'
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: docsnapshot.data![
                                                              'connectionStatus'] ==
                                                          true
                                                      ? Colors.lightGreen
                                                      : Colors.red[300],
                                                  fontWeight: FontWeight.w500),
                                              // ElevatedButton(
                                              //   style: ButtonStyle(
                                              //       backgroundColor:
                                              //           MaterialStateProperty.all(docsnapshot.data!['connectionStatus'] == true ?
                                              //               Colors.red : Colors.green),
                                              //       shape: MaterialStateProperty.all<
                                              //               RoundedRectangleBorder>(
                                              //           RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(18.0),
                                              //       ))),
                                              //   child: Text(
                                              //     docsnapshot.data!['connectionStatus'] == true ? 'disconnect'.toUpperCase() :
                                              //     'connect'.toUpperCase(),
                                              //     style: TextStyle(fontSize: 16),
                                              //   ),
                                              //   onPressed: () {

                                              //   },
                                            ),
                                          ),
                                          StreamBuilder<BluetoothDeviceState>(
                                              stream: bleProvider
                                                          .connectedDevices
                                                          .length >
                                                      0
                                                  ? bleProvider.connectedDevices
                                                      .first.state
                                                  : Stream.empty(),
                                              // stream: bleDevice?.state,
                                              initialData: BluetoothDeviceState
                                                  .disconnected,
                                              builder: (context, bleSnapshot) {
                                                return ListTile(
                                                    tileColor: Colors.white70,
                                                    leading: Icon(
                                                        LineAwesomeIcons
                                                            .bluetooth),
                                                    title: Text(
                                                        'Bluetooth Connection Status'),
                                                    trailing: ElevatedButton(
                                                      child: bleSnapshot.data ==
                                                              BluetoothDeviceState
                                                                  .connected
                                                          ? Text(
                                                              'Disconnect'
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ))
                                                          : bleSnapshot.data ==
                                                                  BluetoothDeviceState
                                                                      .disconnected
                                                              ? Text(
                                                                  'Connect'
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                )
                                                              : Text(
                                                                  bleSnapshot
                                                                      .data
                                                                      .toString()
                                                                      .substring(
                                                                          21)
                                                                      .toUpperCase()
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                      onPressed:
                                                          // () {
                                                          docsnapshot.data![
                                                                      'connectionStatus'] ==
                                                                  true
                                                              ? null
                                                              : () {
                                                                  //checks bluetooth current state
                                                                  FlutterBlue
                                                                      .instance
                                                                      .state
                                                                      .listen(
                                                                          (state) {
                                                                    if (state ==
                                                                        BluetoothState
                                                                            .off) {
                                                                      Get.dialog(
                                                                          SimpleDialog(
                                                                        title:
                                                                            Text(
                                                                          "Warning",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        titlePadding:
                                                                            EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              30,
                                                                          vertical:
                                                                              20,
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                new BorderRadius.circular(10.0)),
                                                                        children: [
                                                                          Text(
                                                                              "Please turn on your Bluetooth",
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontSize: 20.0)),
                                                                        ],
                                                                        contentPadding:
                                                                            EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              40,
                                                                          vertical:
                                                                              20,
                                                                        ),
                                                                      ));
                                                                      //Alert user to turn on bluetooth.
                                                                    } else if (state ==
                                                                        BluetoothState
                                                                            .on) {
                                                                      //if bluetooth is enabled then go ahead.
                                                                      //Make sure user's device gps is on.
                                                                      bleSnapshot.data ==
                                                                              BluetoothDeviceState
                                                                                  .connected
                                                                          ?
                                                                          // stopScanning();
                                                                          bleProvider
                                                                              .connectedDevices
                                                                              .first
                                                                              .disconnect()
                                                                              // bleDevice
                                                                              //     ?.disconnect()
                                                                              .then((value) {
                                                                              print('Disconnected clicked');

                                                                              context.read<BleModel>().removeConnectedDevice(bleProvider.connectedDevices.first);
                                                                            })
                                                                          : scan();
                                                                    }
                                                                  });
                                                                },
                                                      style: ButtonStyle(
                                                          backgroundColor: docsnapshot
                                                                          .data![
                                                                      'connectionStatus'] ==
                                                                  true
                                                              ? MaterialStateProperty.all(
                                                                  Colors.grey[
                                                                      400])
                                                              : bleSnapshot.data ==
                                                                      BluetoothDeviceState
                                                                          .connected
                                                                  ? MaterialStateProperty.all(
                                                                      Colors.red[
                                                                          300])
                                                                  : MaterialStateProperty.all(Colors
                                                                      .lightGreen),
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                          ))),

                                                      // style: ButtonStyle(
                                                      //     backgroundColor: bleProvider
                                                      //                     .deviceList
                                                      //                     .length ==
                                                      //                 0 &&
                                                      //             !_isScanning
                                                      //         ? MaterialStateProperty.all(
                                                      //             Colors.red[300])
                                                      //         : bleProvider.deviceList.length >
                                                      //                     0 &&
                                                      //                 bleProvider
                                                      //                         .connectedDevices
                                                      //                         .length ==
                                                      //                     0
                                                      //             ? MaterialStateProperty.all(
                                                      //                 Colors.green[300])
                                                      //             : MaterialStateProperty.all(
                                                      //                 Colors.red),
                                                      // shape: MaterialStateProperty.all<
                                                      //         RoundedRectangleBorder>(
                                                      //     RoundedRectangleBorder(
                                                      //   borderRadius:
                                                      //       BorderRadius.circular(18.0),
                                                      //     ))),
                                                      // child: Text(
                                                      //   bleProvider.deviceList.length == 0 &&
                                                      //           !_isScanning
                                                      //       ? 'scan'.tr.toUpperCase()
                                                      //       : bleProvider.deviceList.length >
                                                      //                   0 &&
                                                      //               bleProvider
                                                      //                       .connectedDevices
                                                      //                       .length ==
                                                      //                   0
                                                      //           ? 'connect'.tr.toUpperCase()
                                                      //           : 'disconnect'
                                                      //               .tr
                                                      //               .toUpperCase(),
                                                      //   style: TextStyle(fontSize: 16),
                                                      // ),
                                                      // onPressed: () {
                                                      //   bleProvider.deviceList.length == 0 &&
                                                      //           !_isScanning
                                                      //       ? scan()
                                                      //       : bleProvider.deviceList.length >
                                                      //                   0 &&
                                                      //               bleProvider
                                                      //                       .connectedDevices
                                                      //                       .length ==
                                                      //                   0
                                                      //           ? connectDev(bleProvider
                                                      //               .deviceList[0]
                                                      //               .device) //Connects to only one gateway
                                                      //           // ignore: unnecessary_statements
                                                      //           : bleProvider
                                                      //               .deviceList[0].device
                                                      //               .disconnect()
                                                      // .then((status) async => {
                                                      //       context
                                                      //           .read<
                                                      //               BleModel>()
                                                      //           .removeConnectedDevice(
                                                      //               bleProvider
                                                      //                   .deviceList[
                                                      //                       0]
                                                      //                   .device),
                                                      //     });
                                                      // },
                                                    ));
                                              }),
                                          ListTile(
                                            tileColor: Colors.white70,
                                            leading: docsnapshot
                                                        .data!['batteryLevel'] <
                                                    20
                                                ? Icon(LineAwesomeIcons
                                                    .battery_1_4_full)
                                                : 20 < docsnapshot.data!['batteryLevel'] &&
                                                        docsnapshot.data![
                                                                'batteryLevel'] <=
                                                            50
                                                    ? Icon(LineAwesomeIcons
                                                        .battery_1_2_full)
                                                    : 50 < docsnapshot.data!['batteryLevel'] &&
                                                            docsnapshot.data![
                                                                    'batteryLevel'] <
                                                                80
                                                        ? Icon(LineAwesomeIcons
                                                            .battery_3_4_full)
                                                        : docsnapshot.data!['batteryLevel'] >
                                                                80
                                                            ? Icon(
                                                                LineAwesomeIcons
                                                                    .battery_full)
                                                            : Icon(LineAwesomeIcons
                                                                .battery_empty),
                                            title: Text('Baterry Level'),
                                            trailing: Text(docsnapshot
                                                    .data!['batteryLevel']
                                                    .toString() +
                                                '%'),
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
                                            trailing: Text(
                                                docsnapshot.data!['version']),
                                          ),
                                          ListTile(
                                            tileColor: Colors.white70,
                                            title: Text('Serial Number'),
                                            trailing: Text(docsnapshot
                                                .data!['gatewayMAC']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      });
                } else {
                  return Loading();
                }
              }),
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
                // StreamBuilder<QuerySnapshot>(
                //     stream: _getDataStreamSnapshots(),
                //     builder: (BuildContext context,
                //         AsyncSnapshot<QuerySnapshot> querysnapshot) {
                //       if (querysnapshot.hasError) {
                //         return Text('Something went wrong');
                //       }

                //       if (querysnapshot.connectionState ==
                //           ConnectionState.waiting) {
                //         return Loading();
                //       }
                //       return
                ListView.builder(
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
                            title: _devices[index].enabled == true
                                ? Text(_devices[index].name!.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300))
                                : Text(
                                    _devices[index].name!.toUpperCase() +
                                        ' - (disabled)',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w100),
                                  ),
                            leading: Padding(
                              // change left :
                              padding: const EdgeInsets.only(left: 60),
                              child: Icon(
                                LineAwesomeIcons.mobile_phone,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context,
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
                              if (_devices.length - _devicesDisabled.length <
                                  4) {
                                scanQR(); //Maximum 4 devices
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            'You have reach the maximum number of trackers that can be paired. Please choose one tracker that you would like to replace.'),
                                        content: setupAlertDialoadContainer(),
                                      );
                                    });
                                // Get.dialog(SimpleDialog(
                                //   title: Text(
                                //     "Whoops",
                                //     textAlign: TextAlign.center,
                                //     style:
                                //         TextStyle(fontWeight: FontWeight.bold),
                                //   ),
                                //   titlePadding: EdgeInsets.symmetric(
                                //     horizontal: 30,
                                //     vertical: 20,
                                //   ),
                                //   shape: RoundedRectangleBorder(
                                //       borderRadius:
                                //           new BorderRadius.circular(10.0)),
                                //   children: [
                                //     Text("You have reach the maximum number of trackers that can be paired. Please choose one tracker that you would like to replace.",
                                //         textAlign: TextAlign.center,
                                //         style: TextStyle(fontSize: 20.0)),
                                //   ],
                                //   contentPadding: EdgeInsets.symmetric(
                                //     horizontal: 40,
                                //     vertical: 20,
                                //   ),
                                // ));
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

  Widget setupAlertDialoadContainer() {
    var _tempEnabledDevices = _devices;
    _tempEnabledDevices.removeWhere((element) => element.enabled == false);
    print(_tempEnabledDevices);
    // tempEnabledDevices.removeWhere((element) => false)
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _tempEnabledDevices.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: Icon(LineAwesomeIcons.mobile_phone),
              // leading: CircleAvatar(
              //     backgroundImage: NetworkImage(movie.imageUrl),
              //   ),
              title: Text(_tempEnabledDevices[index].name!.toUpperCase(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
              onTap: () {
                senderCollection
                    .doc('SD-' + _tempEnabledDevices[index].mac!)
                    .set({
                  'enabled':
                      _tempEnabledDevices[index].enabled == true ? false : true
                }, SetOptions(merge: true)).then((value) {
                  setState(() {
                    _devices[index].enabled =
                        _devices[index].enabled == true ? false : true;
                    if (_devices[index].enabled == false) {
                      _devicesDisabled.add(_devices[index]);
                    } else {
                      _devicesDisabled.removeWhere(
                          (element) => element.id == _devices[index].id);
                    }
                    _availableColors
                        .add(AuxFunc().getColor(_devices[index].color));
                  });
                  Navigator.pop(context);
                }).catchError((error) {
                  print("Failed to add user: $error");
                });
              });
        },
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    gatewayCollection
        .doc("GW-" + widget.gatewayMAC!)
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
