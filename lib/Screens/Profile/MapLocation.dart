import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../Services/bluetooth_conect.dart';

class MapLocation extends StatefulWidget {
  // final User user;
  // final bool wantsTouchID;
  // final String password;

  // MapLocation({@required this.user, @required this.wantsTouchID, this.password});

  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  StreamSubscription _locationSubscription;
  BleSingleton _locationTracker = BleSingleton();
  // GlobalKey<_BluetoothConnectionState> _myKey = GlobalKey();

  // Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;
  final List<LatLng> points = <LatLng>[];
  final _firestore = FirebaseFirestore.instance;
  // FirebaseStorage firestore = FirebaseStorage.instance;
  Geoflutterfire geo = Geoflutterfire();
  CollectionReference reference =
      FirebaseFirestore.instance.collection('locations');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<LatLng> polyLinesLatLongs = List<LatLng>(); // our list of geopoints
  var mapLocation;

  @override
  void initState() {
    listenNumbers();
    super.initState();
  }

  listenNumbers() async {
    Uint8List imageData = await getMarker();
    // LocationValues _locationData = await _locationTracker.heading;
    // LocationValues _locationValues = await _locationTracker.getLocation();

    // Stream<QuerySnapshot> streamNumbers = _firestore
    _firestore
        .collection('locations')
        .doc(_firebaseAuth.currentUser.uid)
        .collection('User_Locations')
        .where("owner", isEqualTo: "${_firebaseAuth.currentUser.uid}")
        .get()
        .then((querySnapshot) {
      var fireBase = querySnapshot.docs;

      GeoFirePoint point =
          geo.point(latitude: 46.520374, longitude: -80.954211);
      _firestore
          .collection('locations')
          .doc(_firebaseAuth.currentUser.uid)
          .collection('User_Locations')
          .add(
              {'position': point.data, 'owner': _firebaseAuth.currentUser.uid});

      for (var i = 1; i < fireBase.length; i++) {
        GeoPoint point = fireBase[i].data()['position']
            ['geopoint']; //that way to take instance of geopoint

        polyLinesLatLongs.add(LatLng(
            double.parse('${point.latitude}'),
            double.parse(
                '${point.longitude}'))); // now we can add our point to list

        updateMarkerAndCircle(
            LatLng(double.parse('${point.latitude}'),
                double.parse('${point.longitude}')),
            imageData,
            _locationTracker.heading);
        updatePolygon(LatLng(double.parse('${point.latitude}'),
            double.parse('${point.longitude}')));
      }
    });
    // Stream<QuerySnapshot> streamNumbers = _firestore
    //   .collection('locations')
    //   .doc(_firebaseAuth.currentUser.uid)
    //   .collection('User_Locations')
    //   .where("owner", isEqualTo: "${_firebaseAuth.currentUser.uid}")
    //   .snapshots();
    // streamNumbers.listen((snapshot) {
    //   snapshot.docs.forEach((doc) {
    //     MyModel obj = MyModel.fromDocument(doc);
    //     numbersList.add(obj);
    //     setState(() {
    //     });
    //   });
    // });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_controller == null) _controller = controller;
    // mapLocation = context.read<BleModel>();
  }

  static final CameraPosition initialLocation =
      CameraPosition(target: LatLng(46.520374, -80.954211), zoom: 18.00
          // zoom: 14.4746,
          );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/dog.png");
    return byteData.buffer.asUint8List();
  }

  void updatePolygon(LatLng latlong) {
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

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }

  void updateMarkerAndCircle(
      LatLng latlong, Uint8List imageData, double heading) {
    LatLng latlng = LatLng(latlong.latitude, latlong.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      /*
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
          */
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      // Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // var location = await _locationTracker.getLocation();

      // updateMarkerAndCircle(LatLng(location.latitude, location.longitude),
      //         imageData,
      //         location.heading);

      // if (_locationSubscription != null) {
      //   _locationSubscription.cancel();
      // }

      // _locationSubscription =
      //     _locationTracker.onLocationChanged().listen((newLocalData) {
      if (_controller != null) {
        // print('Accuracy ${newLocalData.accuracy}');
        print(
            'Latitude ${Utf8Decoder().convert(context.read<BleModel>().lat)}');
        print(
            'Latitude ${double.parse(Utf8Decoder().convert(context.read<BleModel>().lng))}');

        _controller.animateCamera(CameraUpdate.newCameraPosition(
            new CameraPosition(
                bearing: 192.8334901395799,
                // bearing: 0,
                target: LatLng(
                    double.parse(
                        Utf8Decoder().convert(context.read<BleModel>().lat)),
                    double.parse(
                        Utf8Decoder().convert(context.read<BleModel>().lng))),
                tilt: 0,
                zoom: 18.00)));
        updateMarkerAndCircle(
            LatLng(
                double.parse(
                    Utf8Decoder().convert(context.read<BleModel>().lat)),
                double.parse(
                    Utf8Decoder().convert(context.read<BleModel>().lng))),
            imageData,
            BleSingleton.shared.heading);
        updatePolygon(LatLng(
            double.parse(Utf8Decoder().convert(context.read<BleModel>().lat)),
            double.parse(Utf8Decoder().convert(context.read<BleModel>().lng))));
        polyLinesLatLongs.add(LatLng(
            double.parse(
                '${Utf8Decoder().convert(context.read<BleModel>().lat)}'),
            double.parse(
                '${double.parse(Utf8Decoder().convert(context.read<BleModel>().lng))}')));
        //  GeoFirePoint point =
        // geo.point(latitude: newLocalData.latitude, longitude: newLocalData.longitude);
        // _firestore
        // .collection('locations')
        // .doc(_firebaseAuth.currentUser.uid)
        // .collection('User_Locations')
        // .add({'position': point.data, 'owner': _firebaseAuth.currentUser.uid});
      }
      // });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  // @override
  // void dispose() {
  //   if (_locationSubscription != null) {
  //     _locationSubscription.cancel();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    // final mapVal = context.watch<BleModel>();
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
                return GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                          double.parse(Utf8Decoder().convert(position.lat)),
                          double.parse(Utf8Decoder().convert(position.lng))),
                      zoom: 16.0),
                  markers: Set.of((marker != null) ? [marker] : []),
                  circles: Set.of((circle != null) ? [circle] : []),
                  polylines: Set<Polyline>.of(_mapPolylines.values),
                  myLocationButtonEnabled: false,
                  zoomGesturesEnabled: true,
                  mapToolbarEnabled: true,
                  myLocationEnabled: true,
                  scrollGesturesEnabled: true,
                  onMapCreated: _onMapCreated,
                  // onMapCreated: (GoogleMapController controller) {
                  //   _controller = controller;
                  // },
                );
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
