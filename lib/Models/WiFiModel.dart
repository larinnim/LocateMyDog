import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WiFiModel extends ChangeNotifier {
  double lat;
  double lng;
  int rssi;
  String ssid;
  DateTime timestampWiFi;
  DateTime wifiConnectedTimestamp;
  String senderNumber;
  // DateTime now = DateTime.now();

  /// An unmodifiable view of the items in the cart.
  // UnmodifiableListView<BleDeviceItem> get items =>
  //     UnmodifiableListView(deviceList);

  void addLat(double value, String sender) {
    lat = value;
    senderNumber = sender;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addLng(double value, String sender) {
    lng = value;
    senderNumber = sender;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addRSSI(int value, String sender) {
    rssi = value;
    senderNumber = sender;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void addSSID(String value, String sender) {
    //print("addLat - Line 166");
    ssid = value;
    senderNumber = sender;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // void addTimeStamp(DateTime value) {
  void addTimeStamp(String timeString, String sender) {
    //print("addLgn - Line 177");
    timestampWiFi = DateTime.parse(timeString);
    senderNumber = sender;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void connectionWiFiTimestamp(String time, String sender) {
    senderNumber = sender;

    wifiConnectedTimestamp = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(time);
    // wifiConnectedTimestamp =
    //     new DateTime.fromMicrosecondsSinceEpoch(timeFormat.microsecondsSinceEpoch);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
