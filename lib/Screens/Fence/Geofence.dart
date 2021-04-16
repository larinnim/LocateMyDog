import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:flutter_maps/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as localization;
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class Geofence extends StatefulWidget {
  @override
  _GeofenceWidgetState createState() => _GeofenceWidgetState();
}

class _GeofenceWidgetState extends State<Geofence> {
  StreamSubscription _locationSubscription;
  localization.Location _locationTracker = localization.Location();
  Circle circle;
  Marker marker;
  Polygon polygon;
  GoogleMapController _controller;
  static LatLng _initialPosition;
  var _configuredRadius = 0.0; //Radius is 30 meters
  AppUser _currentUser = locator.get<UserController>().currentUser;
  CollectionReference locateDogInstance =
      FirebaseFirestore.instance.collection('locateDog');
  CollectionReference userInstance =
      FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isPolygonFence = false;
  bool _isDoNotEnterFence = false;
  Set<Polygon> _polygonsFence = HashSet<Polygon>();
  List<LatLng> polygonFenceLatLngs = [];
  int _polygonFenceIdCounter = 1;
  Set<Polygon> _doNotEnterFence = HashSet<Polygon>();
  List<LatLng> dotNotEnterFenceLatLngs = [];
  int _doNotEnterFenceIdCounter = 1;
  int _incrementRadius = 5;
  String _units = 'kilometer';
  // List<Polygon> polygons = <Polygon>[
  //   new Polygon(
  // polygonId: PolygonId('area'),
  // points: <LatLng>[
  //   new LatLng(46.52098670361095, -80.95421220237156),
  //   new LatLng(46.52101623317156, -80.95524753496112),
  //   new LatLng(46.52058805297215, -80.95529581471918),
  //   new LatLng(46.52024845938013, -80.95401908333933)
  // ],
  // geodesic: true,
  // strokeColor: Colors.blue,
  // fillColor: Colors.lightBlue.withOpacity(0.1),
  //   )
  // ];

  @override
  void initState() {
    super.initState();
    _getRadiusAndUnits();
    // _getInitialLocation();
    _getCurrentLocation();
  }

  Future<void> _getRadiusAndUnits() async {
    await userInstance
     .doc(_currentUser.uid)
    .get()
    .then((DocumentSnapshot documentSnapshot) {
     setState(() {
          _units = documentSnapshot['units'];
          if (_units == 'miles') {
            _incrementRadius = (_incrementRadius * 0.621371).round();
          }
        });
    });
   

    await locateDogInstance.doc(_currentUser.uid).get().then((value) {
      //  _configuredRadius = value.data()['Geofence'].Circle.radius;
      setState(() {
        _configuredRadius = value.data()['Geofence']['Circle']['radius'];
        print('Radius: ' + _configuredRadius.toString());
      });
    });
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

      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  // void _getInitialLocation() async {
  //   Position position = await GeolocatorPlatform.instance
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   _initialPosition = LatLng(position.latitude, position.longitude);
  // }

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
      // geodesic: true,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.redAccent,
    ));
  }

  void updateMarkerAndCircle(
      localization.LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
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

  Column bottonNavigationBuilder(StateSetter mystate) {
    return Column(children: <Widget>[
      SizedBox(height: 50),

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
                          _configuredRadius.toString() +
                          ' ' +
                          _units.tr,
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
                      await DatabaseService(uid: _currentUser.uid)
                          .updateCircleRadius(
                              _configuredRadius, _initialPosition);
                    }),
                SizedBox(width: 50),
                IconButton(
                    icon: Icon(FontAwesomeIcons.minus, size: 20),
                    onPressed: () async {
                      mystate(() {
                        _configuredRadius -=
                            _incrementRadius; //Increase by 5 meters
                      });
                      await DatabaseService(uid: _currentUser.uid)
                          .updateCircleRadius(
                              _configuredRadius, _initialPosition);
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
      // ListTile(
      //   leading: Icon(FontAwesomeIcons.drawPolygon),
      //   title: Text("Polygon Geofence"),
      //   onTap: () => {
      //     mystate(() {
      //       _isPolygonFence = true;
      //       _isDoNotEnterFence = false;
      //     }),
      //     Navigator.of(context).pop()
      //   },
      // ),
      // ListTile(
      //   leading: Icon(Icons.do_disturb_on_outlined),
      //   title: Text("Dot Not Enter Area"),
      //   onTap: () => {
      //     mystate(() {
      //       _isPolygonFence = false;
      //       _isDoNotEnterFence = true;
      //     }),
      //     Navigator.of(context).pop()
      //   },
      // )
    ]);
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus =
        Provider.of<ConnectionStatusModel>(context, listen: false);
    connectionStatus.initConnectionListen();
    return Scaffold(
        appBar: AppBar(
          title: Text("geofence".tr),
          centerTitle: true,
          // backgroundColor: Colors.blueGrey,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              }),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  _onSettingsPressed();
                },
                child: Icon(Icons.settings),
              ),
            )
          ],
        ),
        backgroundColor: Colors.grey[100],
        body: Consumer<ConnectionStatusModel>(
            builder: (_, connectionProvider, child) {
          return FutureBuilder(
              initialData: false,
              future: mounted
                  ? connectionStatus.getCurrentStatus()
                  : Future.value(null),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return connectionProvider.connectionStatus ==
                              NetworkStatus.Offline ||
                          snapshot.data == NetworkStatus.Offline
                      ? CupertinoAlertDialog(
                          title: Text(
                              'You are offline. Please connect to the internet to continue to use this feature'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ProfileScreen();
                                }));
                              },
                            )
                          ],
                        )
                      : _initialPosition == null
                          ? Container(
                              child: Center(
                                child: Text(
                                  'Loading Map...',
                                  style: TextStyle(
                                      fontFamily: 'Avenir-Medium',
                                      color: Colors.grey[400]),
                                ),
                              ),
                            )
                          : new Stack(children: <Widget>[
                              new Container(
                                  height: 1000, // This line solved the issue
                                  child: GoogleMap(
                                    mapType: MapType.hybrid,
                                    initialCameraPosition: CameraPosition(
                                      target: _initialPosition,
                                      zoom: 11,
                                    ),
                                    zoomGesturesEnabled: true,
                                    myLocationEnabled: false,
                                    compassEnabled: true,
                                    myLocationButtonEnabled: false,
                                    markers: Set.of(
                                        (marker != null) ? [marker] : []),
                                    circles: Set.of(
                                        (circle != null) ? [circle] : []),
                                    polygons: _isPolygonFence
                                        ? _polygonsFence
                                        : _isDoNotEnterFence
                                            ? _doNotEnterFence
                                            : null,
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
                                      _controller = controller;
                                    },
                                  )),
                              // connectionProvider.connectionStatus == NetworkStatus.Offline
                              //     ? CupertinoAlertDialog(
                              //         title: Text(
                              //             'You are offline. Please connect to internet to continue to use this feature'),
                              //         actions: [
                              //           CupertinoDialogAction(
                              //             child: Text('OK'),
                              //             onPressed: () {
                              //               Navigator.push(context,
                              //                   MaterialPageRoute(builder: (context) {
                              //                 return ProfileScreen();
                              //               }));
                              //             },
                              //           )
                              //         ],
                              //       )
                              //     : new Container()
                            ]);
                } else {
                  return Container(
                    color: Colors.white,
                    child: SpinKitCircle(
                      color: Colors.red,
                      size: 30.0,
                    ),
                  );
                }
              });
        }));
  }
}
