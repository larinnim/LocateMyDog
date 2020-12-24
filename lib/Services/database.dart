import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference locateCollection =
      FirebaseFirestore.instance.collection('locateDog');

  Future<void> updateUserData(
      String dogname, String ownername, String breed) async {
    return await locateCollection
        .doc(uid)
        .set({'dogname': dogname, 'ownername': ownername, 'breed': breed},SetOptions(merge: true));
  }

  Future<void> updateCircleRadius(double radius, LatLng initialLocation) async {
    return await locateCollection.doc(uid).set({
      'Geofence': {
        "Circle": 
          {
            "radius": radius,
            "initialLat": initialLocation.latitude,
            "initialLng": initialLocation.longitude,
          }
        
      }, 
    }, SetOptions(merge: true));
  }
}

class FirestoreSetUp {
  String gateway = "";
  String endDevice = "";

  FirestoreSetUp._privateConstructor();

  static final FirestoreSetUp _instance = FirestoreSetUp._privateConstructor();

  static FirestoreSetUp get instance => _instance;
}
