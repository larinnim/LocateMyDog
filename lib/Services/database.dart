import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // collection reference
  final CollectionReference locateCollection =
      FirebaseFirestore.instance.collection('locateDog');

  final CollectionReference senderCollection =
      FirebaseFirestore.instance.collection('sender');

  final CollectionReference gatewayCollection =
      FirebaseFirestore.instance.collection('gateway');

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  late final CollectionReference gatewayConfigCollection =
      FirebaseFirestore.instance.collection('gateway-config');

  late final CollectionReference pendingDevicesCollection =
      FirebaseFirestore.instance.collection('pendingDevices');

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateUserData(
      String? dogname, String? ownername, String? breed) async {
    usersCollection.doc(uid).set({
      'Geofence': {
        'Circle': {'initialLat': 0, 'initialLng': 0, 'radius': 30}
      }
    }, SetOptions(merge: true));
    _db.collection('users').doc(uid).set(
        {
          'dogname': dogname,
          'ownername': ownername,
          'breed': breed,
          'units': 'feet'
        }, //default unit is feet
        SetOptions(merge: true));
    // SetOptions(merge: true);
  }

  Future<void> updateDeviceColor(String deviceColor) async {
    await senderCollection.doc(uid).set({
      'color': deviceColor,
    }, SetOptions(merge: true));
  }

  Future<void> addSenderToGateway(String senderMac, String gatewayID) async {
    await gatewayConfigCollection.doc(gatewayID).set({
      'senders': FieldValue.arrayUnion([senderMac]),
      'userID': uid
    }, SetOptions(merge: true));
  }

  Future<void> updateCircleRadius(
      double? radius, LatLng initialLocation) async {
    return await usersCollection.doc(uid).set({
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
    await gatewayCollection.doc(uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  Future<void> completedSetup(bool completed) async {
    await usersCollection.doc(uid).set({
      'hasCompletedSetup': completed,
    }, SetOptions(merge: true));
  }

  Future<void> createGateway(String gatewayMAC) async {
    await gatewayCollection.doc('GW-' + gatewayMAC).set({
      'name': "Gateway - IAT - " + gatewayMAC,
      'userID': _firebaseAuth.currentUser!.uid,
      'version': '1.0',
      'gatewayMAC': gatewayMAC
    }, SetOptions(merge: true)).then((value) => null);
    var isItPending =
        await pendingDevicesCollection.doc('GW-' + gatewayMAC).get();
    if (isItPending.exists) {
      await pendingDevicesCollection.doc('GW-' + gatewayMAC).delete();
    }
  }

  Future<void> updateDeviceName(String name) async {
    await senderCollection.doc(uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  Future<void> updateFencePreference(String fencePref) async {
    return await usersCollection.doc(uid).set({
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
