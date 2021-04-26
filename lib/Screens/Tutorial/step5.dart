import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Devices/device.dart';
import 'package:flutter_maps/Screens/Devices/device_detail.dart';
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../loading.dart';
import 'addNewDevice.dart';
import 'step3.dart';
import '../../locator.dart';

import 'package:flutter_maps/Services/database.dart';

class Step5 extends StatefulWidget {
  @override
  _Step5State createState() => new _Step5State();
}

class _Step5State extends State<Step5> {
  CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final List<Color> _availableColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red
  ];
  @override
  initState() {
    super.initState();
  }

  void completedSetup(bool completed) async {
    await DatabaseService(uid: _firebaseAuth.currentUser!.uid)
        .completedSetup(completed)
        .then((value) => Get.off(Wrapper()));
  }

  void goToAddNewDevice(int senderID, String color) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => AddNewDevice(senderID, color)))
        .then((value) {
      _availableColors.removeAt(0);
      print(value.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference sendersStream = FirebaseFirestore.instance
        .collection('locateDog')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('gateway');

    return StreamBuilder<QuerySnapshot>(
        stream: sendersStream.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          return Material(
              type: MaterialType.transparency,
              child: new Container(
                decoration: BoxDecoration(color: Colors.white),
                child: SafeArea(
                    child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                  child: Column(children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'Step 5 of 5',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20.0,
                              fontFamily: 'RobotoMono'),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Visibility(
                      visible: snapshot.data!.docs.length < 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //Center Row contents horizontally,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.red[300]),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ))),
                              label: Text(
                                'Add New Device',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              onPressed: () {
                                goToAddNewDevice(
                                    snapshot.data!.docs.length + 1,
                                    AuxFunc().colorNamefromColor(
                                        _availableColors[0]));
                              },
                            ),
                          ),
                        ],
                      ),
                      replacement: Row(
                        children: [
                          Text(
                            'You have already configured up to 4 devices',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'RobotoMono'),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Expanded(
                      child: new ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(height: 1),
                          itemBuilder: (BuildContext context, int index) {
                            return ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                child: ListTile(
                                    tileColor: AuxFunc().getColor(snapshot.data!.docs[index]['color']),
                                    leading: Icon(
                                      LineAwesomeIcons.mobile_phone,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                      snapshot.data!.docs[index]['name'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )));
                            // title: Text("List item $index"));
                          }),
                    ),
                    Visibility(
                      visible: snapshot.data!.docs.length < 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[],
                      ),
                      replacement: Column(
                        children: [
                          SizedBox(
                            height: 30.0,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                            child: Text(
                              'Continue',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            onPressed: () {
                              completedSetup(true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                )),
              ));
        });
  }
}
