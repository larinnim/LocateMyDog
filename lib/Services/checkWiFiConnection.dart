import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

enum NetworkStatus { Online, Offline }

class ConnectionStatusModel extends ChangeNotifier {
  NetworkStatus connectionStatus;
  // StreamController<NetworkStatus> networkStatusController =
  //     StreamController<NetworkStatus>();
  final Connectivity _connectivity = Connectivity();

  void initConnectionListen() {
    Connectivity().onConnectivityChanged.listen((status) {
      // networkStatusController.add(_getNetworkStatus(status));
      connectionStatus = _getNetworkStatus(status);
      notifyListeners();
    });
  }

 // Platform messages are asynchronous, so we initialize in an async method.
  Future<NetworkStatus> getCurrentStatus() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }

    return _getNetworkStatus(result);
  }

  NetworkStatus _getNetworkStatus(ConnectivityResult status) {
    return status == ConnectivityResult.mobile ||
            status == ConnectivityResult.wifi
        ? NetworkStatus.Online
        : NetworkStatus.Offline;
  }
}
