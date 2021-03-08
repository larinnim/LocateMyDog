import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:flutter_maps/Screens/SplashView.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'Screens/Profile/profile.dart';
import 'Screens/ProfileSettings/translationDictionary.dart';
import 'Services/SetWiFiConf.dart';
import 'locator.dart';
import 'Services/bluetooth_conect.dart';
// void main() => runApp(MyApp());

void main() async {
  // void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]); // this forces the app to keep portrait orientation- No Matter What
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BleModel()),
          ChangeNotifierProvider(create: (context) => WiFiModel()),
          ChangeNotifierProvider(create: (context) => ConnectionStatusModel()),
          ChangeNotifierProvider(create: (context) => SocialSignInProvider())
        ],
        child: GetMaterialApp(
            locale: Get.deviceLocale, //read the system locale
            translations: Messages(),
            fallbackLocale: Locale('en',
                'US'), // specify the fallback locale in case an invalid locale is selected.
            debugShowCheckedModeBanner: false,
            title: 'Locate My Pet',
            routes: {
              '/profile': (context) => ProfileScreen(),
              '/trackwalk': (context) => BluetoothConnection(),
              '/blueMap': (context) => MapLocation(),
              '/wifiConf': (context) => SetWiFiConf(),
            },
            theme: ThemeData(
              primaryColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: Material(
              // child: SplashView(),
              child: Wrapper(),
            )));
  }
}
