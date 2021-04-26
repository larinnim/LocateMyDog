import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

void main() async {
  await GetStorage.init(); //get storage initialization

  // void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.location.request();
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
  }

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
        ));
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
