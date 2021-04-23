import 'dart:async';
import 'package:esptouch_smartconfig/esp_touch_result.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/wifi_page.dart';
import 'package:get/get.dart';

class TaskRoute extends StatefulWidget {
  TaskRoute(
      this.ssid, this.bssid, this.password, this.deviceCount, this.isBroadcast);
  final String ssid;
  final String bssid;
  final String password;
  final String deviceCount;
  final bool isBroadcast;
  @override
  State<StatefulWidget> createState() {
    return TaskRouteState();
  }
}

class TaskRouteState extends State<TaskRoute> {
  late Stream<ESPTouchResult>? _stream;

  @override
  void initState() {
    _stream = EsptouchSmartconfig.run(widget.ssid, widget.bssid,
        widget.password, widget.deviceCount, widget.isBroadcast);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget waitingState(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
        children: [
          Text(
            "wifi_credentials_not_work".tr,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            width: 150.0,
            height: 50.0,
            child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(MaterialPageRoute(
                      builder: (context) =>
                          WifiPage(widget.ssid, widget.bssid)));
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
        children: [
          Text(
            "wifi_connected".tr,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            width: 150.0,
            height: 50.0,
            child: ElevatedButton(
                onPressed: () async {
                 Navigator.of(context).pop(MaterialPageRoute(
                  builder: (context) =>
                      WifiPage(widget.ssid, widget.bssid, espIP)));
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
      body: Container(
        child: StreamBuilder<ESPTouchResult>(
          stream: _stream,
          builder: (context, AsyncSnapshot<ESPTouchResult> snapshot) {
            if (snapshot.hasError) {
              return error(context);
            }
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
             
              return success(context, snapshot.data!.ip);
            }
             else if (snapshot.connectionState == ConnectionState.waiting) {
              return waitingState(context);
            } else {
              return error(context);
            }
          },
        ),
      ),
    );
  }
}
