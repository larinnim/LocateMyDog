import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions.dart';
import 'package:flutter_maps/Screens/loading.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../Services/bluetooth_conect.dart';

// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MapLocation extends StatefulWidget {
  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  // CollectionReference locationDB =
  //     FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  CollectionReference sendersCollection =
      FirebaseFirestore.instance.collection('sender');

  // List<Marker?> markers = <Marker?>[];
  List<Polyline> mapPolylines = <Polyline>[];
  late LatLng _currentPosition;
  Circle? circle;
  late GoogleMapController _controller;
  // Map<PolylineId, Polyline> _mapPolylines = {};
  final List<LatLng> points = <LatLng>[];
  // FirebaseStorage firestore = FirebaseStorage.instance;
  Geoflutterfire geo = Geoflutterfire();
  CollectionReference reference =
      FirebaseFirestore.instance.collection('locations');
  List<LatLng> polyLinesLatLongs = []; // our list of geopoints
  var mapLocation;
  Uint8List? imageData;
  // BitmapDescriptor icon;
  late Marker marker;
  Timer? timer;
  // List<Marker> markers = [];
  Set<Marker> markers = Set();

  // final List<Flushbar> flushBars = [];

  @override
  void initState() {
    super.initState();
    _initSenders();
    // timer = Timer.periodic(Duration(seconds: 3), (Timer t) => moveCamera());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _initSenders() async {
    await sendersCollection
        .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var latlng =
            LatLng(doc['Location']['Latitude'], doc['Location']['Longitude']);
        setState(() {
          updateMarkerAndCircle(latlng, doc.id, doc['color']);
        });
      });
    });
    readDatabase(); // set context read
  }

  Future<List<DocumentSnapshot>> getSendersID() async {
    // var data = await FirebaseFirestore.instance
    //     .collection('locateDog')
    //     .doc(_firebaseAuth.currentUser?.uid)
    //     .collection('gateway')
    //     .get();
    var data = await sendersCollection
        .where('userID', isEqualTo: _firebaseAuth.currentUser?.uid)
        .get();
    var senders = data.docs;
    return senders;
  }

  void readDatabase() async {
    int gwBatteryLevel = 0;
    if (_firebaseAuth.currentUser != null) {
      sendersCollection
          .where('userID',
              isEqualTo: _firebaseAuth
                  .currentUser?.uid) //Listen to changes in all the users
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> firestoreInfo = change.doc.data()!;
          firestoreInfo.forEach((key, value) async {
            print(key);
            print(value);
            await FirebaseFirestore.instance
                .collection('gateway')
                .doc('GW-' + firestoreInfo["senderMac"])
                .get()
                .then((DocumentSnapshot documentSnapshot) {
              if (documentSnapshot.exists) {
                print('Document exists on the database');
                gwBatteryLevel = documentSnapshot['batteryLevel'];
              }
            });
            context.read<IATDataModel>().addIatData(new IATData(
                senderMAC: firestoreInfo["senderMac"],
                latitude: firestoreInfo['Location']['Latitude'],
                longitude: firestoreInfo['Location']['Longitude'],
                locationTimestamp:
                    firestoreInfo['LocationTimestamp'] != "" ? DateTime.parse(firestoreInfo['LocationTimestamp'])
                        .millisecondsSinceEpoch : 0,
                gatewayMAC: firestoreInfo['gatewayID'],
                trackerBatteryLevel: firestoreInfo['batteryLevel'],
                gatewayBatteryLevel: gwBatteryLevel,
                senderColor: firestoreInfo['color']));
          });
        });
      });
    }
  }

  Future<void> moveCamera() async {
    // if (_currentPosition.latitude != null &&
    //     _currentPosition.longitude != null) {
    _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        tilt: 0,
        zoom: 18.00)));
    // }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/dogpin.png");
    return byteData.buffer.asUint8List();
  }

  Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<Set<Marker>> updateMarkerAndCircle(
      LatLng latlong, String? sender, String senderColor) async {
    LatLng latlng = LatLng(latlong.latitude, latlong.longitude);
    late Uint8List imageData;
    // locationDB
    //     .doc(_firebaseAuth.currentUser!.uid)
    //     .get()
    //     .then((DocumentSnapshot documentSnapshot) {
    //   if (documentSnapshot.exists) {
    //     documentSnapshot.data()!.forEach((key, value) async {
    //       if (key == sender) {
    String pathColor = 'assets/images/' + 'dogpin_' + senderColor + '.png';
    ByteData byteData = await DefaultAssetBundle.of(context).load(pathColor);
    imageData = byteData.buffer.asUint8List();
    _currentPosition = latlong;

    // if (markers.length > 0) {
    //   marker = markers[0];

    // setState(() {
    //   markers[0] = marker.copyWith(
    //       positionParam: LatLng(latlong.latitude, latlong.longitude));
    // });
    // } else {
    if (markers.length > 0) {
      markers.removeWhere((marker) => marker.mapsId.value.toString() == sender);
    }
    marker = Marker(
        markerId: MarkerId(sender!),
        position: latlng,
        // rotation: BleSingleton.shared.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData));
    markers.add(marker);
    //   for (var i = 0; i < 4; i++) {
    //     if (markers[i].markerId.value == sender) {
    //       setState(() {
    //         markers[i] = marker.copyWith(
    //             positionParam: LatLng(latlong.latitude, latlong.longitude));
    //       });
    //     } else {
    //       marker = Marker(
    //           markerId: MarkerId(sender!),
    //           position: latlng,
    //           // rotation: BleSingleton.shared.heading,
    //           draggable: false,
    //           zIndex: 2,
    //           flat: true,
    //           anchor: Offset(0.5, 0.5),
    //           icon: BitmapDescriptor.fromBytes(imageData));
    //       setState(() {
    //         markers.add(marker);
    //       });
    //     }
    //   }
    // } else {
    //   marker = Marker(
    //       markerId: MarkerId(sender!),
    //       position: latlng,
    //       // rotation: BleSingleton.shared.heading,
    //       draggable: false,
    //       zIndex: 2,
    //       flat: true,
    //       anchor: Offset(0.5, 0.5),
    //       icon: BitmapDescriptor.fromBytes(imageData));
    //   setState(() {
    //     markers.add(marker);
    //   });
    // }

    // markers.add(marker);
    // }
    // }
    return markers.toSet();
  }

  // Uint8List imageData = await getMarker();
  //
  // _currentPosition = latlong;

  // if (markers.length > 0) {
  //   marker = markers[0];

  //   setState(() {
  //     markers[0] = marker.copyWith(
  //         positionParam: LatLng(latlong.latitude, latlong.longitude));
  //   });
  // } else {
  //   marker = Marker(
  //       markerId: MarkerId("home"),
  //       position: latlng,
  //       // rotation: BleSingleton.shared.heading,
  //       draggable: false,
  //       zIndex: 2,
  //       flat: true,
  //       anchor: Offset(0.5, 0.5),
  //       icon: BitmapDescriptor.fromBytes(imageData));
  //   setState(() {
  //     markers.add(marker);
  //   });
  //   // markers.add(marker);
  // }
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final connectionStatus =
        Provider.of<ConnectionStatusModel>(context, listen: false);
    connectionStatus.initConnectionListen();

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Text("Map"),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate back to the first screen by popping the current route
                  // off the stack.
                  flutterLocalNotificationsPlugin.cancelAll();
                  Navigator.pushNamed(context, '/profile');
                })),
        body: Consumer3<IATDataModel, WiFiModel, ConnectionStatusModel>(builder:
            (_, iatDataProvider, wifiProvider, connectionProvider, child) {
          return FutureBuilder(
              future: mounted
                  ? connectionStatus.getCurrentStatus()
                  : Future.value(null),
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return connectionProvider.connectionStatus ==
                              NetworkStatus.Offline ||
                          snapshot.data == NetworkStatus.Offline
                      ? CupertinoAlertDialog(
                          title: Text(
                              'You are offline. You are going to be redirected to Offline mode'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  // return Radar();
                                  return OfflineRegionBody();
                                }));
                              },
                            )
                          ],
                        )
                      : iatDataProvider.iatData.latitude != null &&
                              iatDataProvider.iatData.longitude != null
                          ? FutureBuilder(
                              future: //its sending BLE
                                  // ? updateMarkerAndCircle(
                                  //     LatLng(
                                  //         bleProvider.lat!, bleProvider.lng!),
                                  //     bleProvider.senderNumber,
                                  //     "green") //TODO create color logic for BLE
                                  // :
                                  updateMarkerAndCircle(
                                      LatLng(iatDataProvider.iatData.latitude!,
                                          iatDataProvider.iatData.longitude!),
                                      iatDataProvider.iatData.senderMAC,
                                      iatDataProvider.iatData
                                          .senderColor!), // its sending WIFI
                              initialData: Set.of(<Marker>[]),
                              builder: (context, snapshotMarker) {
                                return Align(
                                  child: SafeArea(
                                    child: Column(children: <Widget>[
                                      // SizedBox(height:  MediaQuery.of(context).size.height * 0.1, width: MediaQuery.of(context).size.width,),
                                      Expanded(
                                        child: SizedBox(
                                          // width: MediaQuery.of(context).size.width,
                                          // height: MediaQuery.of(context).size.height * 0.89,
                                          child: GoogleMap(
                                            mapType: MapType.hybrid,
                                            onMapCreated: (GoogleMapController
                                                controller) {
                                              _controller = controller;
                                              moveCamera();
                                            },
                                            initialCameraPosition:
                                                CameraPosition(
                                                    target: LatLng(
                                                        iatDataProvider
                                                            .iatData.latitude!,
                                                        iatDataProvider.iatData
                                                            .longitude!),
                                                    zoom: 16.0),
                                            markers: markers.toSet(),

                                            circles: Set.of((circle != null)
                                                ? [circle!]
                                                : []),
                                            // polylines: snapshotPolyline.data,
                                            myLocationButtonEnabled: false,
                                            zoomGesturesEnabled: true,
                                            mapToolbarEnabled: true,
                                            myLocationEnabled: false,
                                            scrollGesturesEnabled: true,
                                            // initialCameraPosition:
                                            //     const CameraPosition(
                                            //         target: LatLng(0.0, 0.0)),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                );
                              })
                          : new Container();
                } else {
                  return Loading();
                }
              });
          // })

          // (currentPositionBle.lat != null &&
          //             currentPositionBle.lng != null ||
          //         currentPositionWiFi.lat != null &&
          //             currentPositionWiFi.lng != null)
          //     ?
          //   Consumer3<BleModel, WiFiModel, ConnectionStatusModel>(builder:
          //       (_, bleProvider, wifiProvider, connectionProvider, child) {
          // return FutureBuilder(
          //     future: mounted
          //         ? connectionStatus.getCurrentStatus()
          //         : Future.value(null),
          //     initialData: false,
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData) {
          //         return connectionProvider.connectionStatus ==
          //                     NetworkStatus.Offline ||
          //                 snapshot.data == NetworkStatus.Offline
          //             ? CupertinoAlertDialog(
          //                 title: Text(
          //                     'You are offline. You are going to be redirected to Offline mode'),
          //                 actions: [
          //                   CupertinoDialogAction(
          //                     child: Text('OK'),
          //                     onPressed: () {
          //                       Navigator.push(context,
          //                           MaterialPageRoute(builder: (context) {
          //                         // return Radar();
          //                         return OfflineRegionBody();
          //                       }));
          //                     },
          //                   )
          //                 ],
          //               )
          //             : bleProvider.lat != null && bleProvider.lng != null ||
          //                     wifiProvider.lat != null &&
          //                         wifiProvider.lng != null
          //                 ? FutureBuilder(
          //                     future: (bleProvider.timestampBLE != null &&
          //                             wifiProvider.timestampWiFi != null &&
          //                             bleProvider.timestampBLE!.isAfter(
          //                                 wifiProvider
          //                                     .timestampWiFi!)) //its sending BLE
          //                         ? updateMarkerAndCircle(
          //                             LatLng(
          //                                 bleProvider.lat!, bleProvider.lng!),
          //                             bleProvider.senderNumber,
          //                             "green") //TODO create color logic for BLE
          //                         : updateMarkerAndCircle(
          //                             LatLng(
          //                                 wifiProvider.lat!, wifiProvider.lng!),
          //                             wifiProvider.senderNumber,
          //                             wifiProvider
          //                                 .senderColor!), // its sending WIFI
          // (bleProvider.timestampBLE == null &&
          //         wifiProvider.timestampWiFi != null) //its sending WIFI
          //     ? updateMarkerAndCircle(
          //         LatLng(wifiProvider.lat!,
          //             wifiProvider.lng!),
          //         wifiProvider.senderNumber)
          // : (bleProvider != null &&
          //         wifiProvider == null)
          //     ? updateMarkerAndCircle(
          //         LatLng(bleProvider.lat!,
          //             bleProvider.lng!),
          //         bleProvider.senderNumber)
          //     : updateMarkerAndCircle(
          //         LatLng(wifiProvider.lat!,
          //             wifiProvider.lng!),
          //         wifiProvider.senderNumber),
          // initialData: Set.of(<Marker>[]),
          // builder: (context, snapshotMarker) {
          // return new Stack(
          //   children: <Widget>[

          // new Container(
          //   height:
          //       1000, // This line solved the issue
          //   child: GoogleMap(
          //     mapType: MapType.hybrid,
          //     initialCameraPosition: (bleProvider
          //                     .timestampBLE !=
          //                 null &&
          //             wifiProvider.timestampWiFi !=
          //                 null &&
          //             bleProvider.timestampBLE!
          //                 .isAfter(wifiProvider
          //                     .timestampWiFi!)) // BLE is sending
          //         ? CameraPosition(
          //             target: LatLng(bleProvider.lat!,
          //                 bleProvider.lng!),
          //             zoom: 16.0)
          //         : CameraPosition(
          //             target: LatLng(
          //                 wifiProvider.lat!,
          //                 wifiProvider.lng!),
          //             zoom: 16.0), //WIFI is sending
          //     // (bleProvider.timestampBLE == null &&
          //     //         wifiProvider.timestampWiFi !=
          //     //             null)  // WIFI is sending
          //     //     ? CameraPosition(
          //     //         target: LatLng(
          //     //             wifiProvider.lat!,
          //     //             wifiProvider.lng!),
          //     //         zoom: 16.0)
          //     //     : (bleProvider != null &&
          //     //             wifiProvider == null)
          //     //         ? CameraPosition(
          //     //             target: LatLng(
          //     //                 bleProvider.lat!,
          //     //                 bleProvider.lng!),
          //     //             zoom: 16.0)
          //     //         : CameraPosition(
          //     //             target: LatLng(bleProvider.lat!, bleProvider.lng!),
          //     //             zoom: 16.0),
          //     // markers: snapshotMarker.data,
          //     markers: markers.toSet(),

          //     circles: Set.of(
          //         (circle != null) ? [circle!] : []),
          //     // polylines: snapshotPolyline.data,
          //     myLocationButtonEnabled: false,
          //     zoomGesturesEnabled: true,
          //     mapToolbarEnabled: true,
          //     myLocationEnabled: false,
          //     scrollGesturesEnabled: true,
          //     onMapCreated:
          //         (GoogleMapController controller) {
          //       _controller = controller;
          //       moveCamera();
          //     },
          //   ), // Mapbox
          // ),
          // connectionProvider.connectionStatus ==
          //         NetworkStatus.Offline
          //     ? CupertinoAlertDialog(
          //         title: Text(
          //             'You are offline. You are going to be redirected to Offline mode'),
          //         actions: [
          //           CupertinoDialogAction(
          //             child: Text('OK'),
          //             onPressed: () {
          //               // TODO ENABLE WHEN MAPBOX NULLSAFETY IS AVAILABLE
          //               // Navigator.push(context,
          //               //     MaterialPageRoute(
          //               //         builder: (context) {
          //               //   // return Radar();
          //               //   return OfflineRegionBody();
          //               // }));
          //             },
          //           )
          //         ],
          //       )
          //     : new Container()
          //   ],
          // );
          //                       })
          //                   : Loading();
          //         } else {
          //           return Loading();
          //         }
          //       });
          // })
          // :
          // Loading()
          //  Center(
          //     child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       Icon(FontAwesomeIcons.exclamationTriangle),
          //       Padding(
          //         padding: EdgeInsets.only(top: 30.0),
          //       ),
          //       Text(
          //         'Whoops',
          //         style:
          //             TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          //       ),
          //       Padding(
          //         padding: EdgeInsets.only(top: 15.0),
          //       ),
          //       Text(
          //           'You are offline. Please connect the gateway to WiFi or Bluetooth to continue'),
          //     ],
          //   ))
        }));
  }
}
