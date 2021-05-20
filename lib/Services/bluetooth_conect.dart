import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as vec;

class LocationValues {
  /// Latitude in degrees
  final double? latitude;

  /// Longitude, in degrees
  final double? longitude;

  /// timestamp of the LocationData
  final double? time;

  /// Heading is the horizontal direction of travel of this device, in degrees
  double? heading = 90;

  LocationValues._(this.latitude, this.longitude, this.time, this.heading);

  factory LocationValues.fromMap(Map<String, double> dataMap) {
    return LocationValues._(
      dataMap['latitude'],
      dataMap['longitude'],
      dataMap['heading'],
      dataMap['time'],
    );
  }
  @override
  String toString() {
    return "LocationValues<lat: $latitude, long: $longitude>";
  }

  /// Returns the initial bearing between two points
  /// The initial bearing will most of the time be different than the end bearing, see [https://www.movable-type.co.uk/scripts/latlong.html#bearing]
  Future<double> bearingBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    var startLongtitudeRadians = vec.radians(startLongitude);
    var startLatitudeRadians = vec.radians(startLatitude);

    var endLongtitudeRadians = vec.radians(endLongitude);
    var endLattitudeRadians = vec.radians(endLatitude);

    var y = sin(endLongtitudeRadians - startLongtitudeRadians) *
        cos(endLattitudeRadians);
    var x = cos(startLatitudeRadians) * sin(endLattitudeRadians) -
        sin(startLatitudeRadians) *
            cos(endLattitudeRadians) *
            cos(endLongtitudeRadians - startLongtitudeRadians);

    return Future.value(vec.degrees(atan2(y, x)));
  }
}

class BleDeviceItem {
  int rssi;
  AdvertisementData advertisementData;
  BluetoothDevice device;
  BleDeviceItem(this.rssi, this.advertisementData, this.device);
}

class BleModel extends ChangeNotifier {
  List<BleDeviceItem> deviceList = [];
  List<BluetoothService> services = [];
  List<BluetoothCharacteristic> characteristics = [];
  List<BluetoothDevice> connectedDevices = [];
  double? lat;
  double? lng;
  DateTime? timestampBLE;
  String? senderNumber;

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<BleDeviceItem> get items =>
      UnmodifiableListView(deviceList);

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void addDeviceList(BleDeviceItem item) {
    print("addDeviceList - Line 138");
    // if (item != null) {
    deviceList.add(item);
    notifyListeners();
    // }
    // This call tells the widgets that are listening to this model to rebuild.
  }

  void removeConnectedDevice(BluetoothDevice device) {
    services.clear();
    characteristics.clear();
    connectedDevices.clear();
    lat = null;
    lng = null;
    senderNumber = null;
    notifyListeners();
  }

  void addService(BluetoothService service) {
    print("addDeviceList - Line 145");
    services.add(service);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addcharacteristics(BluetoothCharacteristic characteristic) {
    print("addcharacteristics - Line 152");
    characteristics.add(characteristic);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addconnectedDevices(BluetoothDevice device) {
    print("addconnectedDevices - Line 159");
    connectedDevices.add(device);
    // BleSingleton._singleton.connectedDevices.add(device);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addLatLng(double receivedLat, double receivedLng, String? sender) {
    //print("addLat - Line 166");
    lat = receivedLat;
    lng = receivedLng;
    senderNumber = sender;
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    print("removeAll - Line 189");
    deviceList.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}

class BluetoothConnection extends StatefulWidget {
  const BluetoothConnection({Key? key}) : super(key: key);

  @override
  _BluetoothConnectionState createState() => _BluetoothConnectionState();
}

class _BluetoothConnectionState extends State<BluetoothConnection> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isScanning = false;
  String serviceUUID = "d1acf0d0-0a9b-11eb-adc1-0242ac120002";

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
        //Only works if I have 1 service. Review the logic if there is more than 1
        context.read<BleModel>().services.forEach((service) {
          context.read<BleModel>().characteristics = service.characteristics;
        });
        await context
            .read<BleModel>()
            .characteristics
            .elementAt(0)
            .setNotifyValue(true); //ESP32 - Latitude

        context
            .read<BleModel>()
            .characteristics
            .elementAt(0)
            .value
            .listen((value) {
          final split = Utf8Decoder().convert(value).split(',');
          final Map<int, String> values = {
            for (int i = 0; i < split.length; i++) i: split[i]
          };
          print(values); // {0: grubs, 1:  sheep}

          final lat = values[0]!;
          final lng = values[1]!;
          final sender = values[2];

          context.read<BleModel>().addLatLng(double.parse(lat),
              double.parse(lng), sender); // Add lat to provider
        });
        print("Connected");
        setState(() {});
      }).catchError((e) {
        print("Connection Error $e");
      });
    }
  }

  //스캔 ON/OFF
  void scan() async {
    print("scan - Line 340");
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
    print("list - Line 391");
    return Consumer2<BleModel, WiFiModel>(
        builder: (_, bleProvider, wifiProvider, child) {
      return ListView.builder(
          itemCount: bleProvider.items.length,
          itemBuilder: (context, index) {
            return Column(children: <Widget>[
              SizedBox(height: 20.0),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: Offset(3, 4))
                  ],
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.router_outlined,
                    color: Colors.green,
                    size: 30.0,
                  ),
                  title: Text(
                    "Device: " + bleProvider.deviceList[index].device.name,
                    style: TextStyle(fontSize: 25),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    //TODO create list on the phone regarding the last saved color for the devices
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => GatewayDetails(
                    //             title: bleProvider
                    //                 .deviceList[index].device.name)));
                  },
                ),
              )
            ]);
          });
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer<BleModel>(builder: (context, dev, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Connection"),
        centerTitle: true,
        // backgroundColor: Colors.blueGrey,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            }),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: list(),
            ),
          ),
          Expanded(
              child:
                  // list(),
                  Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton.icon(
                label: Text(
                    _isScanning
                        ? 'Scanning'.toUpperCase()
                        : 'Scan'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
                icon:
                    Icon(_isScanning ? Icons.stop : Icons.bluetooth_searching),
                onPressed: () {
                  scan();
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red[300]),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)))),
              ),
            ),
          )),
          SizedBox(height: 30)
        ],
      )
          // child: list(),
          ),
    );
  }
}
