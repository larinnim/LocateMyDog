import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Radar extends StatefulWidget {
  @override
  _RadarState createState() => _RadarState();
}

class _RadarState extends State<Radar> with SingleTickerProviderStateMixin {
  Location location = new Location();
  var bearing = 0.0;
  var distance = 0;
  LocationData _location;
  AnimationController _animationController;

  // StreamSubscription<LocationData> _locationSubscription;
  StreamSubscription _locationSubscription;
  String _error;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  @override
  void initState() {
    super.initState();
    requestPermission();
    _listenLocation();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
  }

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged().handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;

        _location = currentLocation;
        if (_location != null) {
          calculateBearing(_location);
          calculateDistance(_location);
        }
      });
    });
  }

  Future<void> _stopListen() async {
    _locationSubscription.cancel();
  }

  Future<void> requestPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.DENIED ||
        _permissionGranted == PermissionStatus.DENIED_FOREVER) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    } else {
      _listenLocation();
    }
  }

  void calculateBearing(LocationData locationData) {
    var dL = BleSingleton.shared.lng - locationData.longitude;
    var x = cos(BleSingleton.shared.lat) * sin(dL);
    var y = cos(locationData.latitude) * sin(BleSingleton.shared.lat) -
        sin(locationData.latitude) * cos(BleSingleton.shared.lat) * cos(dL);
    bearing = atan2(x, y);
  }

  void calculateDistance(LocationData locationData) {
    var ky = 40000 / 360;
    var kx = cos(pi * locationData.latitude / 180.0) * ky;
    var dx = ((locationData.longitude - BleSingleton.shared.lng) * kx).abs();
    var dy = ((locationData.latitude - BleSingleton.shared.lat) * ky).abs();
    distance = (sqrt(dx * dx + dy * dy) * 1000).round(); // in m
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              }),
        ),
        body:
            // Image.asset("assets/images/direction_arrow.png", height: 30),
            BleSingleton.shared.connectedDevices.length > 0
                ? StreamBuilder<BluetoothDeviceState>(
                    stream: BleSingleton.shared.connectedDevices[0].state,
                    initialData: BluetoothDeviceState.connecting,
                    builder: (c, snapshot) {
                      switch (snapshot.data) {
                        case BluetoothDeviceState.connected:
                          return Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  // mainAxisAlignment:
                                  // MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (_, child) {
                                        return Transform.rotate(
                                          // angle: _animationController.value * 2 * pi,
                                          angle: bearing,
                                          child: child,
                                        );
                                      },
                                      child: Image.asset(
                                          "assets/images/direction_arrow.png"),
                                    ),
                                    // Image.asset("assets/images/direction_arrow.png"),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 40.0),
                                      child: Text(
                                        'Meters: ' + distance.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Roboto',
                                          letterSpacing: 0.5,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                          break;
                        case BluetoothDeviceState.disconnected:
                          return Center(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                Text("Please Connect to Bluetooth")
                              ]));
                          break;
                      }
                    })
                : Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                        Icon(FontAwesomeIcons.exclamationTriangle),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                        ),
                        Text(
                          'Whoops',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15.0),
                        ),
                        Text('You are offline. Please connect to Bluetooth to continue',
                            style: TextStyle(fontSize: 20.0)),
                      ])));
  }
}
