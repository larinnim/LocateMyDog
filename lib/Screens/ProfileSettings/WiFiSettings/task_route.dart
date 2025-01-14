import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esptouch_smartconfig/esp_touch_result.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/wifi_page.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:get/get.dart';

class TaskRoute extends StatefulWidget {
  TaskRoute(this.ssid, this.bssid, this.password, this.deviceCount,
      this.isBroadcast, this.gatewayConnected, this.gatewayConnectedSSID);
  final String ssid;
  final String bssid;
  final String password;
  final String deviceCount;
  final bool isBroadcast;
  final bool gatewayConnected;
  final String gatewayConnectedSSID;

  @override
  State<StatefulWidget> createState() {
    return TaskRouteState();
  }
}

class TaskRouteState extends State<TaskRoute> {
  late Stream<ESPTouchResult>? _stream;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference gatewayCollection =
      FirebaseFirestore.instance.collection('gateway');
  String _gatewayID = "";

  @override
  void initState() {
    _stream = EsptouchSmartconfig.run(widget.ssid, widget.bssid,
        widget.password, widget.deviceCount, widget.isBroadcast);
    _getGatewayID();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  void _getGatewayID() {
    gatewayCollection
        .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        _gatewayID = doc.id;
      });
    });
  }

  Widget waitingState(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.red),
          ),
          SizedBox(height: 16),
          Text(
            'trying_to_connect'.tr,
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget error(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 100.0,
          ),
          Image.asset(
            'assets/images/cloud_disconnected.png',
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 200.0,
          ),
          Text(
            "wifi_credentials_not_work".tr,
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          SizedBox(height: 100.0),
          SizedBox(
            width: 150.0,
            height: 50.0,
            child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(MaterialPageRoute(
                      builder: (context) => WifiPage(
                          widget.ssid,
                          widget.bssid,
                          widget.gatewayConnected,
                          widget.gatewayConnectedSSID)));
                  Navigator.of(context)
                      .pop(); // POP twice because of the dialog box
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[300],
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                ),
                child: Text("OK")),
          ),
        ],
      ),
    );
  }

  Widget success(BuildContext context, String espIP) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 100.0,
          ),
          Image.asset(
            'assets/images/cloud_connected.png',
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 200.0,
          ),
          Text(
            "wifi_connected".tr,
            style: TextStyle(
                color: Colors.lightGreen[400],
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 100.0),
          SizedBox(
            width: 150.0,
            height: 50.0,
            child: ElevatedButton(
                onPressed: () async {
                  DatabaseService(uid: _firebaseAuth.currentUser!.uid)
                      .updateWiFiSSID(_gatewayID, widget.ssid);
                  Navigator.pop(context, espIP);
                  Navigator.of(context)
                      .pop(); // POP twice because of the dialog box
                  // _sendChangeWiFiCommand();
                  // Navigator.of(context).pop(MaterialPageRoute(
                  //     builder: (context) =>
                  //         WifiPage(widget.ssid, widget.bssid, espIP)));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[300],
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                ),
                child: Text("continue".tr)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: StreamBuilder<ESPTouchResult>(
            stream: _stream,
            builder: (context, AsyncSnapshot<ESPTouchResult> snapshot) {
              if (snapshot.hasError) {
                return error(context);
              }
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                return success(context, snapshot.data!.ip);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return waitingState(context);
              } else {
                return error(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
