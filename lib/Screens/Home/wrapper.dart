import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return either Home or Authenticate Widget
    return Authenticate();
  }
}
