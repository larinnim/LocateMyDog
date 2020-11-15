import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Screens/Tutorial/step2.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/setWiFiConf.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../Services/custom_expansion_tile.dart' as custom;

class Step1 extends StatefulWidget {
  @override
  _Step1State createState() => new _Step1State();
}

class _Step1State extends State<Step1> {
  bool _isScanning = false;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  String serviceUUID = "d1acf0d0-0a9b-11eb-adc1-0242ac120002";
  bool _isShowingDialog = false;
  @override
  initState() {
    super.initState();
    //checks bluetooth current state
    // FlutterBlue.instance.state.listen((state) {
    // if (state == BluetoothState.off) {
    //   showDialog(
    //       context: context,
    //       child: new AlertDialog(
    //         title: new Text("Bluetooth Disconnected"),
    //         content: new Text("Please Turn on your Bluetooth"),
    //       ));
    // //Alert user to turn on bluetooth.
    // } else if (state == BluetoothState.on) {
    // //if bluetooth is enabled then go ahead.
    // //Make sure user's device gps is on.
    // // scanForDevices();
    // }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        // type: MaterialType.transparency,
        child: new Container(
          // decoration: BoxDecoration(color: Colors.white),
          child: SafeArea(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
            child: Column(children: <Widget>[
              Row(
                children: [
                  Text(
                    'Step 1 of 4',
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
                    'Scan Gateway',
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
                  SizedBox(height: 20.0),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.lightBlue,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(
                          _isScanning ? Icons.stop : Icons.bluetooth_searching),
                      onPressed: scan,
                      color: Colors.white, //
                    ),
                  ),
                  list(),
                ],
              ),
            ]),
          )),
        ));
  }

  void checkBluetooth() {
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        showDialog(
            context: context,
            child: new AlertDialog(
              title: new Text("Bluetooth Disconnected"),
              content: new Text("Please Turn on your Bluetooth"),
            ));
        _isShowingDialog = true;
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        if (_isShowingDialog) {
          Navigator.pop(context);
        }
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        // scanForDevices();
      }
    });
  }

  void connectDev(BluetoothDevice dev) async {
    //sleep(const Duration(seconds: 1));
    // List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;

    if (!BleSingleton.shared.connectedDevices.contains(dev)) {
      print("connectDev - Line 243");
      await dev.connect().then((status) async {
        //add connected device to the list
        context.read<BleModel>().addconnectedDevices(dev);

        context.read<BleModel>().services = await dev.discoverServices();
        //Only works if I have 1 service. Review the logic if there is more than 1
        context.read<BleModel>().services.forEach((service) {
          context.read<BleModel>().characteristics = service.characteristics;
        });
        await context
            .read<BleModel>()
            .characteristics
            .elementAt(0)
            .setNotifyValue(true); //ESP32 - Latitude
        await context
            .read<BleModel>()
            .characteristics
            .elementAt(1)
            .setNotifyValue(true); //ESP32 - Longitude

        context
            .read<BleModel>()
            .characteristics
            .elementAt(0)
            .value
            .listen((value) {
          context.read<BleModel>().addLat(double.parse(
              Utf8Decoder().convert(value))); // Add lat to provider
        });
        context
            .read<BleModel>()
            .characteristics
            .elementAt(1)
            .value
            .listen((value) {
          context.read<BleModel>().addLng(double.parse(
              Utf8Decoder().convert(value))); // Add lng to provider
        });

        print("Connected");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Step2(),
        ));
        // setState(() {});
      }).catchError((e) async {
        print("Connection Error $e");
        List<BluetoothDevice> connectedDevices =
            await flutterBlue.connectedDevices;

        if (connectedDevices.contains(dev)) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Step2(),
          ));
        }
      });
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Step2(),
      ));
    }
  }

  //스캔 ON/OFF
  void scan() async {
    checkBluetooth();
    print("scan - Line 340");
    if (!_isScanning) {
      // flutterBlue.startScan(
      //     withServices: [Guid(serviceUUID)]);
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
              //이미 존재하면 기존 값을 갱신.
              element.device = r.device;
              element.advertisementData = r.advertisementData;
              element.rssi = r.rssi;
              return true;
            }
            return false;
          });

          //If it is the first device found, add it to the devicelist
          if (!findDevice) {
            // 여러가지 정보 확인
            print("Scanned Name ${r.device.name}, RSSI ${r.rssi}");
            print("\tidentifier(mac) ${r.device.id}"); //mac address
            print("\tservice UUID : ${r.advertisementData.serviceUuids}");
            print(
                "\tmanufacture Data : ${r.advertisementData.manufacturerData}");
            print("\tTx Power Level : ${r.advertisementData.txPowerLevel}");
            context.read<BleModel>().addDeviceList(
                BleDeviceItem(r.rssi, r.advertisementData, r.device));
          }
          setState(() {});
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

  list() {
    return Consumer<BleModel>(builder: (_, bleProvider, child) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: bleProvider.items.length,
          itemBuilder: (context, index) {
            return Column(children: <Widget>[
              SizedBox(height: 20.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      // borderRadius: BorderRadius.circular(50.0),
                      ),
                  child: ListTile(
                    tileColor: Colors.lightBlue,
                    title: Text(
                      // "Device: ",
                      "Device: " + bleProvider.deviceList[index].device.name,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    subtitle: Text(
                      "Tap to Connect",
                    ),
                    onTap: () {
                      connectDev(bleProvider.deviceList[index].device);
                    },
                  ),
                ),
              )
            ]);
          });
    });
  }
}
