import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/bluetooth_conect.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'offline_regions.dart';

class OfflineRegionMap extends StatefulWidget {
  OfflineRegionMap(this.item);

  final OfflineRegionListItem item;

  @override
  _OfflineRegionMapState createState() => _OfflineRegionMapState();
}

class _OfflineRegionMapState extends State<OfflineRegionMap> {
  late MapboxMapController controller;
  int symbolCount = 1;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool? _finishedLoadingMap = false;
  Map<String, Symbol> _symbols = <String, Symbol>{};

  CollectionReference sendersCollection =
      FirebaseFirestore.instance.collection('sender');
  @override
  void initState() {
    super.initState();
    readDatabase(); // set context read
  }

  @override
  void dispose() {
    // if (controller != null) {
    //   controller.removeListener(_onMapChanged);
    // }
    super.dispose();
  }

  // Future<void> _initSenders() async {

  // }

  // void _initAddSymbol() {
  //   var tempIatData = Provider.of<IATDataModel>(context, listen: false).iatData;
  //   _add(tempIatData);
  // }
  // void _onMapChanged() {
  //   // setState(() {
  //   _add(Provider.of<IATDataModel>(context, listen: false).iatData);
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    _add(Provider.of<IATDataModel>(context, listen: true).iatData);
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Region: ${widget.item.name}'),
      ),
      body: Consumer<IATDataModel>(builder: (context, iatDataProvider, child) {
        return MapboxMap(
          // onMapCreated: _onMapCreated,
          onMapCreated: (MapboxMapController controller) {
            this.controller = controller;

            // controller.addListener(() {
            //   _add(iatDataProvider.iatData);
            // });
            // controller.addListener(_onMapChanged);
            // _initAddSymbol();
            // _add(iatDataProvider.iatData);
          },
          onStyleLoadedCallback: () {
            // _add(iatDataProvider.iatData);
            _finishedLoadingMap = true;
          },

          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: widget.item.offlineRegionDefinition.minZoom,
          ),
          minMaxZoomPreference: MinMaxZoomPreference(
            widget.item.offlineRegionDefinition.minZoom,
            widget.item.offlineRegionDefinition.maxZoom,
          ),
          styleString: widget.item.offlineRegionDefinition.mapStyleUrl,
          cameraTargetBounds: CameraTargetBounds(
            widget.item.offlineRegionDefinition.bounds,
          ),
        );
      }),
    );
  }

  LatLng get _center {
    final bounds = widget.item.offlineRegionDefinition.bounds;
    final lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }

  // void _onMapCreated(MapboxMapController controller) {
  //   this.controller = controller;
  //   _add();
  // }

  void readDatabase() async {
    int gwBatteryLevel = 0;
    if (_firebaseAuth.currentUser != null) {
      sendersCollection
          .where('userID',
              isEqualTo: _firebaseAuth
                  .currentUser?.uid) //Listen to changes in all the users
          .where('enabled',
              isEqualTo: true) // Get only senders that are enabled
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> firestoreInfo = change.doc.data()!;
          firestoreInfo.forEach((key, value) async {
            print(key);
            print(value);
            await FirebaseFirestore.instance
                .collection('gateway')
                .doc('GW-' + firestoreInfo["senderMac"])
                .get()
                .then((DocumentSnapshot documentSnapshot) {
              if (documentSnapshot.exists) {
                print('Document exists on the database');
                gwBatteryLevel = documentSnapshot['batteryLevel'];
              }
            });
            var tempIatData = new IATData(
                senderMAC: firestoreInfo["senderMac"],
                latitude: firestoreInfo['Location']['Latitude'],
                longitude: firestoreInfo['Location']['Longitude'],
                locationTimestamp: firestoreInfo['LocationTimestamp'] != ""
                    ? DateTime.parse(firestoreInfo['LocationTimestamp'])
                        .millisecondsSinceEpoch
                    : 0,
                gatewayMAC: firestoreInfo['gatewayID'],
                trackerBatteryLevel: firestoreInfo['batteryLevel'],
                gatewayBatteryLevel: gwBatteryLevel,
                senderColor: firestoreInfo['color'],
                escaped: firestoreInfo['escaped']);
            context.read<IATDataModel>().iatData = tempIatData;
            // context.read<IATDataModel>().addIatData(tempIatData);
            // _add(tempIatData);
          });
        });
      });
    }
  }

  void _add(IATData iatData) async {
    if (_finishedLoadingMap == true) {
      LatLng _geometry = LatLng(
        iatData.latitude ?? 0,
        iatData.longitude ?? 0,
        // _center.latitude + sin(symbolCount * pi / 6.0) / 20.0,
        // _center.longitude + cos(symbolCount * pi / 6.0) / 20.0,
      );

      if (_symbols.length > 0) {
        if (_symbols.containsKey(iatData.senderMAC!)) {
          setState(()async {
                          await controller.updateSymbol(
            _symbols[iatData.senderMAC!]!,
            SymbolOptions(geometry: _geometry),
          );
                    });
          // await controller.updateSymbol(
          //   _symbols[iatData.senderMAC!]!,
          //   SymbolOptions(geometry: _geometry),
          // );
        }
        // markers.removeWhere(
        //     (marker) => marker.mapsId.value.toString() == 'SD-' + sender!);
      }
      _symbols[iatData.senderMAC!] = await controller.addSymbol(SymbolOptions(
        // textField: iatData.senderMAC,
        geometry: _geometry,
        iconImage: "assets/images/dogpin_${iatData.senderColor}.png",
      ));

      // controller.addSymbol(SymbolOptions(
      //   // textField: iatData.senderMAC,
      //   geometry: geometry,
      //   iconImage: "assets/images/dogpin_${iatData.senderColor}.png",
      // ));

      // controller.addSymbol(SymbolOptions(
      //   // textField: iatData.senderMAC,
      //   geometry: geometry,
      //   iconImage: "assets/images/dogpin_${iatData.senderColor}.png",
      // ));
      //  controller.addSymbol(SymbolOptions(
      //   // textField: iatData.senderMAC,
      //   geometry: geometry,
      //   iconImage: "assets/images/dogpin_${iatData.senderColor}.png",
      // ));

      // controller.updateSymbol(symbol, changes)
      // controller.symbols.contains(value)

      // controller.addSymbol(SymbolOptions(
      //   geometry: geometry,
      //   iconImage: "assets/images/dogpin_purple.png",
      // ));
      // controller.addSymbol(SymbolOptions(
      //   geometry: LatLng(_center.latitude + sin(2 * pi / 6.0) / 20.0,
      //       _center.longitude + cos(2 * pi / 6.0) / 20.0),
      //   iconImage: "assets/images/dogpin_green.png",
      // ));
      // controller.addSymbol(SymbolOptions(
      //   geometry: LatLng(_center.latitude + sin(3 * pi / 6.0) / 20.0,
      //       _center.longitude + cos(3 * pi / 6.0) / 20.0),
      //   iconImage: "assets/images/dogpin_red.png",
      // ));
      // controller.addSymbol(SymbolOptions(
      //   geometry: LatLng(_center.latitude + sin(4 * pi / 6.0) / 20.0,
      //       _center.longitude + cos(4 * pi / 6.0) / 20.0),
      //   iconImage: "assets/images/dogpin_orange.png",
      // ));
    }
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes =
        await rootBundle.load("assets/images/dogpin_purple.png");
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }
}
