import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            ? Consumer<BleModel>(builder: (_, position, child) {
                return FutureBuilder(
                    future: updateMarkerAndCircle(LatLng(
                      position.lat,
                      position.lng)),
                        // double.parse(Utf8Decoder().convert(position.lat)),
                        // double.parse(Utf8Decoder().convert(position.lng)))),
                    initialData: Set.of(<Marker>[]),
                    builder: (context, snapshotMarker) {
                      return FutureBuilder(
                          future: updatePolygon(LatLng(
                            position.lat,
                            position.lng)),
                              // double.parse(Utf8Decoder().convert(position.lat)),
                              // double.parse(
                              //     Utf8Decoder().convert(position.lng)))),
                          initialData: Set.of(<Polyline>[]),
                          builder: (context, snapshotPolyline) {
                            if (snapshotMarker.hasData) {
                              return GoogleMap(
                                mapType: MapType.hybrid,
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                     position.lat,
                                     position.lng),
                                        // double.parse(Utf8Decoder()
                                        //     .convert(position.lat)),
                                        // double.parse(Utf8Decoder()
                                        //     .convert(position.lng))),
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
