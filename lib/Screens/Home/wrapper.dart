import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Screens/Tutorial/step1.dart';
import 'package:flutter_maps/Services/database.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      print("In Authenticate screen");
      return Authenticate();
    } else {
      print("In Profile screen");
      // var endDeviceName = "IATS-{$FirestoreSetUp.instance.endDevice}";

      // if (FirestoreSetUp.instance.gateway != null) {
      //   var document = FirebaseFirestore.instance
      //       .collection('locateDog')
      //       .doc(FirebaseAuth.instance.currentUser.uid)
      //       .get()
      //       .then((value) {
      //     print("End Device: " +
      //         value.data()[FirestoreSetUp.instance.gateway][endDeviceName]);
      //   }).catchError((e) {
      //     print("Error retrieving from Firebase $e");
      //   });
      // }
      // collectionQuery = FirebaseFirestore.instance
      //     .collection('locateDog')
      //     .where(FirestoreSetUp.instance.gateway, "array-contains",
      //         {userId: "xyz", userName: "abc"});
      return Step1();
      // return ProfileScreen();
    }
  }
}
