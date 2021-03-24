import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/change_email.dart';
import 'package:flutter_maps/Screens/ProfileSettings/languages.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions.dart';
import 'package:flutter_maps/Screens/ProfileSettings/reset_password.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FixedExtentScrollController fixedExtentScrollController =
      new FixedExtentScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _units = "Kilometre";

  void _updateUnits(String unitsChoose) {
    _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .set({'units': _units}, SetOptions(merge: true));
  }

  void getUnits(String unitsFromDB) {
    _units = unitsFromDB;
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(_firebaseAuth.currentUser.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            getUnits(data['units']);

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                padding: EdgeInsets.only(left: 16, top: 25, right: 16),
                child: ListView(
                  children: [
                    Text(
                      "settings".tr,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
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
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                    // Divider(
                    //   height: 15,
                    //   thickness: 1,
                    // ),

                    // buildUnitSelection(context, "Units"),

                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_units == "Miles".tr) {
                            _units = "Kilometre".tr;
                          } else {
                            _units = "Miles".tr;
                          }
                        });
                        _updateUnits(_units);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'units'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(_units != null ? _units : "Kilometre"),
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
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                    buildNotificationOptionRow("New for you", true),
                    buildNotificationOptionRow("Account activity", true),
                    buildNotificationOptionRow("Opportunity", false),
                    // SizedBox(
                    //   height: 50,
                    // ),
                    // Center(
                    //   child: OutlineButton(
                    //     padding: EdgeInsets.symmetric(horizontal: 40),
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20)),
                    //     onPressed: () {},
                    //     child: Text("SIGN OUT",
                    //         style: TextStyle(
                    //             fontSize: 16, letterSpacing: 2.2, color: Colors.black)),
                    //   ),
                    // )
                  ],
                ),
              ),
            );
          }
          return Container(
            color: Colors.white,
            child: SpinKitCircle(
              color: Colors.red,
              size: 30.0,
            ),
          );
        });
  }

  Row buildNotificationOptionRow(String title, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]),
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

  InkWell buildUnitSelection(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_units == "Kilometre") {
            _units = "Kilometre";
          } else {
            _units = "Kilometre";
          }
        });
        _updateUnits(_units);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(_units),
          ],
        ),
      ),
    );
  }

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
}
