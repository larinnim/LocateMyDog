import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Screens/Devices/gateway_detail.dart';
import 'package:flutter_maps/Services/constants.dart';
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

// class BleSingleton {
//   static final BleSingleton _singleton = BleSingleton._internal();
//   factory BleSingleton() => _singleton;
//   BleSingleton._internal();
//   static BleSingleton get shared => _singleton;
//   double lat;
//   double lng;
//   String senderNumber;
//   DateTime now = DateTime.now();
//   double heading = 90;
//   List<BluetoothDevice> connectedDevices = [];

//   // BlueLocation.private(this.lat, this.lng, this.now);

//   Stream<LocationValues> _onLocationChanged;
//   StreamController<dynamic> controller;

//   /// Returns a stream of [LocationData] objects.
//   /// The frequency and accuracy of this stream can be changed with [changeSettings]
//   ///
//   /// Throws an error if the app has no permission to access location.
//   Stream<LocationValues> onLocationChanged() {
//     _onLocationChanged = receiveBroadcastStream().map<LocationValues>(
//         (element) => LocationValues.fromMap(element.cast<String, double>()));
//     return _onLocationChanged;
//   }

//   Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
//     controller = StreamController<dynamic>.broadcast(onListen: () async {
//       // binaryMessenger.setMessageHandler(name, (ByteData reply) async {
//       try {
//         controller.add(lat);
//         controller.add(lng);
//         controller.add(now);
//         controller.close();
//       } on PlatformException catch (e) {
//         controller.addError(e);
//       }
//     });
//     return controller.stream;
//   }
// }

class BleModel extends ChangeNotifier {
  List<BleDeviceItem> deviceList = [];
  List<BluetoothService> services = [];
  List<BluetoothCharacteristic> characteristics = [];
  List<BluetoothDevice> connectedDevices = [];
  double lat;
  double lng;
  DateTime timestampBLE;
  String senderNumber;

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
    senderNumber = null;
    // BleSingleton._singleton.lat = null;
    // BleSingleton._singleton.lng = null;
    // BleSingleton._singleton.now = null;
    // BleSingleton._singleton.senderNumber = null;
    // BleSingleton._singleton.connectedDevices.remove(device);
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

  void addLatLng(double receivedLat, double receivedLng, String sender) {
    //print("addLat - Line 166");
    lat = receivedLat;
    lng = receivedLng;
    senderNumber = sender;
    // BleSingleton._singleton.lat = value;
    // BleSingleton._singleton.now = DateTime.now();
    // timestampBLE = BleSingleton._singleton.now;
    // BleSingleton._singleton.onLocationChanged();
    // print("Latitude received: " + value.toString());
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // void addLng(double value, String sender) {
  //   //print("addLgn - Line 177");
  //   lng = value;
  //   senderNumber = sender;
  //   BleSingleton._singleton.lng = value;
  //   BleSingleton._singleton.now = DateTime.now();
  //   timestampBLE = BleSingleton._singleton.now;
  //   BleSingleton._singleton.onLocationChanged();
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }

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

  // @override
  // void initState() {
  //   print("initState - Line 225");
  //   init();
  //   super.initState();
  // }

  // void init() async {
  //   print("init - Line 231");
  //   FlutterBlue.instance.state.listen((state) {
  //     if (state == BluetoothState.off) {
  //       //Alert user to turn on bluetooth.
  //       // showDialog(
  //       //     context: context,
  //       //     child: new AlertDialog(
  //       //       title: new Text("Bluetooth is Off"),
  //       //       content: new Text("Turn on Bluetooth to start scanning."),
  //       //     ));
  //     } else if (state == BluetoothState.on) {
  //       //if bluetooth is enabled then go ahead.
  //       //Make sure user's device gps is on.
  //     }
  //   });
  // }

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
        // await context
        //     .read<BleModel>()
        //     .characteristics
        //     .elementAt(1)
        //     .setNotifyValue(true); //ESP32 - Longitude

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

          final lat = values[0];
          final lng = values[1];
          final sender = values[2];

          // print("LAT VALUEE:" + value.toString());
          context.read<BleModel>().addLatLng(double.parse(
              lat), double.parse(lng), sender); // Add lat to provider
        });
        // context
        //     .read<BleModel>()
        //     .characteristics
        //     .elementAt(1)
        //     .value
        //     .listen((value) {
        //   context.read<BleModel>().addLng(
        //         double.parse(Utf8Decoder().convert(value)),
        //       ); // Add lng to provider
        // });

        print("Connected");
        setState(() {});
      }).catchError((e) => print("Connection Error $e"));
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

      //  flutterBlue.startScan().then((value) {
      //     new Future.delayed(const Duration(seconds: 5), () {
      //       // deleayed code here
      //       setState(() {
      //         _isScanning = false;
      //       });
      //     });
      //   });

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

    // var dataBLE = Provider.of<BleModel>(context);
    // var dataWiFi = Provider.of<WiFiModel>(context);

    return Consumer2<BleModel, WiFiModel>(
        builder: (_, bleProvider, wifiProvider, child) {
      return ListView.builder(
          itemCount: bleProvider.items.length,
          itemBuilder: (context, index) {
            return Column(children: <Widget>[
              SizedBox(height: 20.0),
              //                 StreamBuilder<BluetoothDeviceState>(
              // stream: bleProvider.deviceList[index].device.state
              //     .asBroadcastStream(),
              // builder: (context, snapshot) {
              // return
              // snapshot.data == BluetoothDeviceState.disconnected ?
              //  Container() :
              // custom.ExpansionTile(
              //     headerBackgroundColor: Colors.lightBlue,
              //     iconColor: Colors.white,
              //     initiallyExpanded: true,
              //     title:
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200],
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GatewayDetails(
                                title: bleProvider
                                    .deviceList[index].device.name)));
                  },
                ),

                // ListTile(
                //   title: Text(
                //     "Device: " + bleProvider.deviceList[index].device.name,
                //     style: TextStyle(
                //         fontSize: 18.0,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.white),
                //   ),
                //   trailing: RichText(
                //     text: TextSpan(children: <InlineSpan>[
                //       TextSpan(
                //           text: '85%',
                //           style: TextStyle(
                //               color: Colors.black,
                //               fontWeight: FontWeight.bold)),
                //       WidgetSpan(
                //         alignment: ui.PlaceholderAlignment.middle,
                //         child: Icon(
                //           LineAwesomeIcons.battery_3_4_full,
                //           color: Colors.black87,
                //         ),
                //       ),
                //       WidgetSpan(
                //           alignment: ui.PlaceholderAlignment.middle,
                //           child: Container(
                //             child: Icon(
                //               LineAwesomeIcons.wifi,
                //               color: Colors.black87,
                //             ),
                //             padding: EdgeInsets.all(12.0),
                //           )),
                //     ]),
                //   ),
                //   // trailing:Column(children: <Widget>[Text("85%", style: TextStyle(fontSize: 10.0),), Icon(LineAwesomeIcons.battery_3_4_full)]),
                // ),

                // children: <Widget>[
                //   bleProvider.connectedDevices.length > 0
                //       // &&
                //       //         snapshot.data ==
                //       //             BluetoothDeviceState.connected
                //       ? ListTile(
                //           onTap: () {
                //             Navigator.pushNamed(context, '/wifiConf');
                //           },
                //           title: Text("Configure Device WiFi"),
                //           trailing: IconButton(
                //               icon: Icon(Icons.wifi),
                //               tooltip: 'Go to WiFI',
                //               // onPressed: () => {},
                //               onPressed: () =>
                //                   Navigator.pushNamed(context, '/wifiConf')))
                //       : Column(),
                //   bleProvider.connectedDevices.length > 0
                //       // &&
                //       // snapshot.data ==
                //       //     BluetoothDeviceState.connected
                //       ? ListTile(
                //           onTap: () {
                //             Navigator.pushNamed(context, '/blueMap');
                //           },
                //           title: Text("Go to Map"),
                //           trailing: IconButton(
                //               icon: Icon(Icons.map),
                //               tooltip: 'Go to Map',
                //               // onPressed: () => {},
                //               onPressed: () =>
                //                   Navigator.pushNamed(context, '/blueMap')))
                //       // onPressed: () => Navigator.pushReplacement(context,
                //       //         MaterialPageRoute(builder: (context) {
                //       //       return MapLocation();
                //       //     })))),
                //       : Column(),
                //   ExpansionTile(
                //       title: Text(
                //         'Current Data',
                //       ),
                //       initiallyExpanded: true,
                //       children: <Widget>[
                //         ListTile(
                //             title: (bleProvider.lat != null &&
                //                         wifiProvider.lat == null) ||
                //                     (bleProvider.timestampBLE != null &&
                //                         wifiProvider.timestampWiFi != null &&
                //                         bleProvider.timestampBLE.isAfter(
                //                             wifiProvider.timestampWiFi))
                //                 ? Text("Lat: " +
                //                     bleProvider.lat.toString() +
                //                     // Utf8Decoder().convert(bleProvider.lat) +
                //                     " | Long: " +
                //                     bleProvider.lng.toString() +
                //                     // Utf8Decoder().convert(bleProvider.lng) +
                //                     " at : " +
                //                     DateFormat('hh:mm:ss')
                //                         .format(bleProvider.timestampBLE))
                //                 : (bleProvider.lat == null &&
                //                             wifiProvider.lat != null) ||
                //                         wifiProvider.timestampWiFi != null &&
                //                             bleProvider.timestampBLE !=
                //                                 null &&
                //                             wifiProvider.timestampWiFi
                //                                 .isAfter(
                //                                     bleProvider.timestampBLE)
                //                     ? Text("Lat: " +
                //                         wifiProvider.lat.toString() +
                //                         // Utf8Decoder().convert(wifiProvider.lat) +
                //                         " | Long: " +
                //                         wifiProvider.lng.toString() +
                //                         // Utf8Decoder().convert(wifiProvider.lng) +
                //                         " at : " +
                //                         DateFormat('hh:mm:ss').format(
                //                             wifiProvider.timestampWiFi))
                //                     : Text(
                //                         "No Data. Please Connect",
                //                         style: TextStyle(
                //                             fontFamily: 'Raleway',
                //                             fontSize: 13,
                //                             color: Colors.grey),
                //                       ),
                //             trailing:
                //                 // StreamBuilder<BluetoothDeviceState>(
                //                 //     stream: bleProvider
                //                 //         .deviceList[index].device.state
                //                 //         .asBroadcastStream(),
                //                 //     builder: (context, snapshot) {
                //                 // return
                //                 FlatButton(
                // color: (bleProvider.connectedDevices == null ||
                //         bleProvider.connectedDevices.length == 0
                //                   //  ||
                //                   // snapshot.data !=
                //                   //         BluetoothDeviceState
                //                   //             .connected &&
                //                   //     snapshot.data !=
                //                   //         BluetoothDeviceState
                //                   //             .connecting
                //                   )
                //                   ? Colors.green
                //                   : Colors.red,
                //               shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(18.0)),
                //               onPressed: () {
                //                 if (bleProvider.connectedDevices != null) {
                //                   if (bleProvider.connectedDevices.length == 0
                //                       // ||
                //                       // snapshot.data !=
                //                       //         BluetoothDeviceState
                //                       //             .connected &&
                //                       //     snapshot.data !=
                //                       //         BluetoothDeviceState
                //                       //             .connecting
                //                       ) {
                //                     connectDev(
                //                         bleProvider.deviceList[index].device);
                //                   } else {
                //                     bleProvider.deviceList[index].device
                //                         .disconnect()
                //                         .then((status) async => {
                //                               context
                //                                   .read<BleModel>()
                //                                   .removeConnectedDevice(
                //                                       bleProvider
                //                                           .deviceList[index]
                //                                           .device),
                //                               setState(() {})
                //                             });
                //                   }
                //                 } else {
                //                   connectDev(
                //                       bleProvider.deviceList[index].device);
                //                 }
                //               },
                //               child: Text(
                //                 bleProvider.connectedDevices == null ||
                //                         bleProvider.connectedDevices.length ==
                //                             0
                //                     // ||
                //                     // snapshot.data !=
                //                     //         BluetoothDeviceState
                //                     //             .connected &&
                //                     //     snapshot.data !=
                //                     //         BluetoothDeviceState
                //                     //             .connecting
                //                     ? "Connect"
                //                     : "Disconnect",
                //                 style: TextStyle(
                //                     fontSize: 15.0, color: Colors.white),
                //               ),
                //             ))
                //       ])
                // ]
                // })
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: scan, //버튼이 눌리면 스캔 ON/OFF 동작
      // child: Icon(_isScanning
      //     ? Icons.stop
      //     : Icons.bluetooth_searching), //_isScanning 변수에 따라 아이콘 표시 변경
      // ),
    );
  }
}
