import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as vec;
import 'custom_expansion_tile.dart' as custom;
import 'dart:ui' as ui;

class LocationValues {
  /// Latitude in degrees
  final double latitude;

  /// Longitude, in degrees
  final double longitude;

  /// timestamp of the LocationData
  final double time;

  /// Heading is the horizontal direction of travel of this device, in degrees
  double heading = 90;

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

class BleSingleton {
  static final BleSingleton _singleton = BleSingleton._internal();
  factory BleSingleton() => _singleton;
  BleSingleton._internal();
  static BleSingleton get shared => _singleton;
  List<int> lat;
  List<int> lng;
  DateTime now;
  double heading = 90;
  // BlueLocation.private(this.lat, this.lng, this.now);

  Stream<LocationValues> _onLocationChanged;
  StreamController<dynamic> controller;

  /// Returns a stream of [LocationData] objects.
  /// The frequency and accuracy of this stream can be changed with [changeSettings]
  ///
  /// Throws an error if the app has no permission to access location.
  Stream<LocationValues> onLocationChanged() {
    _onLocationChanged = receiveBroadcastStream().map<LocationValues>(
        (element) => LocationValues.fromMap(element.cast<String, double>()));
    return _onLocationChanged;
  }

  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    controller = StreamController<dynamic>.broadcast(onListen: () async {
      // binaryMessenger.setMessageHandler(name, (ByteData reply) async {
      try {
        controller.add(lat);
        controller.add(lng);
        controller.add(now);
        controller.close();
      } on PlatformException catch (e) {
        controller.addError(e);
      }
    });
    return controller.stream;
  }
}

class BleModel extends ChangeNotifier {
  List<BleDeviceItem> deviceList = [];
  List<BluetoothService> services = [];
  List<BluetoothCharacteristic> characteristics = [];
  List<BluetoothDevice> connectedDevices = [];
  List<int> lat = [];
  List<int> lng = [];
  DateTime now = DateTime.now();

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<BleDeviceItem> get items =>
      UnmodifiableListView(deviceList);

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void addDeviceList(BleDeviceItem item) {
    print("addDeviceList - Line 138");
    deviceList.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void removeConnectedDevice(BluetoothDevice device) {
    services.clear();
    characteristics.clear();
    connectedDevices.clear();
    lat = null;
    lng = null;
    BleSingleton._singleton.lat = null;
    BleSingleton._singleton.lng = null;
    BleSingleton._singleton.now = null;
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
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addLat(List<int> value) {
    //print("addLat - Line 166");
    lat = value;
    BleSingleton._singleton.lat = value;
    BleSingleton._singleton.now = DateTime.now();
    now = BleSingleton._singleton.now;
    BleSingleton._singleton.onLocationChanged();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addLng(List<int> value) {
    //print("addLgn - Line 177");
    lng = value;
    BleSingleton._singleton.lng = value;
    BleSingleton._singleton.now = DateTime.now();
    now = BleSingleton._singleton.now;
    BleSingleton._singleton.onLocationChanged();
    // This call tells the widgets that are listening to this model to rebuild.
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
  const BluetoothConnection({Key key}) : super(key: key);

  @override
  _BluetoothConnectionState createState() => _BluetoothConnectionState();
}

class _BluetoothConnectionState extends State<BluetoothConnection> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isScanning = false;
  String serviceUUID = "d1acf0d0-0a9b-11eb-adc1-0242ac120002";

  @override
  void initState() {
    print("initState - Line 225");
    init();
    super.initState();
  }

  void init() async {
    print("init - Line 231");
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
      }
    });
  }

  void connectDev(BluetoothDevice dev) async {
    //sleep(const Duration(seconds: 1));
    print("connectDev - Line 243");
    await dev.connect().then((status) async {
      //add connected device to the list
      context.read<BleModel>().addconnectedDevices(dev);

      context.read<BleModel>().services = await dev.discoverServices();
      //Only works if I have 1 service. Review the logic if there is more than 1
      context.read<BleModel>().services.forEach((service) {
        context.read<BleModel>().characteristics = service.characteristics;
      });
      await context.read<BleModel>().characteristics[0].setNotifyValue(true);
      await context.read<BleModel>().characteristics[1].setNotifyValue(true);

      context.read<BleModel>().characteristics[0].value.listen((value) {
        context.read<BleModel>().addLat(value);
      });
      context.read<BleModel>().characteristics[1].value.listen((value) {
        context.read<BleModel>().addLng(value);
      });

      print("Connected");
      setState(() {
      });
    }).catchError((e) => print("Connection Error $e"));
  }

  //스캔 ON/OFF
  void scan() async {
    print("scan - Line 340");
    if (!_isScanning) {
      flutterBlue.startScan(withServices: [Guid(serviceUUID)]);

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
    // Consumer looks for an ancestor Provider widget
    // and retrieves its model (BLE Model, in this case).
    // Then it uses that model to build widgets, and will trigger
    // rebuilds if the model is updated.
    return Consumer<BleModel>(builder: (_, dev, child) {
      return ListView.builder(
          itemCount: dev.items.length,
          itemBuilder: (context, index) {
            return Column(children: <Widget>[
              SizedBox(height: 20.0),
              custom.ExpansionTile(
                  headerBackgroundColor: Colors.lightBlue,
                  iconColor: Colors.white,
                  title: ListTile(
                    title: Text(
                    "Device: " + dev.deviceList[index].device.name,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    ), 
                    trailing:
                    RichText(
                       text: TextSpan(
                            children: <InlineSpan>[ 
                              TextSpan(text: '85%', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
                              WidgetSpan(
                                alignment: ui.PlaceholderAlignment.middle, 
                                child: Icon(LineAwesomeIcons.battery_3_4_full, color: Colors.black87,), 
                                ),  
                              WidgetSpan(
                                alignment: ui.PlaceholderAlignment.middle, 
                                child: Container(child:
                                Icon(LineAwesomeIcons.wifi, color: Colors.black87,), 
                                padding: EdgeInsets.all(12.0),

                                ) 
                              ),  
                            ] 
                        ),
                    ),
                    // trailing:Column(children: <Widget>[Text("85%", style: TextStyle(fontSize: 10.0),), Icon(LineAwesomeIcons.battery_3_4_full)]),
                  ),
                  children: <Widget>[
                    dev.connectedDevices.length > 0 ?
                    ListTile(
                        title: Text("Configure Device WiFi"),
                        trailing: IconButton(
                            icon: Icon(Icons.wifi),
                            tooltip: 'Go to WiFI',
                            onPressed: () => Navigator.pushNamed(context, '/wifiConf'))) : Column(),
                    dev.connectedDevices.length > 0 ?
                    ListTile(
                        title: Text("Go to Map"),
                        trailing: IconButton(
                            icon: Icon(Icons.map),
                            tooltip: 'Go to Map',
                            onPressed: () => Navigator.pushNamed(context, '/blueMap')))
                            // onPressed: () => Navigator.pushReplacement(context,
                            //         MaterialPageRoute(builder: (context) {
                            //       return MapLocation();
                            //     })))),
                            : Column(),
                    ExpansionTile(
                        title: Text(
                          'Current Data',
                        ),
                        children: <Widget>[
                          ListTile(
                              title: dev.lat.length > 0 && dev.lng.length > 0
                                  ? Text("Lat: " +
                                      Utf8Decoder().convert(dev.lat) +
                                      " | Long: " +
                                      Utf8Decoder().convert(dev.lng) +
                                      " at : " +
                                      DateFormat('hh:mm:ss').format(dev.now))
                                  : Text(
                                      "No Data. Please Connect",
                                      style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 13,
                                          color: Colors.grey),
                                    ),
                              trailing: FlatButton(
                                color: dev.connectedDevices == null ||
                                        !dev.connectedDevices.contains(
                                            dev.deviceList[index].device)
                                    ? Colors.green
                                    : Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)),
                                onPressed: () {
                                  if (dev.connectedDevices != null) {
                                    if (!dev.connectedDevices.contains(
                                        dev.deviceList[index].device)) {
                                      connectDev(dev.deviceList[index].device);
                                    } else {
                                      dev.deviceList[index].device
                                          .disconnect()
                                          .then((status) async => {
                                                context
                                                    .read<BleModel>().removeConnectedDevice(dev.deviceList[index].device),
                                                setState(() {})
                                              });
                                    }
                                  } else {
                                    connectDev(dev.deviceList[index].device);
                                  }
                                },
                                child: Text(
                                  dev.connectedDevices == null ||
                                          !dev.connectedDevices.contains(
                                              dev.deviceList[index].device)
                                      ? "Connect"
                                      : "Disconnect",
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white),
                                ),
                              ))
                        ])
                  ])
            ]);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer<BleModel>(builder: (context, dev, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Locate My Pet"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to the first screen by popping the current route
              // off the stack.
              // Navigator.pop(context);
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) {
              //   return ProfileScreen();
              // }));
              Navigator.pushNamed(context, '/profile');
            }),
      ),
      backgroundColor: Colors.grey[100],
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
