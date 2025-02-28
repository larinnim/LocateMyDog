import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

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

  late final CollectionReference gatewayCommandCollection =
      FirebaseFirestore.instance.collection('gateway-command');

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateUserData(String? ownername) async {
    usersCollection.doc(uid).set(
        {'ownername': ownername, 'units': 'feet'}, //default unit is feet
        SetOptions(merge: true));
    // SetOptions(merge: true);
  }

  Future<void> updateDeviceColor(String deviceColor) async {
    await senderCollection.doc(uid).set({
      'color': deviceColor,
    }, SetOptions(merge: true));
  }

  Future<void> setSenderPicture(String url) async {
    await senderCollection.doc(uid).set({
      'pictureUrl': url,
    }, SetOptions(merge: true));
  }

  Future<String> getSenderPicture() async {
    return await senderCollection
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document exists on the database');
        return documentSnapshot.data()!['pictureUrl'];
      } else {
        return "";
      }
    });
  }

  Future<void> sendChangeWiFiCommand(String gatewayMAC) async {
    gatewayCommandCollection.doc('GW-' + gatewayMAC).set(
        {
          'command': 'change_wifi',
          'gatewayMAC': gatewayMAC,
          'changedTimestamp': DateTime.now().millisecondsSinceEpoch
        }, //default unit is feet
        SetOptions(merge: true));
    // SetOptions(merge: true);
  }

  Future<void> updateWiFiSSID(String gatewayID, String wifiSSID) async {
    gatewayCollection.doc(gatewayID).set(
        {'wifiSSID': wifiSSID}, //default unit is feet
        SetOptions(merge: true));
    // SetOptions(merge: true);
  }

  Future<void> updateNotificationPreference(
      bool escaped, bool gatewayBattery, bool trackerBattery) async {
    await usersCollection.doc(uid).set({
      'Notification': {
        'gatewayBattery': {'enabled': gatewayBattery},
        'geofence': {'enabled': escaped},
        'trackerBattery': {'enabled': trackerBattery},
      },
    }, SetOptions(merge: true));
  }

  Future<void> setAgreedToNotBeNotified(bool agreed) async {
    await usersCollection.doc(uid).set({
      'agreedToNotBeNotified': agreed,
    }, SetOptions(merge: true));
  }

  Future<void> updateGeofenceType(String gatewayID, String fenceType) async {
    await gatewayConfigCollection.doc(gatewayID).set({
      'Geofence': {'FenceType': fenceType},
    }, SetOptions(merge: true));
  }

  Future<void> updateMapTypePreference(bool isSatellite) async {
    await usersCollection.doc(uid).set({
      'MapTypeIsSatellite': isSatellite,
    }, SetOptions(merge: true));
  }

  Future<void> addSenderToGateway(String senderMac, String gatewayID) async {
    await gatewayConfigCollection.doc('GW-' + gatewayID).set({
      'senders': FieldValue.arrayUnion([
        {'ID': senderMac}
      ]),
      'userID': uid,
      'Geofence': {
        'Circle': {'initialLat': 0, 'initialLng': 0, 'radius': 30},
        'Polygon': FieldValue.arrayUnion([
          {'ID': senderMac}
        ])
      },
    }, SetOptions(merge: true));
  }

  Future<void> updatePolygonGeofenceConfiguration(
      String gatewayID, List<LatLng> polygonLatLng) async {
    await gatewayConfigCollection.doc(gatewayID).set({
      'Geofence': {'Polygon': FieldValue.delete()},
    }, SetOptions(merge: true)).then((value) {
      polygonLatLng.forEach((element) async {
        await gatewayConfigCollection.doc(gatewayID).set({
          'Geofence': {
            'Polygon': FieldValue.arrayUnion([
              {'lat': element.latitude, 'lng': element.longitude}
            ]),
            'updatedTimestamp': DateTime.now(),
          },
        }, SetOptions(merge: true));
      });
    });
  }

  Future<void> updateCircleRadius(
      double? radius, LatLng initialLocation) async {
    // return
    var getGatewayConfig = await gatewayConfigCollection
        .where('userID', isEqualTo: uid)
        .get(); //Temporary as it's one-to-one UserID Gatewat relationship

    getGatewayConfig.docs.forEach((docCollected) {
      //should return only 1 entry
      gatewayConfigCollection.doc(docCollected.id).set({
        'Geofence': {
          "Circle": {
            "radius": radius,
            "initialLat": initialLocation.latitude,
            "initialLng": initialLocation.longitude,
          }
        },
      }, SetOptions(merge: true));
    });
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
      'batteryLevel': 0,
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

  // Future<void> updateFencePreference(String fencePref) async {
  //   return await gatewayConfigCollection.doc(uid).set({
  //     'Geofence': {"Preference": fencePref},
  //   }, SetOptions(merge: true));
  // }
}

class FirestoreSetUp {
  String gateway = "";
  String? endDevice = "";

  FirestoreSetUp._privateConstructor();

  static final FirestoreSetUp _instance = FirestoreSetUp._privateConstructor();

  static FirestoreSetUp get instance => _instance;
}
