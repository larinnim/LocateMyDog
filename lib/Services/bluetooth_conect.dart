import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:convert/convert.dart';
import 'dart:convert';

class BluetoothConnection extends StatefulWidget {
  @override
  _BluetoothConnectionState createState() => _BluetoothConnectionState();
}

class _BluetoothConnectionState extends State<BluetoothConnection> {
  // BleManager _bleManager = BleManager();
  FlutterBlue flutterBlue = FlutterBlue.instance;

  // BluetoothState currentState = await _bleManager.bluetoothState();
  bool _isScanning = false;
  List<BleDeviceItem> deviceList = [];
  List<BluetoothService> services = [];
  List<BluetoothCharacteristic> characteristics = [];
  bool isConnected = false;
  List<BluetoothDevice> connectedDevices;
  List<int> lat;
  List<int> lng;
  // String lat = "";
  // String lng = "";
  String serviceUUID = "d1acf0d0-0a9b-11eb-adc1-0242ac120002";

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
      }
    });
    // setState(() {_isScanning = false;});
    // scan();
  }

  void connect(BluetoothDevice dev) async {
    await dev.connect(autoConnect: true).then((status) async {
      connectedDevices = await flutterBlue.connectedDevices;
      if (connectedDevices.contains(dev)) {
        setState(() {
          isConnected = true;
          print("Connected");
        });
        services = await dev.discoverServices();
        //Only works if I have 1 service. Review the logic if there is more than 1
        services.forEach((service) {
          characteristics = service.characteristics;
        });
        lat = await characteristics[0].read();
        lng = await characteristics[1].read();
      }
    }).catchError((e) => print("Permission check error $e"));
    print(lat);
    print(lng);
    
    // setupAlertDialoadContainer();
  }

  void setupAlertDialoadContainer() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Locate My Pet"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Navigate back to the first screen by popping the current route
                // off the stack.
                // Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  // _bleManager.destroyClient();
                  return BluetoothConnection();
                }));
              }
              // onPressed: () => Navigator.of(context).pop(),
              ),
        ),
        body: Center(
            child: Container(
                child: Material(
          child: ListView.builder(
            itemCount: deviceList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(services[index].uuid.toString()),
                subtitle: Text("Lat :" +
                    Utf8Decoder().convert(lat) +
                    " Long: " +
                    Utf8Decoder().convert(lng)),
                // trailing: Text(characteristicsLng[index].isReadable
                //     ? characteristicsLng[index].read()
                //     : ""),
              );
            },
          ),
        ))),
      );
    }));
  }

  //스캔 ON/OFF
  void scan() async {
    if (!_isScanning) {
      deviceList.clear();
      // _bleManager.startPeripheralScan().listen((scanResult) {
      flutterBlue.startScan(
          timeout: Duration(seconds: 4), withServices: [Guid(serviceUUID)]);

      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          // 여러가지 정보 확인
          print("Scanned Name ${r.device.name}, RSSI ${r.rssi}");
          print("\tidentifier(mac) ${r.device.id}"); //mac address
          print("\tservice UUID : ${r.advertisementData.serviceUuids}");
          print("\tmanufacture Data : ${r.advertisementData.manufacturerData}");
          print("\tTx Power Level : ${r.advertisementData.txPowerLevel}");
          deviceList.add(BleDeviceItem(r.rssi, r.advertisementData, r.device));
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
    return ListView.builder(
      itemCount: deviceList.length,
      itemBuilder: (context, index) {
        return ListTile(
          //디바이스 이름과 맥주소 그리고 신호 세기를 표시한다.
          title: Text(deviceList[index].device.name),
          // subtitle: Text("${deviceList[index].advertisementData}"),
          subtitle: lat != null && lng!= null ? Text("Lat :" +
                    Utf8Decoder().convert(lat) +
                    " Long: " +
                    Utf8Decoder().convert(lng)) : Text(" "),
          // ignore: unrelated_type_equality_checks
          trailing: FlatButton(
            color: isConnected ? Colors.red : Colors.green,
            shape: RoundedRectangleBorder(),
            onPressed: () {
              if (!isConnected) {
                connect(deviceList[index].device);
              } else {
                deviceList[index].device.disconnect().whenComplete(() async => {
                      connectedDevices = await flutterBlue.connectedDevices,
                      if (!connectedDevices.contains(deviceList[index].device))
                        {
                          setState(() {
                            isConnected = false;
                            print("Disconnected");
                          })
                        }
                    });
              }
              print('Received click');
            },
            child: Text(isConnected ? "Disconnect" : "Connect"),
          ),
          // trailing: Text("${deviceList[index].rssi}"),
          // onTap: () {
          //   connect(deviceList[index].peripheral);
          // },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Locate My Pet"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to the first screen by popping the current route
              // off the stack.
              // Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                // _bleManager.destroyClient();
                return ProfileScreen();
              }));
            }
            // onPressed: () => Navigator.of(context).pop(),
            ),
      ),
      body: Center(
        //디바이스 리스트 함수 호출
        child: list(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scan, //버튼이 눌리면 스캔 ON/OFF 동작
        child: Icon(_isScanning
            ? Icons.stop
            : Icons.bluetooth_searching), //_isScanning 변수에 따라 아이콘 표시 변경
      ),
    );
  }
}

class BleDeviceItem {
  int rssi;
  AdvertisementData advertisementData;
  BluetoothDevice device;
  BleDeviceItem(this.rssi, this.advertisementData, this.device);
}
