import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/Radar.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../Services/bluetooth_conect.dart';

class MapLocation extends StatefulWidget {
  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  List<Marker> markers = <Marker>[];
  List<Polyline> mapPolylines = <Polyline>[];
  LatLng _currentPosition;
  Circle circle;
  GoogleMapController _controller;
  // Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;
  final List<LatLng> points = <LatLng>[];
  // FirebaseStorage firestore = FirebaseStorage.instance;
  Geoflutterfire geo = Geoflutterfire();
  CollectionReference reference =
      FirebaseFirestore.instance.collection('locations');
  List<LatLng> polyLinesLatLongs = List<LatLng>(); // our list of geopoints
  var mapLocation;
  Uint8List imageData;
  // BitmapDescriptor icon;
  Marker marker;
  int _markerId = 1;
  Timer timer;
  final List<Flushbar> flushBars = [];

  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(Duration(seconds: 3), (Timer t) => moveCamera());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> moveCamera() async {
    if (_currentPosition.latitude != null &&
        _currentPosition.longitude != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 192.8334901395799,
              target:
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
              tilt: 0,
              zoom: 18.00)));
    }
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   if (_controller == null) _controller = controller;
  //   moveCamera();
  // }

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

  Future<Set<Marker>> updateMarkerAndCircle(LatLng latlong) async {
    LatLng latlng = LatLng(latlong.latitude, latlong.longitude);
    Uint8List imageData = await getMarker();
    _currentPosition = latlong;

    if (markers.length > 0) {
      Marker marker = markers[0];

      setState(() {
        markers[0] = marker.copyWith(
            positionParam: LatLng(latlong.latitude, latlong.longitude));
      });
    } else {
      setState(() {
        marker = Marker(
            markerId: MarkerId("home"),
            position: latlng,
            rotation: BleSingleton.shared.heading,
            draggable: false,
            zIndex: 2,
            flat: true,
            anchor: Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(imageData));

        markers.add(marker);
      });
    }
    return markers.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final currentPositionBle = Provider.of<BleModel>(context, listen: false);
    final currentPositionWiFi = Provider.of<WiFiModel>(context, listen: false);
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
                  Navigator.pushNamed(context, '/profile');
                })),
        body: (currentPositionBle.lat != null &&
                    currentPositionBle.lng != null ||
                currentPositionWiFi.lat != null &&
                    currentPositionWiFi.lng != null)
            ? Consumer3<BleModel, WiFiModel, ConnectionStatusModel>(builder:
                (_, bleProvider, wifiProvider, connectionProvider, child) {
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
                                        return Radar();
                                      }));
                                    },
                                  )
                                ],
                              )
                            : FutureBuilder(
                                future: (bleProvider.timestampBLE != null &&
                                        wifiProvider.timestampWiFi != null &&
                                        bleProvider.timestampBLE.isAfter(
                                            wifiProvider.timestampWiFi))
                                    ? updateMarkerAndCircle(LatLng(
                                        bleProvider.lat, bleProvider.lng))
                                    : (bleProvider.timestampBLE == null &&
                                            wifiProvider.timestampWiFi != null)
                                        ? updateMarkerAndCircle(LatLng(
                                            wifiProvider.lat, wifiProvider.lng))
                                        : (bleProvider != null &&
                                                wifiProvider == null)
                                            ? updateMarkerAndCircle(LatLng(
                                                bleProvider.lat,
                                                bleProvider.lng))
                                            : updateMarkerAndCircle(LatLng(
                                                wifiProvider.lat,
                                                wifiProvider.lng)),
                                initialData: Set.of(<Marker>[]),
                                builder: (context, snapshotMarker) {
                                  return new Stack(
                                    children: <Widget>[
                                      new Container(
                                        height:
                                            1000, // This line solved the issue
                                        child: GoogleMap(
                                          mapType: MapType.hybrid,
                                          initialCameraPosition: (bleProvider.timestampBLE != null &&
                                                  wifiProvider.timestampWiFi !=
                                                      null &&
                                                  bleProvider.timestampBLE
                                                      .isAfter(wifiProvider
                                                          .timestampWiFi))
                                              ? CameraPosition(
                                                  target: LatLng(
                                                      bleProvider.lat,
                                                      bleProvider.lng),
                                                  zoom: 16.0)
                                              : (bleProvider.timestampBLE == null &&
                                                      wifiProvider.timestampWiFi !=
                                                          null)
                                                  ? CameraPosition(
                                                      target: LatLng(
                                                          wifiProvider.lat,
                                                          wifiProvider.lng),
                                                      zoom: 16.0)
                                                  : (bleProvider != null &&
                                                          wifiProvider == null)
                                                      ? CameraPosition(
                                                          target: LatLng(
                                                              bleProvider.lat,
                                                              bleProvider.lng),
                                                          zoom: 16.0)
                                                      : CameraPosition(
                                                          target: LatLng(bleProvider.lat, bleProvider.lng),
                                                          zoom: 16.0),
                                          markers: snapshotMarker.data,
                                          circles: Set.of(
                                              (circle != null) ? [circle] : []),
                                          // polylines: snapshotPolyline.data,
                                          myLocationButtonEnabled: false,
                                          zoomGesturesEnabled: true,
                                          mapToolbarEnabled: true,
                                          myLocationEnabled: true,
                                          scrollGesturesEnabled: true,
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller = controller;
                                            moveCamera();
                                          },
                                        ), // Mapbox
                                      ),
                                      connectionProvider.connectionStatus ==
                                              NetworkStatus.Offline
                                          ? CupertinoAlertDialog(
                                              title: Text(
                                                  'You are offline. You are going to be redirected to Offline mode'),
                                              actions: [
                                                CupertinoDialogAction(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return Radar();
                                                    }));
                                                  },
                                                )
                                              ],
                                            )
                                          : new Container()
                                    ],
                                  );
                                });
                      }
                    });
              })
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.exclamationTriangle),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  Text(
                    'Whoops',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                  ),
                  Text(
                      'You are offline. Please connect the gateway to WiFi or Bluetooth to continue'),
                ],
              ))
              );
  }
}
