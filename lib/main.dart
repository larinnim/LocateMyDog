import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:flutter_maps/Screens/SplashView.dart';
import 'package:flutter_maps/Screens/help_support.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Profile/profile.dart';
import 'Screens/ProfileSettings/translationDictionary.dart';
// import 'Services/SetWiFiConf.dart';
import 'locator.dart';
import 'Services/bluetooth_conect.dart';
// void main() => runApp(MyApp());

// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
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
//                     // icon: 'assets/icon/icon_old.png'
//           // TODO add a proper drawable resource to android, for now using
//           //      one that already exists in example app.
//           // icon: message.notification!.android?.smallIcon,
//         ),
//       ));
  // print(message.notification!.title);
  // print(message.notification!.body);
  // flutterLocalNotificationsPlugin.show(
  //     message.notification.hashCode,
  //     message.notification!.title,
  //     message.notification!.body,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channel.description,
  //         // TODO add a proper drawable resource to android, for now using
  //         //      one that already exists in example app.
  //         icon: 'launch_background',
  //       ),
  //     ));
// }

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

void main() async {
  await GetStorage.init(); //get storage initialization

  // void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await Permission.location.request();
  // Set the background messaging handler early on, as a named top-level function
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // /// Update the iOS foreground notification presentation options to allow
  // /// heads up notifications.
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  // Get any messages which caused the application to open from
      // // a terminated state.
      // RemoteMessage? initialMessage =
      //     await FirebaseMessaging.instance.getInitialMessage();
      // // If the message also contains a data property with a "type" of "chat",
      // // navigate to a chat screen
      // if (initialMessage?.data['type'] == 'map') {
      //   Get.off(MapLocation());
      //   // Navigator.pushNamed(context, '/blueMap',
      //   //     arguments: ChatArguments(initialMessage));
      // }

  setupServices();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => BleModel()),
    ChangeNotifierProvider(create: (context) => WiFiModel()),
    ChangeNotifierProvider(create: (context) => ConnectionStatusModel()),
    ChangeNotifierProvider(create: (context) => SocialSignInProvider())
  ], child: MainPage()));
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _getLanguage(); //Get language from Shared Preferences
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

      // if (message.data != null) {
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
      // } else if (message.notification != null) {
      //   print('Message also contained a notification: ${message.notification}');
      //   RemoteNotification notification = message.notification!;
      //   AndroidNotification android = message.notification!.android!;
      //   if (notification != null && android != null) {
      //     flutterLocalNotificationsPlugin.show(
      //         notification.hashCode,
      //         notification.title,
      //         notification.body,
      //         NotificationDetails(
      //           android: AndroidNotificationDetails(
      //             channel.id,
      //             channel.name,
      //             channel.description,
      //             // TODO add a proper drawable resource to android, for now using
      //             //      one that already exists in example app.
      //             icon: 'launch_background',
      //           ),
      //         ));
      //   }
      }
      // Also handle any interaction when the app is in the background via a
    // Stream listener
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   // if (message.data['type'] == 'map') {
    //             Get.off(MapLocation());
    //     // Navigator.pushNamed(context, '/chat',
    //     //   arguments: ChatArguments(message));
    //   // }
    // });
    // });
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Get.deviceLocale, //read the system locale
      translations: Messages(),
      fallbackLocale: Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'IAT',
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/trackwalk': (context) => BluetoothConnection(),
        '/blueMap': (context) => MapLocation(),
        // '/wifiConf': (context) => SetWiFiConf(),
        '/authenticate': (context) => Authenticate(),
        '/helpSupport': (context) => HelpSupport(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Material(
        // child: SplashView(),
        child: Wrapper(),
      ),
    );
  }

  Future<void> _getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final _lang = _prefs.getString('lan');
    final _countryLang = _prefs.getString('countryLang');
    if (_lang != null) {
      setState(() {
        _currentLocale = Locale(_lang, _countryLang);
        Get.updateLocale(_currentLocale);
      });
    }
  }
}
