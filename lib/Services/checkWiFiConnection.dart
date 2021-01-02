import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class WifiConnection {
  ConnectivityResult result;
  // String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  // StreamSubscription<ConnectivityResult> _connectivitySubscription;
  //
  // Initialize a "Broadcast" Stream controller of integers
  //
  final StreamController streamController =
      StreamController.broadcast();


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
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

  	streamController.sink.add(_updateConnectionStatus(result));

    // return _updateConnectionStatus(result);
  }

  String _updateConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        return result.toString();
        break;
      default:
        return 'Failed to get connectivity.';
        break;
    }
  }
}
