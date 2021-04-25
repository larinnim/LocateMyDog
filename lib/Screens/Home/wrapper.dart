import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Screens/Tutorial/step1.dart';
import 'package:flutter_maps/Services/database.dart';

import '../loading.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('locateDog');

    if (FirebaseAuth.instance.currentUser == null) {
      print("In Authenticate screen");
      return Authenticate();
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data!.data()!;
            // if (FirebaseAuth.instance.currentUser == null) {
            //   print("In Authenticate screen");
            //   return Authenticate();
            // } else {
            if (data['hasCompletedSetup'] == true) {
              return ProfileScreen();
            } else {
              return Step1();
            }
            // }
          }
          return Loading();
        },
      );
    }

    // if (FirebaseAuth.instance.currentUser == null) {
    //   print("In Authenticate screen");
    //   return Authenticate();
    // } else {
    //   print("In Profile screen");
    // var endDeviceName = "IATS-{$FirestoreSetUp.instance.endDevice}";

    // FirebaseFirestore.instance
    //     .collection('locateDog')
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .get()
    //     .then((data) {
    //   if (data['hasCompletedSetup'] == true) {
    //     return ProfileScreen();
    //   } else {
    //     return Step1();
    //   }
    // }).catchError((e) {
    //   print("Error retrieving from Firebase $e");
    // });

    // collectionQuery = FirebaseFirestore.instance
    //     .collection('locateDog')
    //     .where(FirestoreSetUp.instance.gateway, "array-contains",
    //         {userId: "xyz", userName: "abc"});
    // return Step1();
    // return ProfileScreen();
  }
}
