import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Screens/Devices/functions_aux.dart';
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
  Map<String, List<Line>> _polylines = <String, List<Line>>{};
  Map<String, List<LatLng>> _polyLinesLatLongs = <String, List<LatLng>>{};
  CollectionReference sendersCollection =
      FirebaseFirestore.instance.collection('sender');
  @override
  void initState() {
    super.initState();
    _initSenders(); // set context read
  }

  @override
  void dispose() {
    // if (controller != null) {
    //   controller.removeListener(_onMapChanged);
    // }
    super.dispose();
  }

  Future<void> _initSenders() async {
    await sendersCollection
        .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var tempIatData = new IATData(
            senderMAC: doc["senderMac"],
            latitude: doc['Location']['Latitude'],
            longitude: doc['Location']['Longitude'],
            locationTimestamp: doc['LocationTimestamp'] != ""
                ? DateTime.parse(doc['LocationTimestamp'])
                    .millisecondsSinceEpoch
                : 0,
            gatewayMAC: doc['gatewayID'],
            trackerBatteryLevel: doc['batteryLevel'],
            gatewayBatteryLevel:
                0, //Doesnt matter which value we just want the location,
            senderColor: doc['color'],
            escaped: doc['escaped']);
        // setState(() {
          _add(tempIatData);
        // });
      });
    });
    readDatabase(); // set context read
  }

  void _addPolyline(IATData iatData) async {
    if (_finishedLoadingMap == true) {
      // if (_polylines.length > 0) {
      //   if (_polylines.containsKey(iatData.senderMAC!)) {
      //     setState(() async {
      //       await controller.updateLine( _polylines[iatData.senderMAC!]!, changes)
      //        ,
      //         SymbolOptions(geometry: _geometry),
      //       );
      //     });
      //   }
      // }
      _polyLinesLatLongs
          .putIfAbsent(iatData.senderMAC ?? "", () => <LatLng>[])
          .add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));

      Line newLine = await controller.addLine(
        LineOptions(
            geometry: _polyLinesLatLongs[iatData.senderMAC ?? ""]!,
            // geometry: [
            //   LatLng(46.5273986264652, -80.9562962707178),
            //   LatLng(46.521364581404235, -80.94025190931048),
            //   LatLng(46.52189712161899, -80.95885883495315),
            // ],
            lineColor: AuxFunc().colorCodeFromName(iatData.senderColor ?? ""),
            lineWidth: 8.0,
            lineOpacity: 1,
            draggable: false),
      );
      // Line newLine = await controller.addLine(
      //   LineOptions(
      //       geometry: [
      //         LatLng(46.5273986264652, -80.9562962707178),
      //         LatLng(46.521364581404235, -80.94025190931048),
      //         LatLng(46.52189712161899, -80.95885883495315),
      //       ],
      //       lineColor: '#ff00e676',
      //       lineWidth: 8.0,
      //       lineOpacity: 1,
      //       draggable: false),
      // );
      _polylines
          .putIfAbsent(iatData.senderMAC ?? "", () => <Line>[])
          .add(newLine);
    }
  }

  void _addPolylinex(IATData iatData) {
    // final List<LatLng> _points = <LatLng>[];

    // if (_polylines.length > 0) {
    //   if (!_polylines.containsKey(iatData.senderMAC) &&
    //       iatData.latitude != 0 &&
    //       iatData.longitude != 0) {
    // if (_points[iatData.senderMAC]!.last.latitude != iatData.latitude ||
    //     _points[iatData.senderMAC]!.last.longitude != iatData.longitude) {

    // setState(() async {
    if (_finishedLoadingMap == true) {
      this.controller.addLine(
            LineOptions(
                geometry: [
                  LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0),
                ],
                lineColor:
                    AuxFunc().colorCodeFromName(iatData.senderColor ?? ""),
                lineWidth: 28,
                lineOpacity: 1,
                draggable: false),
          );
      // .then((newLine) => {
      //       _polylines
      //           .putIfAbsent(iatData.senderMAC ?? "", () => <Line>[])
      //           .add(newLine)
      //     });
    }

    // _polylines
    //     .putIfAbsent(iatData.senderMAC ?? "", () => <Line>[])
    //     .add(newLine);
    // });
  }

  //       final Polyline polyline = Polyline(
  //         polylineId: polylineId,
  //         consumeTapEvents: true,
  //         color: AuxFunc().getColor(iatData.senderColor),
  //         width: 5,
  //         points: _points[iatData.senderMAC]!,
  //         // onTap: () {
  //         //   _onPolylineTapped(polylineId);
  //         // },
  //       );
  //       setState(() {
  //         polylines[polylineId] = polyline;
  //       });
  //       // _points.add(LatLng(iatData.latitude ?? 0, iatDat  a.longitude ?? 0));
  //       // }
  //     } else if (_points.containsKey(iatData.senderMAC) &&
  //             iatData.latitude != 0 &&
  //             iatData.longitude != 0 &&
  //             _points[iatData.senderMAC]!.last.latitude != iatData.latitude ||
  //         _points[iatData.senderMAC]!.last.longitude != iatData.longitude) {
  //       if (_calculateMeters(_points[iatData.senderMAC]!.last,
  //               LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0)) >
  //           15) {
  //         _points
  //             .putIfAbsent(iatData.senderMAC ?? "", () => <LatLng>[])
  //             .add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
  //         final Polyline polyline = Polyline(
  //           polylineId: polylineId,
  //           consumeTapEvents: true,
  //           color: AuxFunc().getColor(iatData.senderColor),
  //           width: 5,
  //           points: _points[iatData.senderMAC]!,
  //           // onTap: () {
  //           //   _onPolylineTapped(polylineId);
  //           // },
  //         );
  //         setState(() {
  //           polylines[polylineId] = polyline;
  //         });
  //         // _points.add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
  //       }
  //     }
  //   } else {
  //     if (iatData.latitude != 0 && iatData.longitude != 0) {
  //       _points
  //           .putIfAbsent(iatData.senderMAC ?? "", () => <LatLng>[])
  //           .add(LatLng(iatData.latitude ?? 0, iatData.longitude ?? 0));
  //       // _points.add(LatLng(iatData.latitude ?? 0, iatDat  a.longitude ?? 0));
  //       final Polyline polyline = Polyline(
  //         polylineId: polylineId,
  //         consumeTapEvents: true,
  //         color: AuxFunc().getColor(iatData.senderColor),
  //         width: 5,
  //         points: _points[iatData.senderMAC]!,
  //         // onTap: () {
  //         //   _onPolylineTapped(polylineId);
  //         // },
  //       );
  //       setState(() {
  //         polylines[polylineId] = polyline;
  //       });
  //     }
  //   }
  // }
  void _add(IATData iatData) async {
    if (_finishedLoadingMap == true) {
      LatLng _geometry = LatLng(
        iatData.latitude ?? 0,
        iatData.longitude ?? 0,
      );
      if (_symbols.length > 0) {
        if (_symbols.containsKey(iatData.senderMAC!)) {
          setState(() async {
            await controller.updateSymbol(
              _symbols[iatData.senderMAC!]!,
              SymbolOptions(geometry: _geometry),
            );
          });
        }
      }
      _symbols[iatData.senderMAC!] = await controller.addSymbol(SymbolOptions(
        geometry: _geometry,
        iconImage: "assets/images/dogpin_${iatData.senderColor}.png",
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _add(Provider.of<IATDataModel>(context, listen: true).iatData);
    // _addPolyline();

    _addPolyline(Provider.of<IATDataModel>(context, listen: true).iatData);
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

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes =
        await rootBundle.load("assets/images/dogpin_purple.png");
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }
}
