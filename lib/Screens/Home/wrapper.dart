import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      print("In Authenticate screen");
      return Authenticate();
    } else {
      print("In Profile screen");
      return ProfileScreen();
    }
  }
}
