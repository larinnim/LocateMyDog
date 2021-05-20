import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_maps/locator.dart';
import 'package:location/location.dart' as localization;

import '../loading.dart';

class Step5 extends StatefulWidget {
  @override
  _Step5State createState() => _Step5State();
}

class _Step5State extends State<Step5> {
  Completer<GoogleMapController> _controller = Completer();
  double _configuredRadius = 10.0; //Radius is 30 meters
  double _configuredRadiusToUnits = 0.0; //Radius is 30 meters
  String? _units = 'meter';
  bool _unitsMeterOn = true; //on in cupertino is feet
  int _incrementRadius = 5;
  AppUser? _currentUser = locator.get<UserController>().currentUser;
  static LatLng? _initialPosition;
  bool _isDoNotEnterFence = false;
  bool _isPolygonFence = false;
  late Uint8List imageData;
  late localization.LocationData location;
  Circle? circle;
  Marker? marker;
  Set<Polygon> _polygonsFence = HashSet<Polygon>();
  List<LatLng> dotNotEnterFenceLatLngs = [];
  List<LatLng> polygonFenceLatLngs = [];
  Set<Polygon> _doNotEnterFence = HashSet<Polygon>();
  int _doNotEnterFenceIdCounter = 1;
  int _polygonFenceIdCounter = 1;
  CollectionReference userInstance =
      FirebaseFirestore.instance.collection('users');
  localization.Location _locationTracker = localization.Location();
  // ignore: cancel_subscriptions
  StreamSubscription? _locationSubscription;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getRadiusAndUnits();
    _getCurrentLocation();
  }

  Future<void> _getRadiusAndUnits() async {
    await userInstance
        .doc(_currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        _units = documentSnapshot['units'];
        if (_units == 'feet') {
          _unitsMeterOn = true;
          _incrementRadius = (_incrementRadius * 0.621371).round();
        } else {
          _unitsMeterOn = false;
        }
      });
      _updateCurrentRadius();
    });
  }

  void completedSetup(bool completed) async {
    await DatabaseService(uid: _firebaseAuth.currentUser!.uid)
        .completedSetup(completed)
        .then((value) => Get.off(() => Wrapper()));
  }

  void _updateUnits(String? unitsChoose) {
    _db
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .set({'units': _units}, SetOptions(merge: true));
  }

  void _onSettingsPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter mystate /*You can rename this!*/) {
            return Container(
              color: Color(0xFF737373), // It's full transparency
              height: 180,
              child: Container(
                child: bottonNavigationBuilder(mystate),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                    )),
              ),
            );
          });
        });
  }

  Column bottonNavigationBuilder(StateSetter mystate) {
    return Column(children: <Widget>[
      SizedBox(height: 50),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'meter',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                trackColor: Colors.lightGreen,
                activeColor: Colors.red[300],
                value: _unitsMeterOn,
                onChanged: (bool val) {
                  mystate(() {
                    _unitsMeterOn = val;
                    if (_unitsMeterOn == false) {
                      _units = "meter";
                    } else {
                      _units = "feet";
                    }
                  });
                  _updateUnits(_units);
                  _updateCurrentRadius();
                },
              )),
          Text(
            'feet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
        ],
      ),
      ListTile(
        leading: Icon(Icons.adjust_rounded),
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Rounded Geofence"),
                  SizedBox(height: 5),
                  Text(
                      'current'.tr +
                          ': ' +
                          _configuredRadiusToUnits.toStringAsFixed(2) +
                          // _configuredRadius.toString() +
                          ' ' +
                          _units!.tr,
                      style: TextStyle(color: Colors.black.withOpacity(0.6))),
                ]),
            SizedBox(width: 30),
            Row(
              children: [
                IconButton(
                    icon: Icon(FontAwesomeIcons.plus, size: 20),
                    onPressed: () async {
                      mystate(() {
                        _configuredRadius +=
                            _incrementRadius; //Increase by 5 meters
                      });
                      _updateCurrentRadius();
                      await DatabaseService(uid: _currentUser!.uid)
                          .updateCircleRadius(
                              _configuredRadius, _initialPosition!);
                    }),
                SizedBox(width: 50),
                IconButton(
                    icon: Icon(FontAwesomeIcons.minus, size: 20),
                    onPressed: () async {
                      mystate(() {
                        if (_configuredRadius > 0.0) {
                          _configuredRadius -=
                              _incrementRadius; //Increase by 5 meters
                        } else {
                          _configuredRadius = 0.0;
                        }
                      });
                      _updateCurrentRadius();
                      await DatabaseService(uid: _currentUser!.uid)
                          .updateCircleRadius(
                              _configuredRadius, _initialPosition!);
                    }),
                // })
              ],
            ),
          ],
        ),
        onTap: () => {
          mystate(() {
            _isPolygonFence = false;
            _isDoNotEnterFence = false;
          }),
          Navigator.of(context).pop()
        },
      ),
    ]);
  }

  void _updateCurrentRadius() {
    setState(() {
      if (_configuredRadius != 0.0) {
        if (_units == 'meter') {
          _configuredRadiusToUnits = _configuredRadius;
        } else if (_units == 'feet') {
          _configuredRadiusToUnits = _configuredRadius * 3.28084;
        }
      } else {
        _configuredRadius = 5; //minimum is 5 meters
        if (_units == 'meter') {
          _configuredRadiusToUnits = 5;
        } else if (_units == 'feet') {
          _configuredRadiusToUnits = _configuredRadius * 3.28084;
        }
      }
    });
    updateMarkerAndCircle(location, imageData);
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/images/round_marker.png");
    return byteData.buffer.asUint8List();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await GeolocatorPlatform.instance
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _initialPosition = LatLng(position.latitude, position.longitude);

      // Uint8List imageData = await getMarker();
      imageData = await getMarker();

      // var location = await _locationTracker.getLocation();

      location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) async {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
            new CameraPosition(
                bearing: 192.8334901395799,
                target: LatLng(newLocalData.latitude!, newLocalData.longitude!),
                tilt: 0,
                zoom: 18.00)));
        // updateMarkerAndCircle(newLocalData, imageData);
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void updateMarkerAndCircle(
      localization.LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading!,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("pet"),
          radius: _configuredRadius,
          // radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.7));
      // fillColor: Colors.blue.withAlpha(70));
    });
  }

  void _setPolygonFence() {
    final String polygonVal = 'polygon_id_$_polygonFenceIdCounter';
    _polygonsFence.add(Polygon(
      polygonId: PolygonId(polygonVal),
      points: polygonFenceLatLngs,
      // geodesic: true,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.lightBlue,
    ));
  }

  void _setDoNotEnterFence() {
    final String doNotEnterVal = 'doNotEnter_id_$_doNotEnterFenceIdCounter';
    _doNotEnterFence.add(Polygon(
      polygonId: PolygonId(doNotEnterVal),
      points: dotNotEnterFenceLatLngs,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Material(
            type: MaterialType.transparency,
            child: new Container(
              decoration: BoxDecoration(color: Colors.white),
              child: SafeArea(
                  child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                child: Column(children: <Widget>[
                  Row(
                    children: [
                      Text(
                        'Step 5 of 5',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
                            fontFamily: 'RobotoMono'),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configure the Geofence',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30.0,
                            fontFamily: 'RobotoMono'),
                      ),
                      ElevatedButton(
                        onPressed: () => _onSettingsPressed(),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[Icon(Icons.settings)],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  _initialPosition == null
                      ? Loading()
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width,
                          child: _isPolygonFence
                              ? GoogleMap(
                                  mapType: MapType.hybrid,
                                  initialCameraPosition: CameraPosition(
                                    target: _initialPosition!,
                                    zoom: 11,
                                  ),
                                  zoomGesturesEnabled: true,
                                  myLocationEnabled: false,
                                  compassEnabled: true,
                                  myLocationButtonEnabled: false,
                                  markers: Set.of(
                                      (marker != null) ? [marker!] : []),
                                  circles: Set.of(
                                      (circle != null) ? [circle!] : []),
                                  polygons: _polygonsFence,
                                  onTap: (point) {
                                    if (_isPolygonFence) {
                                      setState(() {
                                        polygonFenceLatLngs.add(point);
                                        _setPolygonFence();
                                      });
                                    }
                                    if (_isDoNotEnterFence) {
                                      setState(() {
                                        dotNotEnterFenceLatLngs.add(point);
                                        _setDoNotEnterFence();
                                      });
                                    }
                                  },
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    // _controller = _controller;
                                    _controller.complete(controller);
                                  },
                                )
                              : GoogleMap(
                                  mapType: MapType.hybrid,
                                  initialCameraPosition: CameraPosition(
                                    target: _initialPosition!,
                                    zoom: 11,
                                  ),
                                  zoomGesturesEnabled: true,
                                  myLocationEnabled: false,
                                  compassEnabled: true,
                                  myLocationButtonEnabled: false,
                                  markers: Set.of(
                                      (marker != null) ? [marker!] : []),
                                  circles: Set.of(
                                      (circle != null) ? [circle!] : []),
                                  polygons: _doNotEnterFence,
                                  onTap: (point) {
                                    if (_isPolygonFence) {
                                      setState(() {
                                        polygonFenceLatLngs.add(point);
                                        _setPolygonFence();
                                      });
                                    }
                                    if (_isDoNotEnterFence) {
                                      setState(() {
                                        dotNotEnterFenceLatLngs.add(point);
                                        _setDoNotEnterFence();
                                      });
                                    }
                                  },
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                    // _controller = _controller;
                                  },
                                )),
                  SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      completedSetup(true);
                    },
                  ),
                ]),
              )),
            )),
      ),
    );
  }
}
