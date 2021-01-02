import 'package:flutter/material.dart';

class WiFiModel extends ChangeNotifier {
  double lat;
  double lng;
  int rssi;
  String ssid;
  DateTime timestampWiFi;
  // DateTime now = DateTime.now();

  /// An unmodifiable view of the items in the cart.
  // UnmodifiableListView<BleDeviceItem> get items =>
  //     UnmodifiableListView(deviceList);

  void addLat(double value) {
    lat = value;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addLng(double value) {
    lng = value;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addRSSI(int value) {
    rssi = value;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addSSID(String value) {
    //print("addLat - Line 166");
    ssid = value;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // void addTimeStamp(DateTime value) {
      void addTimeStamp(String timeString) {

    //print("addLgn - Line 177");
    timestampWiFi = DateTime.parse(timeString);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
