import 'dart:async';
import 'dart:io';
import "dart:ui" as ui;
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Authenticate/home_sigin_widget.dart';
import 'package:flutter_maps/Screens/Devices/device_list.dart';
import 'package:flutter_maps/Screens/Devices/gateway_detail.dart';
import 'package:flutter_maps/Screens/Fence/Geofence.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions.dart';
import 'package:flutter_maps/Screens/ProfileSettings/settings_page.dart';
import 'package:flutter_maps/Screens/help_support.dart';
import 'package:flutter_maps/Services/Radar.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:flutter_maps/Services/constants.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/permissionChangeBuilder.dart';
import 'package:flutter_maps/Services/push_notification.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../locator.dart';
import '../loading.dart';
import 'MapLocation.dart';
import 'avatar.dart';

class ProfileScreen extends StatefulWidget {
  final bool? wantsTouchId;
  final String? password;

  ProfileScreen({this.wantsTouchId, this.password});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // bool _ackNotify = false;
  AppUser? _currentUser = locator.get<UserController>().currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final LocalAuthentication localauth = LocalAuthentication();
  final picker = ImagePicker();
  late File _image;

  SocialSignInSingleton socialSiginSingleton = SocialSignInSingleton();
  final box = GetStorage();
  final storage = FlutterSecureStorage();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    // readDatabase(); //Read current WIFI info from firebase
    PushNotificationsManager().init();

    if (widget.wantsTouchId != null && widget.password != null) {
      checkAuthentication();
    }
    requestLocation();
    // cleanNotifyPref(); For Test Purposes
  }

  void requestLocation() async {
    await Permission.location.request();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<bool> _checkIfIsLogged() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      // now you can call to  FacebookAuth.instance.getUserData();
      return true;
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
    } else {
      return false;
    }
  }

  void checkAuthentication() async {
    if (_currentUser != null) {
      storage.write(key: 'email', value: _auth.currentUser!.email);
      storage.write(key: 'password', value: widget.password);
      storage.write(key: 'usingBiometric', value: 'true');
    }
  }

  void logout() async {
    // await googleSignIn.disconnect();
    // FirebaseAuth.instance.signOut();

    bool isGoogleSignedIn = await GoogleSignIn().isSignedIn();
    bool isFacebookSignedIn = await _checkIfIsLogged();
    if (isGoogleSignedIn == true) {
      GoogleSignIn().disconnect();
    } else if (isFacebookSignedIn == true) {
      FacebookAuth.instance.logOut();
    }
    FirebaseAuth.instance.signOut().then((value) async {
      Get.offAll(Authenticate());
      box.read('token');
      // isSignedIn = false;
      // Get.to(Authenticate(),
      //     transition: Transition.downToUp,
      //     duration: Duration(seconds: 1));
    });
    _firebaseMessaging.deleteToken(senderId: '687212317780');
    PushNotificationsManager().clear();
  }
  void setAckNotification(bool setAck) async {
    // setState(() {
    // _ackNotify = setAck;
    // });
     DatabaseService(
                  uid: _auth
                      .currentUser!
                      .uid)
              .setAgreedToNotBeNotified(setAck);
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(_auth.currentUser!.uid)
    //     .set({'agreedToNotBeNotified': setAck}, SetOptions(merge: true));

    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool('ackNotify', setAck);
  }

  // void cleanNotifyPref() async {
  //   //FOR TESTING PURPOSES ONLY
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.remove('ackNotify');
  // }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context,
    //     designSize: Size(750, 1334), allowFontScaling: true);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(750, 1334),
        orientation: Orientation.portrait);

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final currentConnectionStatus = Provider.of<ConnectionStatusModel>(context);
    currentConnectionStatus.initConnectionListen();
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return StreamBuilder<DocumentSnapshot>(
        stream: users.doc(_firebaseAuth.currentUser!.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnaps) {
          if (userSnaps.hasError) {
            return Text('Something went wrong');
          }

          if (userSnaps.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          if (userSnaps.connectionState == ConnectionState.active) {
            Map<String, dynamic> userData = userSnaps.data!.data()!;

            return PermisisonChangeBuilder(
                permission: Permission.notification,
                builder: (context, status) {
                  if (status != PermissionStatus.granted &&
                      userData['agreedToNotBeNotified'] == false) {
                    return new Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 150.0,
                        ),
                        Image.asset(
                          'assets/images/denied.png',
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          'You need to allow notification to be notified by the app when the pet is not inside the geofence or the devices battery level\n You can change this later on the Settings Page',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        ElevatedButton(
                            child: Text("Go to Settings".toUpperCase(),
                                style: TextStyle(fontSize: 14)),
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.red)))),
                            onPressed: () => AppSettings.openAppSettings()),
                        ElevatedButton(
                            child: Text(
                                "I acknowledge I wont be notified by the app"
                                    .toUpperCase(),
                                style: TextStyle(fontSize: 14)),
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.red)))),
                            onPressed: () {
                              setAckNotification(true);
                              // Navigator.pop(context);
                            })
                      ],
                    ));
                  } 
                  else {
                    return Builder(
                      builder: (context) {
                        return Stack(
                          children: <Widget>[
                            Scaffold(
                              body: Consumer3<BleModel, WiFiModel,
                                      ConnectionStatusModel>(
                                  builder: (_, bleProvider, wifiProvider,
                                      connectionStatusProvider, child) {
                                return FutureBuilder(
                                    initialData: false,
                                    future: mounted
                                        ? currentConnectionStatus
                                            .getCurrentStatus()
                                        : Future.value(null),
                                    builder: (context, snapshot) {
                                      return Column(
                                        children: <Widget>[
                                          SizedBox(height: kSpacingUnit.w * 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                  width: kSpacingUnit.w * 3),
                                              Avatar(
                                                avatarUrl: _auth.currentUser !=
                                                        null
                                                    ? _auth.currentUser!
                                                                .photoURL !=
                                                            null
                                                        ? !_auth.currentUser!
                                                                .photoURL!
                                                                .contains(
                                                                    'facebook')
                                                            ? _auth.currentUser!
                                                                .photoURL
                                                            : _auth.currentUser!
                                                                    .photoURL! +
                                                                "?height=500&access_token=" +
                                                                box.read(
                                                                    'token')
                                                        : _currentUser
                                                                    ?.avatarUrl !=
                                                                null
                                                            ? _currentUser
                                                                ?.avatarUrl
                                                            : ""
                                                    : "",
                                                onTap: () async {
                                                  getImage();
                                                  locator
                                                      .get<UserController>()
                                                      .uploadProfilePicture(
                                                          _image);
                                                  setState(() {});
                                                },
                                              ),
                                              SizedBox(
                                                  width: kSpacingUnit.w * 3),
                                            ],
                                          ),
                                          SizedBox(height: kSpacingUnit.w * 3),
                                          Column(
                                            children: <Widget>[ 
                                            ListView(
                                              shrinkWrap: true,
                                              children: <Widget>[
                                                // ProfileListItem(
                                                //   icon: LineAwesomeIcons.user_shield,
                                                //   text: 'Privacy',
                                                // ),
                                                InkWell(
                                                  onTap: () {
                                                    if (snapshot.hasData) {
                                                      if (connectionStatusProvider
                                                                  .connectionStatus ==
                                                              NetworkStatus
                                                                  .Online ||
                                                          snapshot.data ==
                                                              NetworkStatus
                                                                  .Online) {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return MapLocation();
                                                        }));
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OfflineRegionBody()),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: ProfileListItem(
                                                    icon: LineAwesomeIcons
                                                        .search_location,
                                                    text: 'map'.tr,
                                                  ),
                                                ),
                                                // InkWell(
                                                //   onTap: () {
                                                //     Navigator.push(
                                                //         context,
                                                //         new MaterialPageRoute(
                                                //             builder: (context) =>
                                                //                 new BluetoothConnection()));
                                                //     // Navigator.pushNamed(context, '/trackWalk');
                                                //     // Navigator.pushReplacement(context,
                                                //     //     MaterialPageRoute(builder: (context) {
                                                //     //   return BluetoothConnection();
                                                //     // }));
                                                //   },
                                                //   child: ProfileListItem(
                                                //     icon: LineAwesomeIcons.wired_network,
                                                //     text: 'connect'.tr,
                                                //   ),
                                                // ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                new DeviceList()));
                                                  },
                                                  child: ProfileListItem(
                                                    icon: LineAwesomeIcons
                                                        .mobile_phone,
                                                    text: 'Devices',
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                new Geofence()));
                                                  },
                                                  child: ProfileListItem(
                                                    icon: IconData(59174,
                                                        fontFamily:
                                                            'MaterialIcons'),
                                                    text: 'geofence'.tr,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                new HelpSupport()));
                                                  },
                                                  child: ProfileListItem(
                                                    icon: LineAwesomeIcons
                                                        .question_circle,
                                                    text: 'help_support'.tr,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                new SettingsPage()));
                                                  },
                                                  child: ProfileListItem(
                                                    icon: LineAwesomeIcons.cog,
                                                    text: 'settings'.tr,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    // final provider =
                                                    //     Provider.of<SocialSignInProvider>(
                                                    //         context,
                                                    //         listen: false);
                                                    // socialLogin.logout();
                                                    logout();
                                                    // provider.logout();
                                                    // if (!socialLogin.isSignedIn) {
                                                    //   Navigator.pushAndRemoveUntil(
                                                    //       context,
                                                    //       PageRouteBuilder(pageBuilder:
                                                    //           (BuildContext context,
                                                    //               Animation animation,
                                                    //               Animation
                                                    //                   secondaryAnimation) {
                                                    //         return Authenticate();
                                                    //       }, transitionsBuilder:
                                                    //           (BuildContext context,
                                                    //               Animation<double> animation,
                                                    //               Animation<double>
                                                    //                   secondaryAnimation,
                                                    //               Widget child) {
                                                    //         return new SlideTransition(
                                                    //           position: new Tween<Offset>(
                                                    //             begin: const Offset(1.0, 0.0),
                                                    //             end: Offset.zero,
                                                    //           ).animate(animation),
                                                    //           child: child,
                                                    //         );
                                                    //       }),
                                                    //       (Route route) => false);
                                                    // }

                                                    // SignOut();
                                                    // signOut();
                                                  },
                                                  child: ProfileListItem(
                                                    icon: LineAwesomeIcons
                                                        .alternate_sign_out,
                                                    text: 'logout'.tr,
                                                    hasNavigation: false,
                                                  ),
                                                ),
                                                // Align(
                                                //     alignment: Alignment.bottomCenter,
                                                //     child: Text.rich(TextSpan(
                                                //       children: <InlineSpan>[
                                                //         TextSpan(
                                                //             text: 'Powered by Majel Tecnologies'),
                                                //         WidgetSpan(
                                                //           alignment: ui.PlaceholderAlignment.middle,
                                                //           child: ImageIcon(
                                                //               AssetImage('assets/icon/icon.png'),
                                                //               size: 40),
                                                //         ),
                                                //       ],
                                                //     )))
                                              ],
                                            ),
                                            ]),
                                          Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text.rich(TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                      text:
                                                          'Powered by Majel Tecnologies'),
                                                  WidgetSpan(
                                                    alignment: ui
                                                        .PlaceholderAlignment
                                                        .middle,
                                                    child: ImageIcon(
                                                        AssetImage(
                                                            'assets/icon/icon.png'),
                                                        size: 40),
                                                  ),
                                                ],
                                              )))
                                        ],
                                      );
                                    });
                              }),
                            ),
                            // Align(
                            //     alignment: Alignment.bottomCenter,
                            //     child: Text.rich(TextSpan(
                            //       children: <InlineSpan>[
                            //         TextSpan(text: 'Powered by Majel Tecnologies'),
                            //         WidgetSpan(
                            //           alignment: ui.PlaceholderAlignment.middle,
                            //           child: ImageIcon(AssetImage('assets/icon/icon.png'),
                            //               size: 40),
                            //         ),
                            //       ],
                            //     )))
                          ],
                        );
                      },
                    );
                  }
                });
          } else {
            return Loading();
          }
        });
  }
}

class ProfileListItem extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final bool hasNavigation;

  const ProfileListItem({
    Key? key,
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
        color: Colors.red[200],
        // color: Theme.of(context).backgroundColor,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            this.icon,
            size: kSpacingUnit.w * 2.5,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: kSpacingUnit.w * 1.5),
          Text(
            this.text!,
            style: kTitleTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor),
          ),
          Spacer(),
          if (this.hasNavigation)
            Icon(
              LineAwesomeIcons.angle_right,
              size: kSpacingUnit.w * 2.5,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
