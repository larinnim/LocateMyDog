import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
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

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => moveCamera());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void moveCamera() {
        _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        tilt: 0,
        zoom: 18.00)));
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_controller == null) _controller = controller;
  }

  // static final CameraPosition initialLocation =
  //     CameraPosition(target: LatLng(46.520374, -80.954211), zoom: 18.00
  //         // zoom: 14.4746,
  //         );

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

  // Future<Set<Polyline>> updatePolygon(LatLng latlong) async {
  //   final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
  //   _polylineIdCounter++;
  //   final PolylineId polylineId = PolylineId(polylineIdVal);
  //   points.add(LatLng(latlong.latitude, latlong.longitude));

  //   final Polyline polyline = Polyline(
  //       polylineId: polylineId,
  //       consumeTapEvents: true,
  //       color: Colors.red,
  //       width: 5,
  //       points: points);

  //   mapPolylines.add(polyline);
  //   return mapPolylines.toSet();
  // }

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
    // _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
    //     bearing: 192.8334901395799,
    //     target: LatLng(latlong.latitude, latlong.longitude),
    //     tilt: 0,
    //     zoom: 18.00)));
    return markers.toSet();
    // marker = Marker(
    //     markerId: MarkerId("home"),
    //     position: latlng,
    //     rotation: BleSingleton.shared.heading,
    //     draggable: false,
    //     zIndex: 2,
    //     flat: true,
    //     anchor: Offset(0.5, 0.5),
    //     icon: BitmapDescriptor.fromBytes(await getMarker()));
    // markers.add(marker);
    // return markers.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final currentPositionBle = Provider.of<BleModel>(context);
    final currentPositionWiFi = Provider.of<WiFiModel>(context);

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text("Map"),
          // title: Text("Where is  ${_firebaseAuth.currentUser.displayName} ?"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Navigate back to the first screen by popping the current route
                // off the stack.
                Navigator.pushNamed(context, '/profile');
              })),
      body: (currentPositionBle.lat != null && currentPositionBle.lng != null ||
              currentPositionWiFi.lat != null &&
                  currentPositionWiFi.lng != null)
          ? Consumer2<BleModel, WiFiModel>(
              builder: (_, bleProvider, wifiProvider, child) {
              //  Consumer<BleModel>(builder: (_, position, child) {
              return FutureBuilder(
                  future: (bleProvider.timestampBLE != null &&
                          wifiProvider.timestampWiFi != null &&
                          bleProvider.timestampBLE
                              .isAfter(wifiProvider.timestampWiFi))
                      ? updateMarkerAndCircle(
                          LatLng(bleProvider.lat, bleProvider.lng))
                      : (bleProvider.timestampBLE == null &&
                              wifiProvider.timestampWiFi != null)
                          ? updateMarkerAndCircle(
                              LatLng(wifiProvider.lat, wifiProvider.lng))
                          : (bleProvider != null && wifiProvider == null)
                              ? updateMarkerAndCircle(
                                  LatLng(bleProvider.lat, bleProvider.lng))
                              : updateMarkerAndCircle(
                                  LatLng(wifiProvider.lat, wifiProvider.lng)),
                  initialData: Set.of(<Marker>[]),
                  builder: (context, snapshotMarker) {
                    // return FutureBuilder(
                    // future:
                    // (bleProvider.timestampBLE != null &&
                    //         wifiProvider.timestampWiFi != null &&
                    //         bleProvider.timestampBLE
                    //             .isAfter(wifiProvider.timestampWiFi))
                    //     ? updatePolygon(
                    //         LatLng(bleProvider.lat, bleProvider.lng))
                    //     : (bleProvider.timestampBLE == null &&
                    //             wifiProvider.timestampWiFi != null)
                    //         ? updatePolygon(
                    //             LatLng(wifiProvider.lat, wifiProvider.lng))
                    //         : (bleProvider != null && wifiProvider == null)
                    //             ? updateMarkerAndCircle(LatLng(
                    //                 bleProvider.lat, bleProvider.lng))
                    //             : updateMarkerAndCircle(LatLng(
                    //                 wifiProvider.lat, wifiProvider.lng));
                    // initialData: Set.of(<Polyline>[]),
                    // builder: (context, snapshotPolyline) {
                    // if (snapshotMarker.hasData) {
                    return GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: (bleProvider.timestampBLE !=
                                  null &&
                              wifiProvider.timestampWiFi != null &&
                              bleProvider.timestampBLE
                                  .isAfter(wifiProvider.timestampWiFi))
                          ? CameraPosition(
                              target: LatLng(bleProvider.lat, bleProvider.lng),
                              zoom: 16.0)
                          : (bleProvider.timestampBLE == null &&
                                  wifiProvider.timestampWiFi != null)
                              ? CameraPosition(
                                  target: LatLng(
                                      wifiProvider.lat, wifiProvider.lng),
                                  zoom: 16.0)
                              : (bleProvider != null && wifiProvider == null)
                                  ? CameraPosition(
                                      target: LatLng(
                                          bleProvider.lat, bleProvider.lng),
                                      zoom: 16.0)
                                  : CameraPosition(
                                      target: LatLng(
                                          bleProvider.lat, bleProvider.lng),
                                      zoom: 16.0),
                      markers: snapshotMarker.data,
                      circles: Set.of((circle != null) ? [circle] : []),
                      // polylines: snapshotPolyline.data,
                      myLocationButtonEnabled: false,
                      zoomGesturesEnabled: true,
                      mapToolbarEnabled: true,
                      myLocationEnabled: true,
                      scrollGesturesEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      },
                    );
                    // } else if (snapshotMarker.hasError ||
                    //     snapshotPolyline.hasError) {
                    //   return Column(children: <Widget>[
                    //     Icon(
                    //       Icons.error_outline,
                    //       color: Colors.red,
                    //       size: 60,
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.only(top: 16),
                    //       child: Text(
                    //           'Error: ${snapshotMarker.error} + ${snapshotPolyline.error}'),
                    //     )
                    //   ]);
                    // } else {
                    //   return Column(children: <Widget>[
                    //     SizedBox(
                    //       child: CircularProgressIndicator(),
                    //       width: 60,
                    //       height: 60,
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 16),
                    //       child: Text('Awaiting result...'),
                    //     )
                    //   ]);
                    // }
                    // });
                  });
            })
          : Center(
              // child:Container(
              // color: Colors.white,

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
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                ),
                Text(
                    'Please connect the gateway to WiFi or Bluetooth to continue'),
                // Expanded(
                //   child: FittedBox(
                //     fit: BoxFit.contain, // otherwise the logo will be tiny
                //     child: const FlutterLogo(),
                //   ),
                // ),
              ],
            )
              //   Text(
              //   "Align Me!",
              //   style: TextStyle(
              //   fontSize: 30.0
              // ),
              // ),
              // ),
              // ),
              ),
      // floatingActionButton: FloatingActionButton(
      //       child: Icon(Icons.location_searching),
      //       onPressed: () {
      //         getCurrentLocation();
      //       });
    );
  }
}
// }
