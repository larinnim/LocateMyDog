import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Fence/Geofence.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Services/Radar.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:flutter_maps/Services/constants.dart';
import 'package:flutter_maps/Services/push_notification.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import 'MapLocation.dart';
import 'avatar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser _currentUser = locator.get<UserController>().currentUser;
  // WifiConnection networkcheck = WifiConnection();

  // String _connectionStatus = 'Unknown';
  // // final Connectivity _connectivity = Connectivity();
  // StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    readDatabase(); //Read current WIFI info from firebase
    PushNotificationsManager().init();
    // _checkNetwork();
    // WifiConnection().initConnectivity();
    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // _connectivity.initialise();
    // _connectivity.myStream.listen((source) {
    //   setState(() => _source = source);
    // });
  }

  @override
  void dispose() {
    // _connectivitySubscription.cancel();
    // networkcheck.streamController.close();
    super.dispose();
  }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initConnectivity() async {
  //   ConnectivityResult result;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //   } on PlatformException catch (e) {
  //     print(e.toString());
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) {
  //     return Future.value(null);
  //   }

  //   return _updateConnectionStatus(result);
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   switch (result) {
  //     case ConnectivityResult.wifi:
  //     case ConnectivityResult.mobile:
  //     case ConnectivityResult.none:
  //       setState(() => _connectionStatus = result.toString());
  //       break;
  //     default:
  //       setState(() => _connectionStatus = 'Failed to get connectivity.');
  //       break;
  //   }
  // }

  // Future _checkNetwork() async {
  //   if (!mounted) {
  //     return Future.value(null);
  //   } else {
  //     //this will provide value in your stream.
  //     networkcheck.initConnectivity();
  //   }

  //   // _connectivitySubscription =
  //   //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  //   _connectivitySubscription =
  //       networkcheck.streamController.stream.listen((data) {
  //     _connectionStatus = data;
  //     print('Got! $data');
  //   });
  // }

  void readDatabase() {
    // FirebaseFirestore.instance
    //   .collection('locateDog').where(field)

    FirebaseFirestore.instance
        .collection('locateDog')
        .doc(_currentUser.uid)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> firestoreInfo = documentSnapshot.data();

      // var date = DateTime.fromMillisecondsSinceEpoch(
      //         int.parse(firestoreInfo["timestamp"]) * 1000)
      //     .toLocal();

      // var date = firestoreInfo["timestamp"];
      // var date1 = firestoreInfo["timestamp"];
      // collectionRef.where('name', '>=', 'bar').where('name', '<=', 'foo')

      // firestoreInfo.map((key, value) {
      //   if (key.contains('IAT')) {
      //     print('CONTAINS');
      //   }
      // });

      // var date = DateTime.fromMillisecondsSinceEpoch(
      //     firestoreInfo["timestamp"].millisecondsSinceEpoch);

      // context.read<WiFiModel>().addLat(firestoreInfo["latitude"].toDouble());
      // context.read<WiFiModel>().addLng(firestoreInfo["longitude"].toDouble());
      // context.read<WiFiModel>().addRSSI(firestoreInfo["rssi"]);
      // context.read<WiFiModel>().addSSID(firestoreInfo["ssid"]);
      // context.read<WiFiModel>().addTimeStamp(date);

      // context.read<WiFiModel>().addLat(
      //     double.parse(firestoreInfo["Sender1"]["Location"]["Latitude"]));
      // context.read<WiFiModel>().addLng(
      //     double.parse(firestoreInfo["Sender1"]["Location"]["Longitude"]));
      // context.read<WiFiModel>().addRSSI(firestoreInfo["Sender1"]["RSSI"]);
      // context
      //     .read<WiFiModel>()
      //     .addSSID(firestoreInfo["Sender1"]["ConnectedWifiSSID"]);
      // context
      //     .read<WiFiModel>()
      //     .addTimeStamp(firestoreInfo["Sender1"]["LocationTimestamp"]);

      context.read<WiFiModel>().addLat(
          double.parse(firestoreInfo["Sender1"]["Location"]["Latitude"]));
      context.read<WiFiModel>().addLng(
          double.parse(firestoreInfo["Sender1"]["Location"]["Longitude"]));
      context.read<WiFiModel>().addRSSI(firestoreInfo["Sender1"]["RSSI"]);
      context
          .read<WiFiModel>()
          .addSSID(firestoreInfo["Sender1"]["ConnectedWifiSSID"]);
      context
          .read<WiFiModel>()
          .addTimeStamp(firestoreInfo["Sender1"]["LocationTimestamp"]);

      // print(firestoreInfo["latitude"]);
      // print(firestoreInfo["latitude"]);
      // print(firestoreInfo["latitude"]);
      // print(firestoreInfo["latitude"]);
      // print(firestoreInfo["latitude"]);
    }).onError((e) => print("ERROR reading snapshot" + e));
  }

  // @override
  // void dispose() {
  //   _connectivity.disposeStream();
  //   super.dispose();
  // }
  // Future<bool> checkConnection() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     return true;
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     return true;
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(750, 1334), allowFontScaling: true);
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final currentConnectionStatus = Provider.of<ConnectionStatusModel>(context);
    currentConnectionStatus.initConnectionListen();

    void signOut() async {
      await _firebaseAuth.signOut().then((value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Container(
              color: Colors.yellow, child: Material(child: Wrapper()));
        }));
      });
    }

    var profileInfo = Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(kSpacingUnit.w * 3)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Image.network(_currentUser?.avatarUrl, loadingBuilder:
            //     (BuildContext context, Widget child,
            //         ImageChunkEvent loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return Center(
            //     child: CircularProgressIndicator(
            //       value: loadingProgress.expectedTotalBytes != null
            //           ? loadingProgress.cumulativeBytesLoaded /
            //               loadingProgress.expectedTotalBytes
            //           : null,
            //     ),
            //   );
            // }),
            Avatar(
              avatarUrl: _currentUser?.avatarUrl,
              onTap: () async {
                File image =
                    await ImagePicker.pickImage(source: ImageSource.gallery);

                await locator.get<UserController>().uploadProfilePicture(image);

                setState(() {});
              },
            ),
            SizedBox(height: kSpacingUnit.w * 2),
            Text(
              "Where is  ${_firebaseAuth.currentUser.displayName} ?",
              style: kTitleTextStyle,
            ),
            // Text(
            //   "Hi ${_currentUser.displayName ?? 'nice to see you here.'}"),

            // "Hi ${_currentUser.displayName ?? 'nice to see you here.'}"),
          ],
        ),
      ),
    );
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        // Icon(
        //   LineAwesomeIcons.arrow_left,
        //   size: ScreenUtil().setSp(kSpacingUnit.w * 3),
        // ),
        profileInfo,
        // themeSwitcher,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return Builder(
      builder: (context) {
        return Scaffold(body:
            Consumer3<BleModel, WiFiModel, ConnectionStatusModel>(builder: (_,
                bleProvider, wifiProvider, connectionStatusProvider, child) {
          return Column(
            children: <Widget>[
              SizedBox(height: kSpacingUnit.w * 5),
              header,
              Expanded(
                child: ListView(
                  children: <Widget>[
                    ProfileListItem(
                      icon: LineAwesomeIcons.user_shield,
                      text: 'Privacy',
                    ),
                    InkWell(
                      onTap: () {
                        // checkConnection().then((internet) {
                        //   if (internet != null && internet) {
                        // Internet Present Case
                        // Navigator.pushReplacement(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return MapLocation();
                        // }));
                        // },
                        if (connectionStatusProvider.connectionStatus == NetworkStatus.Online) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MapLocation();
                          }));
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Radar()),
                          );
                        }
                      },
                      child: ProfileListItem(
                        icon: LineAwesomeIcons.search_location,
                        text: 'Map',
                        // text: 'Find ${_firebaseAuth.currentUser.displayName}',
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    new BluetoothConnection()));
                        // Navigator.pushNamed(context, '/trackWalk');
                        // Navigator.pushReplacement(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return BluetoothConnection();
                        // }));
                      },
                      child: ProfileListItem(
                        icon: LineAwesomeIcons.wired_network,
                        text: 'Connect',
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new Geofence()));
                      },
                      child: ProfileListItem(
                        icon: IconData(59174, fontFamily: 'MaterialIcons'),
                        text: 'Geofence',
                      ),
                    ),
                    ProfileListItem(
                      icon: LineAwesomeIcons.question_circle,
                      text: 'Help & Support',
                    ),
                    ProfileListItem(
                      icon: LineAwesomeIcons.cog,
                      text: 'Settings',
                    ),
                    InkWell(
                      onTap: () {
                        print("profile SIgn OUt");
                        // SignOut();
                        signOut();
                      },
                      child: ProfileListItem(
                        icon: LineAwesomeIcons.alternate_sign_out,
                        text: 'Logout',
                        hasNavigation: false,
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }));
      },
      // future: checkConnection(),
    );
  }
}

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;

  const ProfileListItem({
    Key key,
    this.icon,
    this.text,
    this.hasNavigation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSpacingUnit.w * 5.5,
      margin: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 4,
      ).copyWith(
        bottom: kSpacingUnit.w * 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
        color: Theme.of(context).backgroundColor,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            this.icon,
            size: kSpacingUnit.w * 2.5,
          ),
          SizedBox(width: kSpacingUnit.w * 1.5),
          Text(
            this.text,
            style: kTitleTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          if (this.hasNavigation)
            Icon(
              LineAwesomeIcons.angle_right,
              size: kSpacingUnit.w * 2.5,
            ),
        ],
      ),
    );
  }
}

// class MyConnectivity {
//   MyConnectivity._internal();

//   static final MyConnectivity _instance = MyConnectivity._internal();

//   static MyConnectivity get instance => _instance;

//   Connectivity connectivity = Connectivity();

//   StreamController controller = StreamController.broadcast();

//   Stream get myStream => controller.stream;

//   void initialise() async {
//     ConnectivityResult result = await connectivity.checkConnectivity();
//     _checkStatus(result);
//     connectivity.onConnectivityChanged.listen((result) {
//       _checkStatus(result);
//     });
//   }

//   void _checkStatus(ConnectivityResult result) async {
//     bool isOnline = false;
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         isOnline = true;
//       } else
//         isOnline = false;
//     } on SocketException catch (_) {
//       isOnline = false;
//     }
//     if (!controller.isClosed) {
//       controller.sink.add({result: isOnline});
//     }
//   }

//   void disposeStream() => controller.close();
// }
