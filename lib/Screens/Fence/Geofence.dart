import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:flutter_maps/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as localization;
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../loading.dart';

class Geofence extends StatefulWidget {
  @override
  _GeofenceWidgetState createState() => _GeofenceWidgetState();
}

class _GeofenceWidgetState extends State<Geofence> {
  // ignore: cancel_subscriptions
  StreamSubscription? _locationSubscription;
  localization.Location _locationTracker = localization.Location();
  Circle? circle;
  Marker? marker;
  late Polygon polygon;
  GoogleMapController? _controller;
  static LatLng? _initialPosition;
  late double _configuredRadius; //Radius is 30 meters
  late double _configuredRadiusToUnits; //Radius is 30 meters
  late Uint8List imageData;
  late localization.LocationData location;
  AppUser? _currentUser = locator.get<UserController>().currentUser;

  // CollectionReference locateDogInstance =
  //     FirebaseFirestore.instance.collection('locateDog');

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  CollectionReference gatewayConfigCollection =
      FirebaseFirestore.instance.collection('gateway-config');

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
  String? _units = 'meter';
  // String _connectionStatus = 'Unknown';
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _getCurrentLocation();

    _getRadiusAndUnits();
    // _getInitialLocation();
    // _getCurrentLocation();
    super.initState();
  }

  Future<void> _getRadiusAndUnits() async {
    await userCollection
        .doc(_currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        _units = documentSnapshot['units'];
        if (_units == 'feet') {
          _incrementRadius = (_incrementRadius * 0.621371).round();
        }
        // _configuredRadius = (documentSnapshot.data()!['Geofence']['Circle']
        //         ['radius'])
        //     .toDouble();
        // // _configuredRadiusToUnits = _configuredRadius;
        // if (_configuredRadius.isNegative) {
        //   _configuredRadius = 0.0;
        //   // _updateCurrentRadius();
        //   print('Radius: ' + _configuredRadius.toString());
        // }
        // _updateCurrentRadius();
      });
    });

    await gatewayConfigCollection
        .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _configuredRadius =
              (doc.data()['Geofence']['Circle']['radius']).toDouble();
          // _configuredRadiusToUnits = _configuredRadius;
          if (_configuredRadius.isNegative) {
            _configuredRadius = 0.0;
            // _updateCurrentRadius();
            print('Radius: ' + _configuredRadius.toString());
          }
          _updateCurrentRadius();
        });
      });
    });

    // await userCollection.doc(_currentUser!.uid).get().then((value) {
    //   //  _configuredRadius = value.data()['Geofence'].Circle.radius;
    //   setState(() {
    //     _configuredRadius = value.data()!['Geofence']['Circle']['radius'];
    //     if (_configuredRadius.isNegative) {
    //       _configuredRadius = 0.0;
    //     }
    //     _updateCurrentRadius();
    //     print('Radius: ' + _configuredRadius.toString());
    //   });
    // });
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

    updateMarkerAndCircle(imageData);

    // updateMarkerAndCircle(location, imageData);
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

      // Uint8List imageData = await getMarker();
      imageData = await getMarker();

      // var location = await _locationTracker.getLocation();

      // location = await _locationTracker.getLocation();
      updateMarkerAndCircle(imageData);

      // updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  tilt: 0,
                  zoom: 18.00)));
          // updateMarkerAndCircle(newLocalData, imageData);
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

  // void updateMarkerAndCircle(
  //     localization.LocationData newLocalData, Uint8List imageData) async {
  //
  void updateMarkerAndCircle(Uint8List imageData) async {
    var loc = await _locationTracker.getLocation();
    LatLng latlng = LatLng(loc.latitude!, loc.longitude!);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: loc.heading!,
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
      _locationSubscription!.cancel();
    }
    // _connectivitySubscription.cancel();

    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initConnectivity() async {
  //   ConnectivityResult result = ConnectivityResult.none;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //   } on PlatformException catch (e) {
  //     print(e.toString());
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) {
  //     return Future.value(null);
  //   }

  //   return _updateConnectionStatus(result);
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //  if (result == ConnectivityResult.none) {
  //     Fluttertoast.showToast(
  //         msg: "You are offline. Please connect to an active internet connection.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.TOP,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0
  //     );
  //   }
  // }

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
        backgroundColor: Colors.grey[500],
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
                                          markers: Set.of((marker != null)
                                              ? [marker!]
                                              : []),
                                          circles: Set.of((circle != null)
                                              ? [circle!]
                                              : []),
                                          polygons: _polygonsFence,
                                          //     : _isDoNotEnterFence
                                          //         ? _doNotEnterFence
                                          //         : null,
                                          onTap: (point) {
                                            if (_isPolygonFence) {
                                              setState(() {
                                                polygonFenceLatLngs.add(point);
                                                _setPolygonFence();
                                              });
                                            }
                                            if (_isDoNotEnterFence) {
                                              setState(() {
                                                dotNotEnterFenceLatLngs
                                                    .add(point);
                                                _setDoNotEnterFence();
                                              });
                                            }
                                          },
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller = controller;
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
                                          markers: Set.of((marker != null)
                                              ? [marker!]
                                              : []),
                                          circles: Set.of((circle != null)
                                              ? [circle!]
                                              : []),
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
                                                dotNotEnterFenceLatLngs
                                                    .add(point);
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
                  return Loading();
                }
              });
        }));
  }
}
