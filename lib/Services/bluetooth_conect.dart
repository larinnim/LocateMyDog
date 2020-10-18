import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as vec;
import 'custom_expansion_tile.dart' as custom;

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

class BlueLocation {
  static final BlueLocation _singleton = BlueLocation._internal();

  BlueLocation._internal();

  factory BlueLocation(
      {List<int> lat, List<int> lng, DateTime now, double heading}) {
    _singleton.lat = lat;
    _singleton.lng = lng;
    _singleton.now = now;
    _singleton.heading = heading;
    return _singleton;
  }
  // BlueLocation._internal(this.lat, this.lng, this.now);

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
  List<BleDeviceItem> _deviceList = [];
  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _characteristics = [];
  List<BluetoothDevice> _connectedDevices;

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<BleDeviceItem> get items =>
      UnmodifiableListView(_deviceList);

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void addDeviceList(BleDeviceItem item) {
    _deviceList.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addService(BluetoothService service) {
    _services.add(service);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addcharacteristics(BluetoothCharacteristic characteristic) {
    _characteristics.add(characteristic);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addconnectedDevices(BluetoothDevice device) {
    _connectedDevices.add(device);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _deviceList.clear();
    _services.clear();
    _characteristics.clear();
    _connectedDevices.clear();
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
  // List<BleDeviceItem> deviceList = [];
  // List<BluetoothService> services = [];
  // List<BluetoothCharacteristic> characteristics = [];
  // List<BluetoothDevice> connectedDevices;
  // List<int> lat;
  // List<int> lng;
  // DateTime now;
  // GlobalKey<_BluetoothConnectionState> _bluetoothState = GlobalKey();

  String serviceUUID = "d1acf0d0-0a9b-11eb-adc1-0242ac120002";

  // Stream<LocationValues> _onLocationChanged;

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
  }

  void connectDev(BluetoothDevice dev) async {
    await dev.connect().then((status) async {
      // connectedDevices = await flutterBlue.connectedDevices;
      await flutterBlue.connectedDevices
          .then((value) async => {
                      Provider.of<BleModel>(context, listen: false)._connectedDevices = value,
                if (Provider.of<BleModel>(context, listen: false)._connectedDevices.contains(dev))
                  {
                    Provider.of<BleModel>(context, listen: false)._services = await dev.discoverServices(),
                    //Only works if I have 1 service. Review the logic if there is more than 1
                    Provider.of<BleModel>(context, listen: false)._services.forEach((service) {
                      Provider.of<BleModel>(context, listen: false)._characteristics = service.characteristics;
                    }),
                    await Provider.of<BleModel>(context, listen: false)._characteristics[0].setNotifyValue(true),
                    await Provider.of<BleModel>(context, listen: false)._characteristics[1].setNotifyValue(true),

                    Provider.of<BleModel>(context, listen: false)._characteristics[0].value.listen((value) {
                      // lat = value;
                      BlueLocation._singleton.lat = value;
                      print(
                          "Received Latitude: " + Utf8Decoder().convert(value));
                      setState(() {
                        BlueLocation._singleton.lat = value;
                        BlueLocation._singleton.now = DateTime.now();
                        BlueLocation._singleton.onLocationChanged();
                      });
                    }),
                    Provider.of<BleModel>(context, listen: false)._characteristics[1].value.listen((value) {
                      // lng = value;
                      print("Received Longitude: " +
                          Utf8Decoder().convert(value));
                      setState(() {
                        BlueLocation._singleton.lng = value;
                        BlueLocation._singleton.now = DateTime.now();
                        BlueLocation._singleton.onLocationChanged();
                      });
                    }),

                    // lat = await characteristics[0].read(),
                    BlueLocation._singleton.lat =
                        await Provider.of<BleModel>(context, listen: false)._characteristics[0].read(),
                    BlueLocation._singleton.lng =
                        await Provider.of<BleModel>(context, listen: false)._characteristics[1].read(),
                    print("Connected"),
                    setState(() {
                      // isConnected = true;
                    })
                  }
              })
          .catchError((e) => print(
              "Couldn't retrieve list of connected devices because of error $e"));
      print(BlueLocation._singleton.lat);
      print(BlueLocation._singleton.lng);
    }).catchError((e) => print("Connection Error $e"));
  }

  //스캔 ON/OFF
  void scan() async {
    if (!_isScanning) {
      // Provider.of<BleModel>(context, listen: false).removeAll();

      // deviceList.clear();
      flutterBlue.startScan(withServices: [Guid(serviceUUID)]);

      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          //Check if the device has already been discovered Check by mac address
          var findDevice = Provider.of<BleModel>(context, listen: false)
              ._deviceList
              .any((element) {
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
            Provider.of<BleModel>(context, listen: false)
                .addDeviceList(BleDeviceItem(r.rssi, r.advertisementData, r.device));
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
    return ListView.builder(
        itemCount: Provider.of<BleModel>(context, listen: false).items.length,
        itemBuilder: (context, index) {
          return Column(children: <Widget>[
            SizedBox(height: 20.0),
            custom.ExpansionTile(
                headerBackgroundColor: Colors.blue,
                iconColor: Colors.white,
                title: Text(
                  "Device: " +
                      Provider.of<BleModel>(context, listen: false)
                          ._deviceList[index]
                          .device
                          .name,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                children: <Widget>[
                  ListTile(
                      title: Text("Configure Device WiFi"),
                      trailing: IconButton(
                          icon: Icon(Icons.wifi),
                          tooltip: 'Go to Map',
                          onPressed: () => Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return MapLocation();
                              })))),
                  ListTile(
                      title: Text("Go to Map"),
                      trailing: IconButton(
                          icon: Icon(Icons.map),
                          tooltip: 'Go to Map',
                          onPressed: () => Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return MapLocation();
                              })))),
                  ExpansionTile(
                      title: Text(
                        'Current Data',
                      ),
                      children: <Widget>[
                        ListTile(
                            title: BlueLocation._singleton.lat != null &&
                                    BlueLocation._singleton.lng != null
                                ? Text("Lat :" +
                                    Utf8Decoder()
                                        .convert(BlueLocation._singleton.lat) +
                                    " | Long: " +
                                    Utf8Decoder()
                                        .convert(BlueLocation._singleton.lng) +
                                    " at : " +
                                    DateFormat('hh:mm:ss')
                                        .format(BlueLocation._singleton.now))
                                : Text(
                                    "No Data. Please Connect",
                                    style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 13,
                                        color: Colors.grey),
                                  ),
                            trailing: FlatButton(
                              color: Provider.of<BleModel>(context, listen: false)._connectedDevices == null ||
                                      !Provider.of<BleModel>(context, listen: false)._connectedDevices.contains(
                                          Provider.of<BleModel>(context,
                                                  listen: false)
                                              ._deviceList[index]
                                              .device)
                                  ? Colors.green
                                  : Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0)),
                              onPressed: () {
                                if (Provider.of<BleModel>(context, listen: false)._connectedDevices != null) {
                                  if (!Provider.of<BleModel>(context, listen: false)._connectedDevices.contains(
                                      Provider.of<BleModel>(context,
                                              listen: false)
                                          ._deviceList[index]
                                          .device)) {
                                    connectDev(Provider.of<BleModel>(context,
                                            listen: false)
                                        ._deviceList[index]
                                        .device);
                                  } else {
                                    Provider.of<BleModel>(context,
                                            listen: false)
                                        ._deviceList[index]
                                        .device
                                        .disconnect()
                                        .then((status) async => {
                                              await flutterBlue.connectedDevices
                                                  .then((value) async => {
                                                        Provider.of<BleModel>(context, listen: false)._connectedDevices =
                                                            value,
                                                        if (!Provider.of<BleModel>(context, listen: false)._connectedDevices
                                                            .contains(Provider.of<
                                                                        BleModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                ._deviceList[
                                                                    index]
                                                                .device))
                                                          {
                                                            BlueLocation
                                                                ._singleton
                                                                .lat = null,
                                                            BlueLocation
                                                                ._singleton
                                                                .lng = null,
                                                            setState(() {})
                                                          }
                                                      })
                                            });
                                  }
                                } else {
                                  connectDev(Provider.of<BleModel>(context,
                                          listen: false)
                                      ._deviceList[index]
                                      .device);
                                }
                              },
                              child: Text(
                                Provider.of<BleModel>(context, listen: false)._connectedDevices == null ||
                                        !Provider.of<BleModel>(context, listen: false)._connectedDevices.contains(
                                            Provider.of<BleModel>(context,
                                                    listen: false)
                                                ._deviceList[index]
                                                .device)
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
                return ProfileScreen();
              }));
            }),
      ),
      backgroundColor: Colors.grey[100],
      // body: Column(
      //   children: <Widget>[
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Container(
      //       color:Colors.blue[50],
      body: Center(
        //디바이스 리스트 함수 호출
        child: list(),
      ),
      // ),
      // ),
      // ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: scan, //버튼이 눌리면 스캔 ON/OFF 동작
        child: Icon(_isScanning
            ? Icons.stop
            : Icons.bluetooth_searching), //_isScanning 변수에 따라 아이콘 표시 변경
      ),
    );
  }
}
