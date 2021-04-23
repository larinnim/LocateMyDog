// TODO ENABLE WHEN MAPBOX NULLSAFETY IS AVAILABLE

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
// import 'dart:math';

// import 'offline_regions.dart';

// class OfflineRegionMap extends StatefulWidget {
//   OfflineRegionMap(this.item);

//   final OfflineRegionListItem item;

//   @override
//   _OfflineRegionMapState createState() => _OfflineRegionMapState();
// }

// class _OfflineRegionMapState extends State<OfflineRegionMap> {
//   late MapboxMapController controller;
//   int symbolCount = 1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Offline Region: ${widget.item.name}'),
//       ),
//       body: MapboxMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _center,
//           zoom: widget.item.offlineRegionDefinition.minZoom,
//         ),
//         minMaxZoomPreference: MinMaxZoomPreference(
//           widget.item.offlineRegionDefinition.minZoom,
//           widget.item.offlineRegionDefinition.maxZoom,
//         ),
//         styleString: widget.item.offlineRegionDefinition.mapStyleUrl,
//         cameraTargetBounds: CameraTargetBounds(
//           widget.item.offlineRegionDefinition.bounds,
//         ),
//       ),
//     );
//   }

//   LatLng get _center {
//     final bounds = widget.item.offlineRegionDefinition.bounds;
//     final lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
//     final lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
//     return LatLng(lat, lng);
//   }

//   void _onMapCreated(MapboxMapController controller) {
//     this.controller = controller;
//     _add();
//   }

//   void _add() {
//     LatLng geometry = LatLng(
//       _center.latitude,
//       _center.longitude,
//       // _center.latitude + sin(symbolCount * pi / 6.0) / 20.0,
//       // _center.longitude + cos(symbolCount * pi / 6.0) / 20.0,
//     );
//     controller.addSymbol(SymbolOptions(
//       geometry: geometry,
//       iconImage: "assets/images/dogpin_purple.png",
//     ));
//     controller.addSymbol(SymbolOptions(
//       geometry: LatLng(_center.latitude + sin(2 * pi / 6.0) / 20.0,  _center.longitude + cos(2 * pi / 6.0) / 20.0),
//       iconImage: "assets/images/dogpin_green.png",
//     ));controller.addSymbol(SymbolOptions(
//       geometry: LatLng(_center.latitude + sin(3 * pi / 6.0) / 20.0,  _center.longitude + cos(3 * pi / 6.0) / 20.0),
//       iconImage: "assets/images/dogpin_red.png",
//     ));controller.addSymbol(SymbolOptions(
//       geometry: LatLng(_center.latitude + sin(4 * pi / 6.0) / 20.0,  _center.longitude + cos(4 * pi / 6.0) / 20.0),
//       iconImage: "assets/images/dogpin_orange.png",
//     ));
//   }

//   /// Adds an asset image to the currently displayed style
//   Future<void> addImageFromAsset(String name, String assetName) async {
//     final ByteData bytes =
//         await rootBundle.load("assets/images/dogpin_purple.png");
//     final Uint8List list = bytes.buffer.asUint8List();
//     return controller.addImage(name, list);
//   }
// }
