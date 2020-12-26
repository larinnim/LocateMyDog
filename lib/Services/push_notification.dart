import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      // Save it to Firestore

      if (token != null) {
            _db
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
              'token': token,
              'createdAt': FieldValue.serverTimestamp(), // optional
              'platform': Platform.operatingSystem // optional
            });
        // .collection('tokens')
        // .doc(token);

        // await tokens.set({
        //   'token': token,
        //   'createdAt': FieldValue.serverTimestamp(), // optional
        //   'platform': Platform.operatingSystem // optional
        // });
      }
      _initialized = true;
    }
  }
}