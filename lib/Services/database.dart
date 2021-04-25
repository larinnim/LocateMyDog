import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // collection reference
  final CollectionReference locateCollection =
      FirebaseFirestore.instance.collection('locateDog');

  Future<void> updateUserData(
      String? dogname, String? ownername, String? breed) async {
    _db.collection('users').doc(uid).set(
        {'dogname': dogname, 'ownername': ownername, 'breed': breed},
        SetOptions(merge: true));

    // SetOptions(merge: true);
  }

  Future<void> updateDeviceColor(
      String deviceColor, String senderNumber) async {
    await locateCollection.doc(uid).set({
      senderNumber: {"color": deviceColor},
    }, SetOptions(merge: true));
  }

  Future<void> updateCircleRadius(double? radius, LatLng initialLocation) async {
    return await locateCollection.doc(uid).set({
      'Geofence': {
        "Circle": {
          "radius": radius,
          "initialLat": initialLocation.latitude,
          "initialLng": initialLocation.longitude,
        }
      },
    }, SetOptions(merge: true));
  }

  Future<void> updateGatewayName(String name) async {
    await locateCollection.doc(uid).set({
      'gateway': {"name": name},
    }, SetOptions(merge: true));
  }

  Future<void> updateGatewayID(String id) async {
    await locateCollection.doc(uid).set({
      'gateway': {"id": id},
    }, SetOptions(merge: true));
  }

  Future<void> updateDeviceName(String name, String? senderNumber) async {
    await locateCollection.doc(uid).set({
      senderNumber!: {"name": name},
    }, SetOptions(merge: true));
  }

  Future<void> updateFencePreference(String fencePref) async {
    return await locateCollection.doc(uid).set({
      'Geofence': {"Preference": fencePref},
    }, SetOptions(merge: true));
  }
}

class FirestoreSetUp {
  String gateway = "";
  String? endDevice = "";

  FirestoreSetUp._privateConstructor();

  static final FirestoreSetUp _instance = FirestoreSetUp._privateConstructor();

  static FirestoreSetUp get instance => _instance;
}
