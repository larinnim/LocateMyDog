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
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions.dart';
import 'package:flutter_maps/Screens/loading.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:flutter_maps/Services/custom_window_info.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../Services/bluetooth_conect.dart';
import 'dart:math' as math;

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

  bool _isSatellite = false;

  CollectionReference sendersCollection =
      FirebaseFirestore.instance.collection('sender');

  // List<Marker?> markers = <Marker?>[];
  // List<Polyline> mapPolylines = <Polyline>[];
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  List<PolylineId>? selectedPolyline;
  late LatLng _currentPosition;
  Circle? circle;
  late GoogleMapController _controller;
  // Map<PolylineId, Polyline> _mapPolylines = {};

  // final List<LatLng> _points = <LatLng>[];
  Map<String, List<LatLng>> _points = <String, List<LatLng>>{};

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  // FirebaseStorage firestore = FirebaseStorage.instance;
  Geoflutterfire geo = Geoflutterfire();
  CollectionReference reference =
      FirebaseFirestore.instance.collection('locations');
  List<LatLng> polyLinesLatLongs = []; // our list of geopoints
  var mapLocation;
  Uint8List? imageData;
  LatLng? initLocation;
  // BitmapDescriptor icon;
  late Marker marker;
  Timer? timer;
  // List<Marker> markers = [];
  // Set<Marker> markers = Set();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // final List<Flushbar> flushBars = [];

  @override
  void initState() {
    _getMapType();
    super.initState();
    _initSenders();

    // timer = Timer.periodic(Duration(seconds: 3), (Timer t) => moveCamera());
  }

  @override
  void dispose() {
    timer?.cancel();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _addPolyline(Provider.of<IATDataModel>(context, listen: false).iatData);
    _currentPosition = LatLng(
        Provider.of<IATDataModel>(context, listen: false).iatData.latitude ?? 0,
        Provider.of<IATDataModel>(context, listen: false).iatData.longitude ??
            0);
  }

  Future<void> _getMapType() async {
    await userCollection
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      _isSatellite = documentSnapshot.data()!['MapTypeIsSatellite'];
    });
  }

  void _addPolyline(IATData iatData) {
    final PolylineId polylineId = PolylineId(iatData.senderMAC ?? "");
    // final List<LatLng> _points = <LatLng>[];

    if (_points.length > 0) {
      if (!_points.containsKey(iatData.senderMAC) &&
          iatData.latitude != 0 &&
          iatData.longitude != 0) {
        // if (_points[iatData.senderMAC]!.last.latitude != iatData.latitude ||
        //     _points[iatData.senderMAC]!.last.longitude != iatData.longitude) {
        _points
            .putIfAbsent(iatData.senderMAC ?? "", () => <LatLng>[])
            .add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
        final Polyline polyline = Polyline(
          polylineId: polylineId,
          consumeTapEvents: true,
          color: AuxFunc().getColor(iatData.senderColor),
          width: 5,
          points: _points[iatData.senderMAC]!,
          // onTap: () {
          //   _onPolylineTapped(polylineId);
          // },
        );
        setState(() {
          polylines[polylineId] = polyline;
        });
        // _points.add(LatLng(iatData.latitude ?? 0, iatDat  a.longitude ?? 0));
        // }
      } else if (_points.containsKey(iatData.senderMAC) &&
              iatData.latitude != 0 &&
              iatData.longitude != 0 &&
              _points[iatData.senderMAC]!.last.latitude != iatData.latitude ||
          _points[iatData.senderMAC]!.last.longitude != iatData.longitude) {
        if (_calculateMeters(_points[iatData.senderMAC]!.last,
                LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0)) >
            15) {
          _points
              .putIfAbsent(iatData.senderMAC ?? "", () => <LatLng>[])
              .add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
          final Polyline polyline = Polyline(
            polylineId: polylineId,
            consumeTapEvents: true,
            color: AuxFunc().getColor(iatData.senderColor),
            width: 5,
            points: _points[iatData.senderMAC]!,
            // onTap: () {
            //   _onPolylineTapped(polylineId);
            // },
          );
          setState(() {
            polylines[polylineId] = polyline;
          });
          // _points.add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
        }
      }
    } else {
      if (iatData.latitude != 0 && iatData.longitude != 0) {
        _points
            .putIfAbsent(iatData.senderMAC ?? "", () => <LatLng>[])
            .add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
        // _points.add(LatLng(iatData.latitude ?? 0, iatDat  a.longitude ?? 0));
        final Polyline polyline = Polyline(
          polylineId: polylineId,
          consumeTapEvents: true,
          color: AuxFunc().getColor(iatData.senderColor),
          width: 5,
          points: _points[iatData.senderMAC]!,
          // onTap: () {
          //   _onPolylineTapped(polylineId);
          // },
        );
        setState(() {
          polylines[polylineId] = polyline;
        });
      }
    }
  }

  double _calculateMeters(LatLng latLng1, LatLng latLng2) {
    var _r = 6378.137; // Radius of earth in KM
    var dLat =
        latLng2.latitude * math.pi / 180 - latLng1.latitude * math.pi / 180;
    var dLon =
        latLng2.longitude * math.pi / 180 - latLng1.longitude * math.pi / 180;
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latLng1.latitude * math.pi / 180) *
            math.cos(latLng2.latitude * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = _r * c;
    return d * 1000; // meters
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
          initLocation = latlng;
          updateMarkerAndCircle(
              latlng, doc.id, doc['color'], doc['name'], doc['batteryLevel']);
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
          .where('enabled',
              isEqualTo: true) // Get only senders that are enabled
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
            var tempIatData = new IATData(
                senderMAC: firestoreInfo["senderMac"],
                latitude: firestoreInfo['Location']['Latitude'],
                longitude: firestoreInfo['Location']['Longitude'],
                locationTimestamp: firestoreInfo['LocationTimestamp'] != ""
                    ? DateTime.parse(firestoreInfo['LocationTimestamp'])
                        .millisecondsSinceEpoch
                    : 0,
                gatewayMAC: firestoreInfo['gatewayID'],
                trackerBatteryLevel: firestoreInfo['batteryLevel'],
                gatewayBatteryLevel: gwBatteryLevel,
                senderColor: firestoreInfo['color'],
                escaped: firestoreInfo['escaped']);
            // context.read<IATDataModel>().addIatData(tempIatData);
            context.read<IATDataModel>().iatData = tempIatData;
            updateMarkerAndCircle(
                LatLng(tempIatData.latitude!, tempIatData.longitude!),
                'SD-' + tempIatData.senderMAC!,
                tempIatData.senderColor!,
                firestoreInfo['name'],
                tempIatData.trackerBatteryLevel ?? 0);

            _addPolyline(tempIatData);
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

  // Future<Uint8List> getMarker() async {
  //   ByteData byteData =
  //       await DefaultAssetBundle.of(context).load("assets/images/dogpin.png");
  //   return byteData.buffer.asUint8List();
  // }

  Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<String> _getSenderImage(String senderID) async {
    return await DatabaseService(uid: senderID).getSenderPicture();
  }

  void updateMarkerAndCircle(LatLng latlong, String? sender, String senderColor,
      String senderName, int trackerBatteryLevel) async {
    LatLng latlng = LatLng(latlong.latitude, latlong.longitude);
    late Uint8List imageData;
    String pathColor = 'assets/images/' + 'dogpin_' + senderColor + '.png';
    ByteData byteData = await DefaultAssetBundle.of(context).load(pathColor);
    imageData = byteData.buffer.asUint8List();

    _currentPosition = latlong;

    if (markers.length > 0) {
      if (markers.containsKey(sender!)) {
        final Marker resetOld =
            markers[sender]!.copyWith(positionParam: _currentPosition);
        markers[MarkerId(sender)] = resetOld;
      }
      // markers.removeWhere(
      //     (marker) => marker.mapsId.value.toString() == 'SD-' + sender!);
    }
    // if (markers.containsKey('SD-' + sender!)) {
    //   final Marker resetOld = markers[previousMarkerId]!
    //       .copyWith(iconParam: BitmapDescriptor.defaultMarker);
    //   markers[previousMarkerId] = resetOld;
    // }
    // selectedMarker = markerId;
    // final Marker newMarker = tappedMarker.copyWith(
    //   iconParam: BitmapDescriptor.defaultMarkerWithHue(
    //     BitmapDescriptor.hueGreen,
    //   ),
    // );

    // markers[markerId] = newMarker;
    marker = Marker(
        markerId: MarkerId(sender!),
        position: latlng,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuxFunc().getColor(senderColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<String>(
                              future: _getSenderImage(sender),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return CircleAvatar(
                                        child: CircularProgressIndicator(),
                                        backgroundColor:
                                            AuxFunc().getColor(senderColor),
                                        radius: 40);
                                  default:
                                    if (snapshot.hasError ||
                                        snapshot.data == '') {
                                      return CircleAvatar(
                                          child: Icon(
                                            LineAwesomeIcons.paw,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          backgroundColor:
                                              AuxFunc().getColor(senderColor),
                                          radius: 40);
                                    } else {
                                      return CircleAvatar(
                                          backgroundImage:
                                              // AssetImage('assets/images/Bailey1.png'),
                                              NetworkImage(snapshot.data!),
                                          backgroundColor:
                                              AuxFunc().getColor(senderColor),
                                          radius: 40);
                                    }
                                }
                              }),

                          // FittedBox(fit: BoxFit.cover,child: ImageIcon(AssetImage('assets/images/Bailey1.png'), color:  Color(0xFF3A5A98),)),
                          // Icon(
                          //   Icons.account_circle,
                          //   color: Colors.white,
                          //   size: 30,
                          // ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Column(
                            children: [
                              Text(
                                senderName,
                                style: new TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                              Text(
                                "Battery Level: " +
                                    trackerBatteryLevel.toString(),
                                style: new TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                              Text(
                                'Latitude: ' + latlng.latitude.toString(),
                                style: new TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                              Text(
                                'Longitude: ' + latlng.longitude.toString(),
                                style: new TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(
                    color: AuxFunc().getColor(senderColor),
                    height: 10,
                    width: 20,
                  ),
                  // Triangle.isosceles(
                  //   edge: Edge.BOTTOM,
                  //   child: Container(
                  //     color: Colors.blue,
                  //     width: 20.0,
                  //     height: 10.0,
                  //   ),
                ),
              ],
            ),
            latlng,
          );
        },
        // infoWindow: InfoWindow(
        //     title: senderName,
        //     snippet: latlng.latitude.toString() +
        //         ' , ' +
        //         latlng.longitude.toString() +
        //         '\r\n' +
        //         'Battery Level: ' +
        //         trackerBatteryLevel.toString()),
        // rotation: BleSingleton.shared.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData));

    setState(() {
      markers[MarkerId(sender)] = marker;
    });
    // markers.add(marker);
    // return markers.toSet();
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
                          ?
                          // FutureBuilder(
                          //     future: //its sending BLE
                          //         updateMarkerAndCircle(
                          //             LatLng(iatDataProvider.iatData.latitude!,
                          //                 iatDataProvider.iatData.longitude!),
                          //             iatDataProvider.iatData.senderMAC,
                          //             iatDataProvider.iatData
                          //                 .senderColor!), // its sending WIFI
                          //     initialData: Set.of(<Marker>[]),
                          //     builder: (context, snapshotMarker) {
                          Align(
                              child: SafeArea(
                                child: FutureBuilder<Position>(
                                    future: Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.high),
                                    builder: (context, userLocation) {
                                      if (userLocation.hasData) {
                                        return Column(children: <Widget>[
                                          // SizedBox(height:  MediaQuery.of(context).size.height * 0.1, width: MediaQuery.of(context).size.width,),
                                          Expanded(
                                            child: Stack(children: <Widget>[
                                              SizedBox(
                                                // width: MediaQuery.of(context).size.width,
                                                // height: MediaQuery.of(context).size.height * 0.89,
                                                child: GoogleMap(
                                                  mapType: _isSatellite
                                              ? MapType.satellite
                                              : MapType.normal,
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) {
                                                    _controller = controller;
                                                    _customInfoWindowController
                                                            .googleMapController =
                                                        controller;

                                                    moveCamera();
                                                  },
                                                  onTap: (position) {
                                                    _customInfoWindowController
                                                        .hideInfoWindow!();
                                                  },
                                                  onCameraMove: (position) {
                                                    _customInfoWindowController
                                                        .onCameraMove!();
                                                  },
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                          target: initLocation ??
                                                              LatLng(
                                                                  userLocation
                                                                      .data!
                                                                      .latitude,
                                                                  userLocation
                                                                      .data!
                                                                      .longitude),
                                                          zoom: 16.0),
                                                  // initialCameraPosition:
                                                  //     CameraPosition(
                                                  //         target: LatLng(
                                                  //             iatDataProvider
                                                  //                 .iatData.latitude!,
                                                  //             iatDataProvider.iatData
                                                  //                 .longitude!),
                                                  //         zoom: 16.0),
                                                  // markers: markers.toSet(),
                                                  markers: Set<Marker>.of(
                                                      markers.values),
                                                  circles: Set.of(
                                                      (circle != null)
                                                          ? [circle!]
                                                          : []),
                                                  polylines: iatDataProvider
                                                              .iatData
                                                              .escaped ==
                                                          true
                                                      ? Set<Polyline>.of(
                                                          polylines.values)
                                                      : {},
                                                  myLocationButtonEnabled:
                                                      false,
                                                  zoomGesturesEnabled: true,
                                                  mapToolbarEnabled: true,
                                                  myLocationEnabled: false,
                                                  scrollGesturesEnabled: true,
                                                  // initialCameraPosition:
                                                  //     const CameraPosition(
                                                  //         target: LatLng(0.0, 0.0)),
                                                ),
                                              ),
                                              CustomInfoWindow(
                                                controller:
                                                    _customInfoWindowController,
                                                height: 85,
                                                width: 300,
                                                offset: 50,
                                              ),
                                              _toolsList(),
                                            ]),
                                          ),
                                        ]);
                                      } else {
                                        return Loading();
                                      }
                                    }),
                              ),
                              // );
                            )
                          : new Container();
                } else {
                  return Loading();
                }
              });
        }));
  }

  ///Widget tools list
  Widget _toolsList() {
    return Builder(
      builder: (context) {
        return SafeArea(
            child: Stack(children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, right: 20),
              child: InkWell(
                onTap: () {
                  if (_isSatellite) {
                    _isSatellite = false;
                  } else {
                    _isSatellite = true;
                  }
                  DatabaseService(uid: _firebaseAuth.currentUser?.uid)
                      .updateMapTypePreference(_isSatellite);
                  setState(() {});
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: _isSatellite ? Colors.white : Colors.black87,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    _isSatellite ? Icons.map : Icons.satellite,
                    color: _isSatellite ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ),
          )
        ]));
      },
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
