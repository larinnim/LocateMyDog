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

  @override
  void initState() {
    super.initState();
    readDatabase(); //Read current WIFI info from firebase
    PushNotificationsManager().init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void readDatabase() {
    FirebaseFirestore.instance
        .collection('locateDog')
        .doc(_currentUser.uid)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> firestoreInfo = documentSnapshot.data();

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

    }).onError((e) => print("ERROR reading snapshot" + e));
  }

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
          ],
        ),
      ),
    );
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        profileInfo,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return Builder(
      builder: (context) {
        return Scaffold(body:
            Consumer3<BleModel, WiFiModel, ConnectionStatusModel>(builder: (_,
                bleProvider, wifiProvider, connectionStatusProvider, child) {
          return FutureBuilder(
              initialData: false,
              future: mounted ? currentConnectionStatus.getCurrentStatus() : Future.value(null),
              builder: (context, snapshot) {
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
                              if (snapshot.hasData) {
                                if (connectionStatusProvider.connectionStatus ==
                                        NetworkStatus.Online ||
                                    snapshot.data == NetworkStatus.Online) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MapLocation();
                                  }));
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Radar()),
                                  );
                                }
                              }
                            },
                            child: ProfileListItem(
                              icon: LineAwesomeIcons.search_location,
                              text: 'Map',
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
                              icon:
                                  IconData(59174, fontFamily: 'MaterialIcons'),
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
              });
        }));
      },
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
