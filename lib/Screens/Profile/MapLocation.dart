import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Services/Geofence/geofencing.dart';
import 'package:flutter_maps/Services/Geofence/location.dart';
import 'package:flutter_maps/Services/Geofence/platform_settings.dart';
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
  List<String> registeredGeofences = [];
  double radius = 150.0; // geofence radius
  ReceivePort port = ReceivePort();
  String geofenceState = 'N/A';

  final List<GeofenceEvent> triggers = <GeofenceEvent>[
    GeofenceEvent.enter,
    GeofenceEvent.dwell,
    GeofenceEvent.exit
  ];

  final AndroidGeofencingSettings androidSettings = AndroidGeofencingSettings(
    initialTrigger: <GeofenceEvent>[
      GeofenceEvent.enter,
      GeofenceEvent.exit,
      GeofenceEvent.dwell
    ],
    loiteringDelay: 1000 * 60);

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

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
      port.sendPort, 'geofencing_send_port');
      port.listen((dynamic data) {
      print('Event: $data');
      setState(() {
        geofenceState = data;
      });
    });
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    print('Initializing...');
    await GeofencingManager.initialize();
    print('Initialization done');
  }

  static void callback(List<String> ids, Location l, GeofenceEvent e) async {
    print('Fences: $ids Location $l Event: $e');
    final SendPort send =
    IsolateNameServer.lookupPortByName('geofencing_send_port');
    send?.send(e.toString());
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

  Future<Set<Polyline>> updatePolygon(LatLng latlong) async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);
    points.add(LatLng(latlong.latitude, latlong.longitude));

    final Polyline polyline = Polyline(
        polylineId: polylineId,
        consumeTapEvents: true,
        color: Colors.red,
        width: 5,
        points: points);

    mapPolylines.add(polyline);

    GeofencingManager.registerGeofence(
      GeofenceRegion(
          'mtv', latlong.latitude, latlong.longitude, radius, triggers,
          androidSettings: androidSettings),
      callback).then((_) {
      GeofencingManager.getRegisteredGeofenceIds().then((value) {
        setState(() {
          registeredGeofences = value;
        });
      });
    });

    return mapPolylines.toSet();
  }

  Future<Set<Marker>> updateMarkerAndCircle(LatLng latlong) async {
    LatLng latlng = LatLng(latlong.latitude, latlong.longitude);
    Marker marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        rotation: BleSingleton.shared.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(await getMarker()));
    markers.add(marker);
    return markers.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final currentPosition = Provider.of<BleModel>(context);

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text("Where is  ${_firebaseAuth.currentUser.displayName} ?"),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate back to the first screen by popping the current route
                  // off the stack.
                  Navigator.pushNamed(context, '/trackwalk');
                })),
        body: (currentPosition != null)
            ?
            Consumer2<BleModel, WiFiModel>(builder: (_,bleProvider, wifiProvider , child) {
            //  Consumer<BleModel>(builder: (_, position, child) {
                return FutureBuilder(
                    future:
                   (bleProvider.timestampBLE != null && wifiProvider.timestampWiFi != null && bleProvider.timestampBLE.isAfter(wifiProvider.timestampWiFi))?
                    updateMarkerAndCircle(LatLng(
                      bleProvider.lat,
                      bleProvider.lng)) : (bleProvider.timestampBLE == null && wifiProvider.timestampWiFi != null) ? 
                      updateMarkerAndCircle(LatLng(
                      wifiProvider.lat,
                      wifiProvider.lng)) : (bleProvider != null && wifiProvider == null) ? 
                      updateMarkerAndCircle(LatLng(
                      bleProvider.lat,
                      bleProvider.lng)): updateMarkerAndCircle(LatLng(
                      wifiProvider.lat,
                      wifiProvider.lng)),
                    initialData: Set.of(<Marker>[]),
                    builder: (context, snapshotMarker) {
                      return FutureBuilder(
                      future: 
                   (bleProvider.timestampBLE != null && wifiProvider.timestampWiFi != null && bleProvider.timestampBLE.isAfter(wifiProvider.timestampWiFi))?
                          updatePolygon(LatLng(
                            bleProvider.lat,
                            bleProvider.lng)) : (bleProvider.timestampBLE == null && wifiProvider.timestampWiFi != null) ? 
                            updatePolygon(LatLng(
                            wifiProvider.lat,
                            wifiProvider.lng)) : (bleProvider != null && wifiProvider == null) ?  updateMarkerAndCircle(LatLng(
                            bleProvider.lat,
                            bleProvider.lng)): updateMarkerAndCircle(LatLng(
                            wifiProvider.lat,
                            wifiProvider.lng)),
                          initialData: Set.of(<Polyline>[]),
                          builder: (context, snapshotPolyline) {
                            if (snapshotMarker.hasData) {
                              return GoogleMap(
                                mapType: MapType.hybrid,
                                initialCameraPosition:
                   (bleProvider.timestampBLE != null && wifiProvider.timestampWiFi != null && bleProvider.timestampBLE.isAfter(wifiProvider.timestampWiFi))?
                                CameraPosition(
                                    target: LatLng(
                                     bleProvider.lat,
                                     bleProvider.lng),
                                    zoom: 16.0) : (bleProvider.timestampBLE == null && wifiProvider.timestampWiFi != null) ? 
                                     CameraPosition(
                                    target: LatLng(
                                     wifiProvider.lat,
                                     wifiProvider.lng),
                                    zoom: 16.0) : (bleProvider != null && wifiProvider == null) ?  CameraPosition(
                                    target: LatLng(
                                     bleProvider.lat,
                                     bleProvider.lng),
                                    zoom: 16.0) : CameraPosition(
                                    target: LatLng(
                                     bleProvider.lat,
                                     bleProvider.lng),
                                    zoom: 16.0),
                                markers: snapshotMarker.data,
                                circles:
                                    Set.of((circle != null) ? [circle] : []),
                                polylines: snapshotPolyline.data,
                                myLocationButtonEnabled: false,
                                zoomGesturesEnabled: true,
                                mapToolbarEnabled: true,
                                myLocationEnabled: true,
                                scrollGesturesEnabled: true,
                                onMapCreated: _onMapCreated,
                              );
                            } else if (snapshotMarker.hasError ||
                                snapshotPolyline.hasError) {
                              return Column(children: <Widget>[
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                      'Error: ${snapshotMarker.error} + ${snapshotPolyline.error}'),
                                )
                              ]);
                            } else {
                              return Column(children: <Widget>[
                                SizedBox(
                                  child: CircularProgressIndicator(),
                                  width: 60,
                                  height: 60,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text('Awaiting result...'),
                                )
                              ]);
                            }
                          });
                    });
              })
            : Center(
                child: CircularProgressIndicator(),
              )
        // floatingActionButton: FloatingActionButton(
        //       child: Icon(Icons.location_searching),
        //       onPressed: () {
        //         getCurrentLocation();
        //       });
        );
  }
}
// }
