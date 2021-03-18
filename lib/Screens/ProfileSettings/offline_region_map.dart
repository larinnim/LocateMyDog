import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:math';

import 'offline_regions.dart';

class OfflineRegionMap extends StatefulWidget {
  OfflineRegionMap(this.item);

  final OfflineRegionListItem item;

  @override
  _OfflineRegionMapState createState() => _OfflineRegionMapState();
}

class _OfflineRegionMapState extends State<OfflineRegionMap> {

  MapboxMapController controller;
  int symbolCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Region: ${widget.item.name}'),
      ),
      body: MapboxMap(
        onMapCreated: _onMapCreated,
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
      ),
    );
  }

  LatLng get _center {
    final bounds = widget.item.offlineRegionDefinition.bounds;
    final lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    _add();
  }

  void _add() {
      LatLng geometry = LatLng(
         _center.latitude,
        _center.longitude,
        // _center.latitude + sin(symbolCount * pi / 6.0) / 20.0,
        // _center.longitude + cos(symbolCount * pi / 6.0) / 20.0,
      );
      controller.addSymbol(
          SymbolOptions(
            geometry: geometry,
            iconImage: 'airport-15',
            fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
            textField: 'Airport',
            textSize: 12.5,
            textOffset: Offset(0, 0.8),
            textAnchor: 'top',
            textColor: '#000000',
            textHaloBlur: 1,
            textHaloColor: '#ffffff',
            textHaloWidth: 0.8,
          ),
          // {'count': availableNumbers.first}
          );
    
  }
}
