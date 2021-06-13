import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:flutter_maps/Services/mapProvider.dart';
import 'package:flutter_maps/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:location/location.dart' as localization;
import 'package:polymaker/core/models/trackingmode.dart';

// import 'package:polymaker/core/models/trackingmode.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_platform_interface/src/types/polygon_updates.dart';

import '../loading.dart';

enum GeofenceType { Circle, Polygon }

class Geofence extends StatefulWidget {
  @override
  _GeofenceWidgetState createState() => _GeofenceWidgetState();
}

class _GeofenceWidgetState extends State<Geofence> {
  // ignore: cancel_subscriptions
  StreamSubscription? _locationSubscription;
  localization.Location _locationTracker = localization.Location();
  Circle? _circle;
  Marker? _marker;
  bool _isSatellite = false;
  GoogleMapController? _controller;
  static LatLng? _initialPosition;
  double _configuredRadius = 0.0; //Radius is 30 meters

  // late double _configuredRadius; //Radius is 30 meters
  // late double _configuredRadiusToUnits; //R
  double _configuredRadiusToUnits = 0.0;
  late Uint8List _imageData;
  late localization.LocationData location;
  AppUser? _currentUser = locator.get<UserController>().currentUser;

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  CollectionReference gatewayConfigCollection =
      FirebaseFirestore.instance.collection('gateway-config');

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isPolygonFence = false;
  int _incrementRadius = 5;
  String? _units = 'meter';
  GeofenceType? _geofenceType = GeofenceType.Circle;

  @override
  void initState() {
    _getCurrentLocation();
    _getRadiusAndUnits();
    _getMapType();
    super.initState();
  }

  Future<void> _getMapType() async {
    await gatewayConfigCollection
        .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _geofenceType = doc.data()['Geofence']['FenceType'] == 'Circle'
              ? GeofenceType.Circle
              : GeofenceType.Polygon;
          _isPolygonFence = _geofenceType == GeofenceType.Circle ? false : true;
        });
      });
    });
     await userCollection.doc(_firebaseAuth.currentUser!.uid).get()
        .then((DocumentSnapshot documentSnapshot) {
         _isSatellite =  documentSnapshot.data()!['MapTypeIsSatellite'];
    });
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

    updateMarkerAndCircle(_imageData);

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
      _imageData = await getMarker();

      // var location = await _locationTracker.getLocation();

      // location = await _locationTracker.getLocation();
      updateMarkerAndCircle(_imageData);

      // updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          // _controller!.animateCamera(CameraUpdate.newCameraPosition(
          //     new CameraPosition(
          //         bearing: 192.8334901395799,
          //         target:
          //             LatLng(newLocalData.latitude!, newLocalData.longitude!),
          //         tilt: 0,
          //         zoom: 18.00)));

          // updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void updateMarkerAndCircle(Uint8List imageData) async {
    var loc = await _locationTracker.getLocation();
    LatLng latlng = LatLng(loc.latitude!, loc.longitude!);
    this.setState(() {
      _marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: loc.heading!,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      _circle = Circle(
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
      SizedBox(height: 30),
      ListTile(
        leading: Icon(FontAwesomeIcons.drawPolygon),
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Polygon Geofence"),
                  SizedBox(height: 5),
                ]),
            SizedBox(width: 30),
          ],
        ),
        trailing: Radio<GeofenceType>(
          value: GeofenceType.Polygon,
          groupValue: _geofenceType,
          activeColor: Colors.lightGreen,
          onChanged: (GeofenceType? value) async {
            setState(() {
              _geofenceType = value;
              _isPolygonFence = true;
            });
            mystate(() {
              _geofenceType = value;
              _isPolygonFence = true;
            });
            await gatewayConfigCollection
                .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
                .get()
                .then((QuerySnapshot querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                DatabaseService().updateGeofenceType(
                    doc.id,
                    _geofenceType == GeofenceType.Circle
                        ? 'Circle'
                        : 'Polygon');
              });
            });
          },
        ),
        onTap: () => {
          // mystate(() {
          //   _isPolygonFence = false;
          //   _isDoNotEnterFence = false;
          // }),
          Navigator.of(context).pop()
        },
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
                SizedBox(width: 15),
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
        trailing: Radio<GeofenceType>(
          value: GeofenceType.Circle,
          groupValue: _geofenceType,
          activeColor: Colors.lightGreen,
          onChanged: (GeofenceType? value) async {
            setState(() {
              _geofenceType = value;
              _isPolygonFence = false;
            });
            mystate(() {
              _geofenceType = value;
              _isPolygonFence = false;
            });
            await gatewayConfigCollection
                .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
                .get()
                .then((QuerySnapshot querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                DatabaseService().updateGeofenceType(
                    doc.id,
                    _geofenceType == GeofenceType.Circle
                        ? 'Circle'
                        : 'Polygon');
              });
            });
          },
        ),
        onTap: () => {
          // mystate(() {
          //   _isPolygonFence = false;
          //   _isDoNotEnterFence = false;
          // }),
          Navigator.of(context).pop()
        },
      ),
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

  ///Widget for custom marker
  Widget mapIcon() {
    return Consumer<MapProvider>(
      builder: (context, mapProv, _) {
        return RepaintBoundary(
          key: mapProv.markerKey,
          child: Container(
            width: 32,
            height: 32,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Center(
              child: Text(
                (mapProv.tempLocation.length + 1).toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mapDistance() {
    return Consumer<MapProvider>(
      builder: (context, mapProv, _) {
        return RepaintBoundary(
          key: mapProv.distanceKey,
          child: Container(
            width: mapProv.distance.length > 6
                ? (mapProv.distance.length >= 9 ? 100 : 80)
                : 64,
            height: 32,
            decoration: BoxDecoration(
                color: Colors.black87, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(mapProv.distance,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  ///Widget tools list
  Widget _toolsList() {
    return Builder(
      builder: (context) {
        return Consumer<MapProvider>(
          builder: (context, mapProv, _) {
            return SafeArea(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 30, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            _isPolygonFence == true

                                // mapProv.isEditMode == true
                                ? Row(children: [
                                    mapProv.isEditMode == true
                                        ? InkWell(
                                            onTap: () => mapProv.undoLocation(),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  color: _isSatellite
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Icon(
                                                Icons.undo,
                                                color: _isSatellite
                                                    ? Colors.black87
                                                    : Colors.white,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                        width: mapProv.isEditMode == true
                                            ? 10
                                            : 0),
                                    mapProv.isEditMode == true
                                        ? InkWell(
                                            onTap: () {
                                              mapProv.saveTracking(context);
                                              mapProv.changeEditMode();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  color: _isSatellite
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Icon(
                                                Icons.check,
                                                color: _isSatellite
                                                    ? Colors.black87
                                                    : Colors.white,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                        width: mapProv.isEditMode == true
                                            ? 10
                                            : 0),
                                    InkWell(
                                      onTap: () => mapProv.changeEditMode(),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: _isSatellite
                                                ? Colors.white
                                                : Colors.black87,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Icon(
                                          mapProv.isEditMode == false
                                              ? Icons.edit_location
                                              : Icons.close,
                                          color: _isSatellite
                                              ? Colors.black87
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ])
                                : SizedBox(),
                            InkWell(
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
                                    color: _isSatellite
                                        ? Colors.white
                                        : Colors.black87,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  _isSatellite ? Icons.map : Icons.satellite,
                                  color: _isSatellite
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //To modify status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

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
        body: Consumer2<ConnectionStatusModel, MapProvider>(
            builder: (_, connectionProvider, mapProv, child) {
          // if (mapProv.markers.isEmpty) {
          //   mapProv.initPolygonMarkers();
          // }

          // _initialPosition != null ?
          //     _controller!.animateCamera(CameraUpdate.newCameraPosition(
          //         new CameraPosition(
          //             bearing: 192.8334901395799,
          //             target: LatLng(_initialPosition!.latitude,
          //                _initialPosition!.longitude),
          //             tilt: 0,
          //             zoom: 20.00))) : mapProv.initCamera(false, true, dragMarker: true) ;
//Get first location
          if (mapProv.cameraPosition == null || mapProv.onInitCamera == false) {
            if (mapProv.markers.isEmpty &&
                mapProv.tempLocation.isEmpty &&
                !mapProv.isEditMode) {
              mapProv.initPolygonMarkers();
            }
          }
          if (mapProv.cameraPosition == null && mapProv.onInitCamera == false) {
            // if (widget.targetCameraPosition != null) {
            //   mapProv.initCamera(false, true,
            //       targetCameraPosition: widget.targetCameraPosition,
            //       dragMarker: widget.enableDragMarker);
            // }
            // else {

            // mapProv.initCamera(false, true, dragMarker: true);
            // mapProv.tempLocation.isNotEmpty
            //     ?
            // _controller!.animateCamera(CameraUpdate.newCameraPosition(
            //     new CameraPosition(
            //         bearing: 192.8334901395799,
            //         target: LatLng(mapProv.markers.first.position.latitude,
            //             mapProv.markers.first.position.longitude),
            //         tilt: 0,
            //         zoom: 18.00)))
            //     :

            mapProv.initCamera(false, true, dragMarker: true);

            // }
            mapProv.setPolygonColor(Colors.blue);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
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
                              Positioned(top: -300, child: mapDistance()),
                              Positioned(top: -300, child: mapIcon()),
                              new Container(
                                  height: 1000, // This line solved the issue
                                  child: _isPolygonFence
                                      ? GoogleMap(
                                          mapType: _isSatellite
                                              ? MapType.satellite
                                              : MapType.normal,
                                          initialCameraPosition: CameraPosition(
                                            target: _initialPosition!,
                                            zoom: 20,
                                          ),
                                          zoomGesturesEnabled: true,
                                          myLocationEnabled: true,
                                          compassEnabled: true,
                                          myLocationButtonEnabled: false,
                                          markers: Set.of(
                                              (mapProv.markers != null)
                                                  ? mapProv.markers
                                                  : []),
                                          polygons: mapProv.polygons,
                                          polylines: mapProv.polylines,
                                          onTap: (loc) => mapProv.onTapMap(loc,
                                              mode: TrackingMode.PLANAR),
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller = controller;
                                          },
                                        )
                                      : GoogleMap(
                                          mapType: _isSatellite
                                              ? MapType.satellite
                                              : MapType.normal,
                                          initialCameraPosition: CameraPosition(
                                            target: _initialPosition!,
                                            zoom: 20,
                                          ),
                                          zoomGesturesEnabled: true,
                                          myLocationEnabled: false,
                                          compassEnabled: true,
                                          myLocationButtonEnabled: false,
                                          markers: Set.of((_marker != null)
                                              ? [_marker!]
                                              : []),
                                          circles: Set.of((_circle != null)
                                              ? [_circle!]
                                              : []),
                                          // polygons: _doNotEnterFence,
                                          onTap: (point) {},
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller = controller;
                                          },
                                        )),
                              _toolsList(),
                            ]);
                } else {
                  return Loading();
                }
              });
        }));
  }
}
