import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/wifi_page.dart';
import 'package:get/get.dart';

import '../../loading.dart';

class ConnectivityPage extends StatefulWidget {
  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult? result;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((e) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("wifi_settings".tr),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          centerTitle: true,
          // backgroundColor: Colors.red,
        ),
        body: FutureBuilder(
            future: _connectivity.checkConnectivity(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              } else if (snapshot.data == ConnectivityResult.wifi) {
                return FutureBuilder<Map<String, String>?>(
                    future: EsptouchSmartconfig.wifiData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return WifiPage(snapshot.data!['wifiName']!,
                            snapshot.data!['bssid']!);
                      } else {
                        return Container();
                      }
                    });
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_sharp,
                        size: 200,
                        color: Colors.red,
                      ),
                      Text(
                        "wifi_not_connected".tr,
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      )
                    ],
                  ),
                );
              }
            }));
    // } else
    // return Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Icon(
    //         Icons.wifi_off_sharp,
    //         size: 200,
    //         color: Colors.red,
    //       ),
    //       Text(
    //         "wifi_not_connected".tr,
    //         style: TextStyle(fontSize: 20, color: Colors.grey),
    //       )
    //     ],
    //   ),
    // );
    // }),
  }
}
