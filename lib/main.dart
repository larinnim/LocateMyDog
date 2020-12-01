import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Profile/MapLocation.dart';
import 'package:flutter_maps/Screens/SplashView.dart';
import 'package:provider/provider.dart';
import 'Screens/Profile/profile.dart';
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
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BleModel()),
          ChangeNotifierProvider(create: (context) => WiFiModel()),

        ],
        child: MaterialApp(
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
