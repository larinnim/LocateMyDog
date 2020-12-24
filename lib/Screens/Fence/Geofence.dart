import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locator;

class Geofence extends StatefulWidget {
  @override
  _GeofenceWidgetState createState() => _GeofenceWidgetState();
}

class _GeofenceWidgetState extends State<Geofence> {
  StreamSubscription _locationSubscription;
  locator.Location _locationTracker = locator.Location();
  Circle circle;
  Marker marker;
  GoogleMapController _controller;
  static LatLng _initialPosition;
  var configuredRadius = 30.0; //Radius is 30 meters

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getCurrentLocation();
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
                child: bottonNavigationBuilder(),
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

  // void _increaseCircleRadius() {
  //   setState(() {
  //     configuredRadius += 5; //Increase by 5 meters
  //   });
  // }

  void _decreaseCircleRadius() {
    setState(() {
      configuredRadius -= 5;
    });
  }

  void _getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location);

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
          updateMarkerAndCircle(newLocalData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void _getUserLocation() async {
    Position position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);

    // setState(() {
    _initialPosition = LatLng(position.latitude, position.longitude);
    // print('${placemark[0].name}');
    // });
  }

  void updateMarkerAndCircle(locator.LocationData newLocalData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      // marker = Marker(
      //     markerId: MarkerId("home"),
      //     position: latlng,
      //     rotation: newLocalData.heading,
      //     draggable: false,
      //     zIndex: 2,
      //     flat: true,
      //     anchor: Offset(0.5, 0.5));
      circle = Circle(
          circleId: CircleId("pet"),
          radius: configuredRadius,
          // radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.7));
      // fillColor: Colors.blue.withAlpha(70));
    });
  }

  Column bottonNavigationBuilder() {
    return Column(children: <Widget>[
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
                  Text(' Current: ' + configuredRadius.toString() + ' meters',
                      style: TextStyle(color: Colors.black.withOpacity(0.6))),
                ]),
            SizedBox(width: 30),
            Row(
              children: [
                IconButton(
                    icon: Icon(FontAwesomeIcons.plus, size: 20),
                    onPressed: () {
                       setState(() {
                        configuredRadius += 5; //Increase by 5 meters
                      });
                    }),
                SizedBox(width: 50),
                IconButton(
                    icon: Icon(FontAwesomeIcons.minus, size: 20),
                    onPressed: () {
                      setState(() {
                        configuredRadius -= 5; //Increase by 5 meters
                      });                    
                })
              ],
            ),
          ],
        ),
        onTap: () => {},
      ),
      ListTile(
        leading: Icon(FontAwesomeIcons.drawPolygon),
        title: Text("Polygon Geofence"),
        onTap: () => {},
      ),
      ListTile(
        leading: Icon(Icons.do_disturb_on_outlined),
        title: Text("Dot Not Enter Area"),
        onTap: () => {},
      )
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Geofence"),
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
      body: _initialPosition == null
          ? Container(
              child: Center(
                child: Text(
                  'loading map..',
                  style: TextStyle(
                      fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                ),
              ),
            )
          : GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 11,
              ),
              zoomGesturesEnabled: true,
              myLocationEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: false,
              // markers: Set.of((marker != null) ? [marker] : []),
              circles: Set.of((circle != null) ? [circle] : []),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),
    );
  }
}
