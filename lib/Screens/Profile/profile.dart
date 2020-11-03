import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:flutter_maps/Services/constants.dart';
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
    readDatabase();
    // readDatabase();
  }

  void readDatabase() {
    FirebaseFirestore.instance
        .collection('locateDog')
        .doc("3heCcuuJTpVhYqTp2wHDS5Nq4IL2")
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {

      Map<String, dynamic> firestoreInfo = documentSnapshot.data();

      var date = DateTime.fromMillisecondsSinceEpoch(
          firestoreInfo["timestamp"] * 1000).toLocal();

      context.read<WiFiModel>().addLat(firestoreInfo["latitude"]);
      context.read<WiFiModel>().addLng(firestoreInfo["longitude"]);
      context.read<WiFiModel>().addRSSI(firestoreInfo["rssi"]);
      context.read<WiFiModel>().addSSID(firestoreInfo["ssid"]);
      context.read<WiFiModel>().addTimeStamp(date);

      print(firestoreInfo["latitude"]);
      print(firestoreInfo["latitude"]);
      print(firestoreInfo["latitude"]);
      print(firestoreInfo["latitude"]);
      print(firestoreInfo["latitude"]);

    }).onError((e) => print("ERROR reading snapshot" +e));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(750, 1334), allowFontScaling: true);
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
        return Scaffold(
          body: Column(
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
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return MapLocation();
                        }));
                      },
                      child: ProfileListItem(
                        icon: LineAwesomeIcons.search_location,
                        text: 'Find ${_firebaseAuth.currentUser.displayName}',
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
                        icon: LineAwesomeIcons.walking,
                        text: 'Track Walk',
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
          ),
        );
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
