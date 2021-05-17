import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_maps/Screens/Devices/device_detail.dart';
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
import 'package:flutter_maps/Screens/Devices/gateway_detail.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'database.dart';

// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

class PushNotificationsManager {
  bool _initialized = false;
  RemoteMessage? initialMessage;

  CollectionReference senderCollection =
      FirebaseFirestore.instance.collection('sender');

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  // static final PushNotificationsManager _instance =
  //     PushNotificationsManager._();
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void clear() {
    _initialized = false;
  }

  Future<void> init() async {
    if (!_initialized) {
      final String firebaseTokenPrefKey = 'firebaseToken';
      // Set the background messaging handler early on, as a named top-level function
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      await Permission.notification.request().then((PermissionStatus status) {
        if (status != PermissionStatus.granted) {
          DatabaseService(uid: _firebaseAuth.currentUser!.uid)
              .updateNotificationPreference(false, false, false);
        }
      });
      // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //   DatabaseService(uid: _firebaseAuth.currentUser!.uid)
      //       .updateNotificationPreference(true, true, true);
      // } else if (settings.authorizationStatus ==
      //     AuthorizationStatus.provisional) {
      //   print('User granted provisional permission');
      //   DatabaseService(uid: _firebaseAuth.currentUser!.uid)
      //       .updateNotificationPreference(false, false, false);
      // } else {
      //   print('User declined or has not accepted permission');
      //   DatabaseService(uid: _firebaseAuth.currentUser!.uid)
      //       .updateNotificationPreference(false, false, false);
      // }
      // print('User granted permission: ${settings.authorizationStatus}');

      // For testing purposes print the Firebase Messaging token
      await _firebaseMessaging.getToken().then((token) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(firebaseTokenPrefKey, token!);
        _db
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(), // optional
          'platform': Platform.operatingSystem // optional
        }, SetOptions(merge: true));
        print("FirebaseMessaging token: $token");
      });

      _firebaseMessaging.onTokenRefresh.listen((token) async {
        final prefs = await SharedPreferences.getInstance();
        final String currentToken = prefs.getString(firebaseTokenPrefKey)!;
        if (currentToken != token) {
          print('token refresh: ' + token);
          // add code here to do something with the updated token
          await prefs.setString(firebaseTokenPrefKey, token);

          // if (token != null) {
          _db
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'token': token,
            'createdAt': FieldValue.serverTimestamp(), // optional
            'platform': Platform.operatingSystem // optional
          }, SetOptions(merge: true));
          // }
        }
      });
      // Save it to Firestore

      await FirebaseMessaging.instance
          .getInitialMessage()
          .then((message) async {
// If the message also contains a data property with a "type" of "chat",
        // navigate to a chat screen
        String messageid = await getFcmId(message!.messageId!);
        if (message != null && messageid.isNotEmpty) {
          setFcmId(message.messageId!);
          if (message.data['type'] == 'map') {
            // Get.to(MapLocation());
            Get.offAllNamed('/blueMap');
          } else if (message.data['type'] == 'gatewayBatteryLevel') {
            Get.to(GatewayDetails(
                title: message.data['gatewayName'],
                gatewayMAC: message.data['gatewayMAC']));
          } else if (message.data['type'] == 'trackerBatteryLevel') {
            String gatewayMAC = message.data['gatewayID'];
            await getAvailableColors(
                    AuxFunc().getColor(message.data['senderColor']), gatewayMAC)
                .then((availableColors) {
              Get.to(DeviceDetail(), arguments: [
                message.data['senderMac'],
                message.data['senderColor'],
                message.data['batteryLevel'],
                message.data['senderID'],
                availableColors
              ]);
            });
          }
        }
      });

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        if (message.data['type'] == 'map') {
          // Get.off(MapLocation());
          Get.offAllNamed('/blueMap');
          // Navigator.pushNamed(context, '/chat',
          //   arguments: ChatArguments(message));
        } else if (message.data['type'] == 'gatewayBatteryLevel') {
          Get.to(GatewayDetails(
              title: message.data['gatewayName'],
              gatewayMAC: message.data['gatewayMAC']));
        } else if (message.data['type'] == 'trackerBatteryLevel') {
          String gatewayMAC = message.data['gatewayID'];
          await getAvailableColors(
                  AuxFunc().getColor(message.data['senderColor']), gatewayMAC)
              .then((availableColors) {
            Get.to(
              DeviceDetail(
                title: message.data['senderName'],
                color: AuxFunc().getColor(message.data['senderColor']),
                battery: int.parse(message.data['batteryLevel']),
                senderID: message.data['senderID'],
                availableColors: availableColors,
              ),
            );
          });
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        // setForegroundNotificationPayload(message.data.toString());
        setForegroundNotificationPayload(jsonEncode(message.data));

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
          RemoteNotification notification = message.notification!;
          AndroidNotification android = message.notification!.android!;
          // if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                ),
              ));
        }
      });

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final IOSInitializationSettings initializationSettingsIOS =
          IOSInitializationSettings(
              requestSoundPermission: false,
              requestBadgePermission: false,
              requestAlertPermission: false,
              onDidReceiveLocalNotification:
                  (int id, String? title, String? body, String? payload) async {
                didReceiveLocalNotificationSubject.add(ReceivedNotification(
                    id: id, title: title, body: body, payload: payload));
              });

      final MacOSInitializationSettings initializationSettingsMacOS =
          MacOSInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false);
      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS,
              macOS: initializationSettingsMacOS);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (String? payload) async {
        getForegroundNotificationPayload('foregroundPayload')
            .then((receivedPayload) async {
          NotificationReceivedTrackerDeviceDetails deviceDetails =
              NotificationReceivedTrackerDeviceDetails.fromJsonString(
                  receivedPayload);
          if (deviceDetails.type == 'map') {
            // Get.off(MapLocation());
            Get.offAllNamed('/blueMap');
            // Navigator.pushNamed(context, '/chat',
            //   arguments: ChatArguments(message));
          }else if (deviceDetails.type == 'gatewayBatteryLevel') {
            Get.to(GatewayDetails(
                title: deviceDetails.gatewayName,
                gatewayMAC: deviceDetails.gatewayMAC));
          }  else if (deviceDetails.type == 'trackerBatteryLevel') {
            String gatewayMAC = deviceDetails.gatewayID;
            await getAvailableColors(
                    AuxFunc().getColor(deviceDetails.senderColor), gatewayMAC)
                .then((availableColors) {
              Get.to(
                DeviceDetail(
                  title: deviceDetails.senderName,
                  color: AuxFunc().getColor(deviceDetails.senderColor),
                  battery: int.parse(deviceDetails.batteryLevel),
                  senderID: deviceDetails.senderID,
                  availableColors: availableColors,
                ),
              );
            });
          }
        });
        // Get.offAllNamed('/blueMap');
      });
      _initialized = true;
    }
  }

  static Future<void> setFcmId(String fcmId) async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString(fcmId, fcmId);
  }

  static Future<String> getFcmId(String fcmId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(fcmId) ?? "";
    // return (await SharedPreferences.getInstance()).getString(fcmId) ?? null;
  }

  static Future<void> setForegroundNotificationPayload(
      String foregroundPayload) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('foregroundPayload', foregroundPayload);
    // return (await SharedPreferences.getInstance()).getString(fcmId) ?? null;
  }

  static Future<String> getForegroundNotificationPayload(
      String foregroundPayload) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(foregroundPayload) ?? "";
    // return (await SharedPreferences.getInstance()).getString(fcmId) ?? null;
  }

  Future<List<Color>> getAvailableColors(
      Color trackerColor, String gatewayMAC) async {
    List<Color> _availableColors = [
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red
    ];

    senderCollection
        .where('gatewayID', isEqualTo: gatewayMAC)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Color devColor = trackerColor;
        _availableColors
            .removeWhere((colorAvailable) => devColor == colorAvailable);
      });
    });
    return _availableColors;
  }
}

class NotificationReceivedTrackerDeviceDetails {
  final String type;
  final String gatewayID;
  final String senderColor;
  final String senderName;
  final String batteryLevel;
  final String senderID;
  final String gatewayName;
  final String gatewayMAC;

  NotificationReceivedTrackerDeviceDetails({
    required this.type,
    this.gatewayID = "",
    this.senderColor = "",
    this.senderName = "",
    required this.batteryLevel,
    this.senderID = "",
    this.gatewayMAC = "",
    this.gatewayName = "",
  });

  //Add these methods below

  factory NotificationReceivedTrackerDeviceDetails.fromJsonString(String str) =>
      NotificationReceivedTrackerDeviceDetails._fromJson(jsonDecode(str));

  String toJsonString() => jsonEncode(_toJson());

  factory NotificationReceivedTrackerDeviceDetails._fromJson(
          Map<String, dynamic> json) =>
      NotificationReceivedTrackerDeviceDetails(
        type: json['type'],
        gatewayID: json['gatewayID'] ?? "",
        senderColor: json['senderColor'] ?? "",
        senderName: json['senderName'] ?? "",
        batteryLevel: json['batteryLevel'] ?? "",
        senderID: json['senderID'] ?? "",
        gatewayMAC: json['gatewayMAC'] ?? "",
        gatewayName: json['gatewayName'] ?? "",
      );

  Map<String, dynamic> _toJson() => {
        'type': type,
        'gatewayID': gatewayID,
        'senderColor': senderColor,
        'senderName': senderName,
        'batteryLevel': batteryLevel,
        'senderID': senderID,
        'gatewayMAC': gatewayMAC,
        'gatewayName': gatewayName,
  };
}
