import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/change_email.dart';
import 'package:flutter_maps/Screens/ProfileSettings/languages.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions.dart';
import 'package:flutter_maps/Screens/ProfileSettings/reset_password.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/permissionChangeBuilder.dart';
import 'package:flutter_maps/Services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../loading.dart';
import 'WiFiSettings/wifi_settings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FixedExtentScrollController fixedExtentScrollController =
      new FixedExtentScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _notifyEscaped = false;
  bool _notifyLowGatewayBaterry = false;
  bool _notifyLowTrackerBaterry = false;

  String? _units = "meter";

  void _updateUnits(String? unitsChoose) {
    _db
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .set({'units': _units}, SetOptions(merge: true));
  }

  void getUnits(String? unitsFromDB) {
    _units = unitsFromDB;
  }

  void getNotificationSetting(Map<String, dynamic> notificatonSettings) {
    _notifyEscaped = notificatonSettings['geofence']['enabled'];
    _notifyLowGatewayBaterry = notificatonSettings['gatewayBattery']['enabled'];
    _notifyLowTrackerBaterry = notificatonSettings['trackerBattery']['enabled'];
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final Connectivity _connectivity = Connectivity();
    var platform = Theme.of(context).platform;

    return PermisisonChangeBuilder(
        permission: Permission.notification,
        builder: (context, status) {
          if(status.isGranted){
                DatabaseService(
                  uid: _firebaseAuth
                      .currentUser!
                      .uid)
              .setAgreedToNotBeNotified(false);
          }
          return FutureBuilder(
              initialData: false,
              future: mounted
                  ? _connectivity.checkConnectivity()
                  : Future.value(null),
              builder: (context, connectivitySnap) {
                if (connectivitySnap.hasData) {
                  return FutureBuilder<DocumentSnapshot>(
                      future: users.doc(_firebaseAuth.currentUser!.uid).get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> data = snapshot.data!.data()!;
                          getUnits(data['units']);
                          getNotificationSetting(data['Notification']);
                          var children2 = [
                            Text(
                              "settings".tr,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.red[200],
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "account".tr,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              height: 15,
                              thickness: 2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            buildChangeEmail(context, "change_email"),
                            buildResetPassword(context, "reset_password"),
                            buildChangeWifiSettings(context, "wifi_settings"),

                            // Divider(
                            //   height: 15,
                            //   thickness: 1,
                            // ),

                            // buildUnitSelection(context, "Units"),

                            InkWell(
                              onTap: () async {
                                // if (await ConnectivityWrapper.instance.isConnected) {
                                if (connectivitySnap.data ==
                                    ConnectivityResult.none) {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (_) => CupertinoAlertDialog(
                                            title: Text("Error"),
                                            content: Text(
                                                "You are offline. Please connect to an active internet connection."),
                                            actions: [
                                              // Close the dialog
                                              // You can use the CupertinoDialogAction widget instead
                                              CupertinoButton(
                                                  child: Text('Dismiss'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  }),
                                            ],
                                          ));
                                } else {
                                  setState(() {
                                    if (_units == "feet") {
                                      _units = "meter";
                                    } else {
                                      _units = "feet";
                                    }
                                  });
                                  _updateUnits(_units);
                                }

                                // } else {
                                //   showSnackBar(
                                //     context,
                                //     title:
                                //         "You are offline. Please connect to an active internet connection!",
                                //   );
                                // }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'units'.tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(_units != null
                                        ? _units!.tr.toUpperCase()
                                        : "meter".tr.toUpperCase()),
                                  ],
                                ),
                              ),
                            ),
                            // Divider(
                            //   height: 15,
                            //   thickness: 1,
                            // ),
                            buildLanguageSelection(context, "language"),
                            // Divider(
                            //   height: 15,
                            //   thickness: 1,
                            // ),
                            // buildAccountOptionRow(context, "Social"),
                            buildAccountOptionRow(context, "privacy_security"),
                            buildOfflineMapSelection(context, "offline_map"),

                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.volume_up_outlined,
                                  color: Colors.red[200],
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Notifications",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              height: 15,
                              thickness: 2,
                            ),
                            SizedBox(
                              height: 10,
                            ),                
                            platform == TargetPlatform.android
                                ? SwitchListTile(
                                    title: Text(
                                      'Escape Notifications',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600]),
                                    ),
                                    // secondary: const Icon(Icons.lightbulb_outline),
                                    value: _notifyEscaped,
                                    onChanged:
                                        status != PermissionStatus.granted
                                            ? null
                                            : (bool value) {
                                                setState(
                                                  () {
                                                    _notifyEscaped = value;
                                                    DatabaseService(
                                                            uid: _firebaseAuth
                                                                .currentUser!
                                                                .uid)
                                                        .updateNotificationPreference(
                                                            _notifyEscaped,
                                                            _notifyLowGatewayBaterry,
                                                            _notifyLowTrackerBaterry);
                                                  },
                                                );
                                              })
                                : CupertinoFormRow(
                                    child: CupertinoSwitch(
                                      value: _notifyEscaped,
                                      onChanged:
                                          status != PermissionStatus.granted
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    _notifyEscaped = value;
                                                    DatabaseService(
                                                            uid: _firebaseAuth
                                                                .currentUser!
                                                                .uid)
                                                        .updateNotificationPreference(
                                                            _notifyEscaped,
                                                            _notifyLowGatewayBaterry,
                                                            _notifyLowTrackerBaterry);
                                                  });
                                                },
                                    ),
                                    prefix: Text('Escape Notifications',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600])),
                                  ),
                            // buildNotificationOptionRow("Dog Escaped", true),
                            platform == TargetPlatform.android
                                ? SwitchListTile(
                                    title: Text(
                                      'Gateway Battery Level Notifications',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600]),
                                    ),
                                    value: _notifyLowGatewayBaterry,
                                    onChanged: status !=
                                            PermissionStatus.granted
                                        ? null
                                        : (bool value) {
                                            setState(() {
                                              _notifyLowGatewayBaterry = value;
                                              DatabaseService(
                                                      uid: _firebaseAuth
                                                          .currentUser!.uid)
                                                  .updateNotificationPreference(
                                                      _notifyEscaped,
                                                      _notifyLowGatewayBaterry,
                                                      _notifyLowTrackerBaterry);
                                            });
                                          },
                                  )
                                : CupertinoFormRow(
                                    child: CupertinoSwitch(
                                      value: _notifyEscaped,
                                      onChanged: (value) {
                                        setState(() {
                                          _notifyEscaped = value;
                                          DatabaseService(
                                                  uid: _firebaseAuth
                                                      .currentUser!.uid)
                                              .updateNotificationPreference(
                                                  _notifyEscaped,
                                                  _notifyLowGatewayBaterry,
                                                  _notifyLowTrackerBaterry);
                                        });
                                      },
                                    ),
                                    prefix: Text(
                                        'Gateway Battery Level Notifications',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600])),
                                  ),
                            // buildNotificationOptionRow("Gateway Low Battery", true),
                            platform == TargetPlatform.android
                                ? SwitchListTile(
                                    title: Text(
                                      'Tracker Battery Level Notifications',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600]),
                                    ),
                                    value: _notifyLowTrackerBaterry,
                                    onChanged: status !=
                                            PermissionStatus.granted
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _notifyLowTrackerBaterry = value;
                                              DatabaseService(
                                                      uid: _firebaseAuth
                                                          .currentUser!.uid)
                                                  .updateNotificationPreference(
                                                      _notifyEscaped,
                                                      _notifyLowGatewayBaterry,
                                                      _notifyLowTrackerBaterry);
                                            });
                                          },
                                  )
                                : CupertinoFormRow(
                                    child: CupertinoSwitch(
                                      value: _notifyEscaped,
                                      onChanged: (value) {
                                        setState(() {
                                          _notifyEscaped = value;
                                          DatabaseService(
                                                  uid: _firebaseAuth
                                                      .currentUser!.uid)
                                              .updateNotificationPreference(
                                                  _notifyEscaped,
                                                  _notifyLowGatewayBaterry,
                                                  _notifyLowTrackerBaterry);
                                        });
                                      },
                                    ),
                                    prefix: Text(
                                        'Tracker Battery Level Notifications',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600])),
                                  ),
                                  SizedBox(
                                    width: 50
                                  ),
                                  // if(!status.isGranted){
                                    Visibility(
                                      visible: !status.isGranted,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                        
                                          ElevatedButton(
                                              onPressed: () async {
                                                openAppSettings();
                                                // Navigator.of(context).push(MaterialPageRoute(
                                                //     builder: (context) => TaskRoute(widget.ssid, widget.bssid,
                                                //         password.text, deviceCount.text, isBroad)));
                                                // _stream = EsptouchSmartconfig.run(widget.ssid, widget.bssid,
                                                //     password.text, deviceCount.text, isBroad);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red[300],
                                                shape: new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(30.0),
                                                ),
                                              ),
                                              child: Text('Enable Notification on the App Settings to configure the Notifications')),
                                        ],
                                      ),
                                    ) 
                                  // }
                                 
                             
                            // buildNotificationOptionRow("Tracker Low Battery", true),
                          ];
                          return Scaffold(
                            appBar: AppBar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              elevation: 1,
                              leading: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.red[200],
                                ),
                              ),
                            ),
                            body: Container(
                              padding:
                                  EdgeInsets.only(left: 16, top: 25, right: 16),
                              child: ListView(
                                children: children2,
                              ),
                            ),
                          );
                        }
                        return Loading();
                      });
                } else {
                  return Loading();
                }
              });
          //  else {}
        });
  }
}

Row buildNotificationOptionRow(String title, bool isActive) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title.tr,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
      ),
      Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            value: isActive,
            onChanged: (bool val) {},
          ))
    ],
  );
}

GestureDetector buildChangeWifiSettings(BuildContext context, String title) {
  return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ConnectivityPage()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ));
}

GestureDetector buildChangeEmail(BuildContext context, String title) {
  return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChangeEmailPage()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ));
}

GestureDetector buildResetPassword(BuildContext context, String title) {
  return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ResetPasswordPage()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ));
}

// InkWell buildUnitSelection(BuildContext context, String title) {
//   return InkWell(
//     onTap: () {
//       setState(() {
//         if (_units == "miles") {
//           _units = "";
//         } else {
//           _units = "miles";
//         }
//       });
//       _updateUnits(_units);
//     },
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title.tr,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(_units!),
//         ],
//       ),
//     ),
//   );
// }

GestureDetector buildLanguageSelection(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => LanguagesPage()));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

GestureDetector buildOfflineMapSelection(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => OfflineRegionBody()));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

GestureDetector buildAccountOptionRow(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Option 1"),
                  Text("Option 2"),
                  Text("Option 3"),
                ],
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close")),
              ],
            );
          });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}
