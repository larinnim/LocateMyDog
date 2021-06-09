import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class PinData{
  String pinPath;
  String avatarPath;
  LatLng location;
  String locationName;
  Color labelColor;

  PinData({required this.pinPath, required this.avatarPath, required this.location, required this.locationName,
      required this.labelColor});


}