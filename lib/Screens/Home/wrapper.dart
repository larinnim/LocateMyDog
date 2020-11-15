import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/database.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      print("In Authenticate screen");
      return Authenticate();
    } else {
      print("In Profile screen");
      var endDeviceName = "IATS-$FirestoreSetUp.instance.endDevice";
      collectionQuery = FirebaseFirestore.instance
          .collection('locateDog')
          .where(FirestoreSetUp.instance.gateway, "array-contains",
              {userId: "xyz", userName: "abc"});

      return ProfileScreen();
    }
  }
}
