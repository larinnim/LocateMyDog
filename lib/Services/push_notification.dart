import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
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

// print(message.notification!.title);
// print(message.notification!.body);
// print(message.data);

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
// if (message.notification != null) {
//   print('Message also contained a notification: ${message.notification}');
//   RemoteNotification notification = message.notification!;
//   AndroidNotification android = message.notification!.android!;
//   // if (notification != null && android != null) {
//   flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channel.description,
//           // TODO add a proper drawable resource to android, for now using
//           //      one that already exists in example app.
//           icon: 'launch_background',
//         ),
//       ));
//   // }
// }

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
// }

class PushNotificationsManager {
  bool _initialized = false;
  RemoteMessage? initialMessage;
  PushNotificationsManager._();
      bool fromForeground = true;

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
      // display a dialog with the notification details, tap ok to go to another page
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) => CupertinoAlertDialog(
      //     title: Text(title),
      //     content: Text(body),
      //     actions: [
      //       CupertinoDialogAction(
      //         isDefaultAction: true,
      //         child: Text('Ok'),
      //         onPressed: () async {
      //           Navigator.of(context, rootNavigator: true).pop();
      //           await Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => SecondScreen(payload),
      //             ),
      //           );
      //         },
      //       )
      //     ],
      //   ),
      // );

//   /// Note: permissions aren't requested here just to demonstrate that can be
//   /// done later
//   final IOSInitializationSettings initializationSettingsIOS =
//       IOSInitializationSettings(
//           requestAlertPermission: false,
//           requestBadgePermission: false,
//           requestSoundPermission: false,
      // onDidReceiveLocalNotification:
      //     (int id, String? title, String? body, String? payload) async {
      //   didReceiveLocalNotificationSubject.add(ReceivedNotification(
      //       id: id, title: title, body: body, payload: payload));
      // });
//   const MacOSInitializationSettings initializationSettingsMacOS =
//       MacOSInitializationSettings(
//           requestAlertPermission: false,
//           requestBadgePermission: false,
//           requestSoundPermission: false);
      // final InitializationSettings initializationSettings =
      //     InitializationSettings(
      //   android: AndroidInitializationSettings('app_icon'),
      // iOS: initializationSettingsIOS,
      // macOS: initializationSettingsMacOS
      // );

//    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
//           selectedNotificationPayload = notificationAppLaunchDetails!.payload;

//         }

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
      print('User granted permission: ${settings.authorizationStatus}');

      // final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      //     await flutterLocalNotificationsPlugin
      //         .getNotificationAppLaunchDetails();

      // String initialRoute = HomePage.routeName;
      // if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      //   selectedNotificationPayload = notificationAppLaunchDetails!.payload;
      //   initialRoute = SecondPage.routeName;
      // }

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

      // Get any messages which caused the application to open from
      // a terminated state.
      // RemoteMessage? initialMessage =
      // initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      // initialMessage =
      await FirebaseMessaging.instance.getInitialMessage().then((value) {
// If the message also contains a data property with a "type" of "chat",
        // navigate to a chat screen

        if (value?.data['type'] == 'map' && fromForeground == false) {
          fromForeground = false;
          // Get.to(MapLocation());
          Get.offAllNamed('/blueMap');
        }
      });

      // selectNotificationSubject.stream.listen((String? payload) async {
      //   Get.off(MapLocation());
      //   // await Navigator.pushNamed(context, '/secondPage');
      // });

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == 'map') {
          // Get.off(MapLocation());
          Get.offAllNamed('/blueMap');
          // Navigator.pushNamed(context, '/chat',
          //   arguments: ChatArguments(message));
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
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

      // const AndroidInitializationSettings initializationSettingsAndroid =
      //     AndroidInitializationSettings('app_icon');
      // final IOSInitializationSettings initializationSettingsIOS =
      //     IOSInitializationSettings(
      //         requestSoundPermission: false,
      //         requestBadgePermission: false,
      //         requestAlertPermission: false,
      //         onDidReceiveLocalNotification:
      //             (int id, String? title, String? body, String? payload) async {
      //           didReceiveLocalNotificationSubject.add(ReceivedNotification(
      //               id: id, title: title, body: body, payload: payload));
      //         });

      // final MacOSInitializationSettings initializationSettingsMacOS =
      //     MacOSInitializationSettings(
      //         requestAlertPermission: false,
      //         requestBadgePermission: false,
      //         requestSoundPermission: false);
      // final InitializationSettings initializationSettings =
      //     InitializationSettings(
      //         android: initializationSettingsAndroid,
      //         iOS: initializationSettingsIOS,
      //         macOS: initializationSettingsMacOS);

      // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      //     onSelectNotification: (String? payload) async {
      //   fromForeground = true;
      //   Get.offAllNamed('/blueMap');
      // });
      _initialized = true;
    }
    // Future onSelectNotification(String payload) async {
    //   Get.off(MapLocation());
    // }
  }

//   Future<void> initNotifications(
//       FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');

//   /// Note: permissions aren't requested here just to demonstrate that can be
//   /// done later
//   final IOSInitializationSettings initializationSettingsIOS =
//       IOSInitializationSettings(
//           requestAlertPermission: false,
//           requestBadgePermission: false,
//           requestSoundPermission: false,
//           onDidReceiveLocalNotification:
//               (int id, String? title, String? body, String? payload) async {
//             didReceiveLocalNotificationSubject.add(ReceivedNotification(
//                 id: id, title: title, body: body, payload: payload));
//           });
// const MacOSInitializationSettings initializationSettingsMacOS =
//       MacOSInitializationSettings(
//           requestAlertPermission: false,
//           requestBadgePermission: false,
//           requestSoundPermission: false);

// final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//       macOS: initializationSettingsMacOS);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onSelectNotification: (String? payload) async {
//         if (payload != null) {
//           debugPrint('notification payload: $payload');
//         }
//         selectedNotificationPayload = payload;
//         selectNotificationSubject.add(payload);
//       });
}
