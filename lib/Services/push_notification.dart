import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  // print(message.notification!.title);
  // print(message.notification!.body);
  print(message.data);

  // if (message.data != null && message.notification == null) {
  //   flutterLocalNotificationsPlugin.show(
  //       message.data.hashCode,
  //       message.data['title'],
  //       message.data['body'],
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           channel.id,
  //           channel.name,
  //           channel.description,
  //           icon: 'launch_background',
  //           // TODO add a proper drawable resource to android, for now using
  //           //      one that already exists in example app.
  //           // icon: message.notification!.android?.smallIcon,
  //         ),
  //       ));
  // } else
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
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
    // }
  }
  // flutterLocalNotificationsPlugin.show(
  //     message.data.hashCode,
  //     message.data['title'],
  //     message.data['body'],
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channel.description,
  //         icon: 'launch_background',
  //         // TODO add a proper drawable resource to android, for now using
  //         //      one that already exists in example app.
  //         // icon: message.notification!.android?.smallIcon,
  //       ),
  //     ));
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

class PushNotificationsManager {
  bool _initialized = false;

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  // static final PushNotificationsManager _instance =
  //     PushNotificationsManager._();
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void clear() {
    _initialized = false;
  }

  Future<void> init() async {
    if (!_initialized) {
      final String firebaseTokenPrefKey = 'firebaseToken';

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
      print('User granted permission: ${settings.authorizationStatus}');

      // For iOS request permission first.
      // _firebaseMessaging.requestNotificationPermissions();

      // _firebaseMessaging.configure();

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

      // if (token != null) {
      //   _db
      //       .collection('users')
      //       .doc(FirebaseAuth.instance.currentUser!.uid)
      //       .set({
      //     'token': token,
      //     'createdAt': FieldValue.serverTimestamp(), // optional
      //     'platform': Platform.operatingSystem // optional
      //   }, SetOptions(merge: true));
      // }
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

      // Get any messages which caused the application to open from
      // a terminated state.
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      // If the message also contains a data property with a "type" of "chat",
      // navigate to a chat screen
      if (initialMessage?.data['type'] == 'map') {
        Get.off(MapLocation());
        // Navigator.pushNamed(context, '/blueMap',
        //     arguments: ChatArguments(initialMessage));
      }

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == 'map') {
          Get.off(MapLocation());
          // Navigator.pushNamed(context, '/chat',
          //   arguments: ChatArguments(message));
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        // if (message.data != null && message.notification == null) {
        //   flutterLocalNotificationsPlugin.show(
        //       message.data.hashCode,
        //       message.data['title'],
        //       message.data['body'],
        //       NotificationDetails(
        //         android: AndroidNotificationDetails(
        //           channel.id,
        //           channel.name,
        //           channel.description,
        //           icon: 'launch_background',
        //           // TODO add a proper drawable resource to android, for now using
        //           //      one that already exists in example app.
        //           // icon: message.notification!.android?.smallIcon,
        //         ),
        //       ));
        // } else
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
          // }
        }
      });
      _initialized = true;
    }
  }
}
