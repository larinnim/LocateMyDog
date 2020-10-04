import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:location/location.dart';

class MapLocation extends StatefulWidget {
  // final User user;
  // final bool wantsTouchID;
  // final String password;

  // MapLocation({@required this.user, @required this.wantsTouchID, this.password});

  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> with AutomaticKeepAliveClientMixin{
   StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;
  final List<LatLng> points = <LatLng>[];

@override
  bool get wantKeepAlive => true;

  void _onMapCreated(GoogleMapController controller) {
    if( _controller == null )
      _controller = controller;
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(46.520227, -80.954182),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/dog.png");
    return byteData.buffer.asUint8List();
  }

  void updatePolygon(LocationData newLocalData) {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);
    points.add(LatLng(newLocalData.latitude, newLocalData.longitude));

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.red,
      width: 5,
      points: points
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
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
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
          updatePolygon(newLocalData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  // StreamSubscription _locationSubscription;
  // Location _locationTracker = Location();
  // Marker marker;
  // Circle circle;
  // GoogleMapController _controller;

  // static final CameraPosition initialLocation = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );

  // Future<Uint8List> getMarker() async {
  //   ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
  //   return byteData.buffer.asUint8List();
  // }

  // void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
  //   LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
  //   this.setState(() {
  //     marker = Marker(
  //         markerId: MarkerId("home"),
  //         position: latlng,
  //         rotation: newLocalData.heading,
  //         draggable: false,
  //         zIndex: 2,
  //         flat: true,
  //         anchor: Offset(0.5, 0.5),
  //         icon: BitmapDescriptor.fromBytes(imageData));
  //     circle = Circle(
  //         circleId: CircleId("car"),
  //         radius: newLocalData.accuracy,
  //         zIndex: 1,
  //         strokeColor: Colors.blue,
  //         center: latlng,
  //         fillColor: Colors.blue.withAlpha(70));
  //   });
  // }

  // void getCurrentLocation() async {
  //   try {

  //     Uint8List imageData = await getMarker();
  //     var location = await _locationTracker.getLocation();

  //     updateMarkerAndCircle(location, imageData);

  //     if (_locationSubscription != null) {
  //       _locationSubscription.cancel();
  //     }


  //     _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
  //       if (_controller != null) {
  //         _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
  //             bearing: 192.8334901395799,
  //             target: LatLng(newLocalData.latitude, newLocalData.longitude),
  //             tilt: 0,
  //             zoom: 18.00)));
  //         updateMarkerAndCircle(newLocalData, imageData);
  //       }
  //     });

  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       debugPrint("Permission Denied");
  //     }
  //   }
  // }

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
    // return ProfileScreen();
// return Scaffold(
//       appBar: AppBar(
//         title: Text("Google Maps location"),
//       ),
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: initialLocation,
//         markers: Set.of((marker != null) ? [marker] : []),
//         circles: Set.of((circle != null) ? [circle] : []),
//         onMapCreated: (GoogleMapController controller) {
//           _controller = controller;
//         },

//       ),
//       floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.location_searching),
//           onPressed: () {
//             getCurrentLocation();
//           }),
//     );
  return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Where is  ${_firebaseAuth.currentUser.displayName} ?"),
        leading: IconButton(icon:Icon(Icons.arrow_back),
        onPressed: () {
          // Navigate back to the first screen by popping the current route
          // off the stack.
          // Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return ProfileScreen();}));
        }
          // onPressed: () => Navigator.of(context).pop(),
        )
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        polylines: Set<Polyline>.of(_mapPolylines.values),
        onMapCreated: _onMapCreated,
        // onMapCreated: (GoogleMapController controller) {
        //   _controller = controller;
        // },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}
