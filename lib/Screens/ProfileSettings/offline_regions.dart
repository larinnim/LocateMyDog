import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions_section.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:get/get.dart';
import 'offline_region_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart' as places;
import 'dart:io';

const kGoogleApiKey = 'AIzaSyA7Rxja6yV7o3YdM8O8bPbQV8r3QcNepdY';
places.GoogleMapsPlaces _places =
    places.GoogleMapsPlaces(apiKey: kGoogleApiKey);

// final String defaultLocale = Get.deviceLocale.toLanguageTag();

final LatLngBounds hawaiiBounds = LatLngBounds(
  southwest: const LatLng(17.26672, -161.14746),
  northeast: const LatLng(23.76523, -153.74267),
);

final LatLngBounds santiagoBounds = LatLngBounds(
  southwest: const LatLng(-33.5597, -70.49102),
  northeast: const LatLng(-33.33282, -153.74267),
);

final LatLngBounds aucklandBounds = LatLngBounds(
  southwest: const LatLng(-36.87838, 174.73205),
  northeast: const LatLng(-36.82838, 174.79745),
);

final List<OfflineRegionDefinition> regionDefinitions = [
  OfflineRegionDefinition(
    bounds: hawaiiBounds,
    minZoom: 3.0,
    maxZoom: 8.0,
    mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
  ),
  OfflineRegionDefinition(
    bounds: santiagoBounds,
    minZoom: 10.0,
    maxZoom: 16.0,
    mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
  ),
  OfflineRegionDefinition(
    bounds: aucklandBounds,
    minZoom: 13.0,
    maxZoom: 16.0,
    mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
  ),
];

final List<String> regionNames = ['Hawaii', 'Santiago', 'Auckland'];

class OfflineRegionListItem {
  OfflineRegionListItem({
    @required this.offlineRegionDefinition,
    @required this.downloadedId,
    @required this.isDownloading,
    @required this.name,
    @required this.estimatedTiles,
  });

  final OfflineRegionDefinition offlineRegionDefinition;
  final int downloadedId;
  final bool isDownloading;
  final String name;
  final int estimatedTiles;

  OfflineRegionListItem copyWith({
    int downloadedId,
    bool isDownloading,
  }) =>
      OfflineRegionListItem(
        offlineRegionDefinition: offlineRegionDefinition,
        name: name,
        estimatedTiles: estimatedTiles,
        downloadedId: downloadedId,
        isDownloading: isDownloading ?? this.isDownloading,
      );

  bool get isDownloaded => downloadedId != null;
}

final List<OfflineRegionListItem> allRegions = [
  OfflineRegionListItem(
    offlineRegionDefinition: regionDefinitions[0],
    downloadedId: null,
    isDownloading: false,
    name: regionNames[0],
    estimatedTiles: 61,
  ),
  OfflineRegionListItem(
    offlineRegionDefinition: regionDefinitions[1],
    downloadedId: null,
    isDownloading: false,
    name: regionNames[1],
    estimatedTiles: 3580,
  ),
  OfflineRegionListItem(
    offlineRegionDefinition: regionDefinitions[2],
    downloadedId: null,
    isDownloading: false,
    name: regionNames[2],
    estimatedTiles: 202,
  ),
];

class OfflineRegionBody extends StatefulWidget {
  const OfflineRegionBody();

  @override
  _OfflineRegionsBodyState createState() => _OfflineRegionsBodyState();
}

class _OfflineRegionsBodyState extends State<OfflineRegionBody> {
  List<OfflineRegionListItem> _items = List();
  final TextEditingController _controller = new TextEditingController();

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _updateListOfRegions();
  }

  Future<Null> displayPrediction(places.Prediction p) async {
    if (p != null) {
      places.PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      List<Location> locations = await locationFromAddress(p.description);

      // var address = await Geocoder.local.findAddressesFromQuery(p.description);

      locations.map((value) {
        print(value.latitude);
        print(value.longitude);
        print(value.timestamp);
      });

      print(lat);
      print(lng);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OfflineRegionMapSelection(
            offlineRegion: OfflineMapRegion(LatLng(lat, lng)),
          ),
        ),
      );
    }
  }

  void onError(places.PlacesAutocompleteResponse response) {
    Get.dialog(Text(response.errorMessage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'offline_map'.tr,
          style: TextStyle(color: Colors.green),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () async {
                places.Prediction p = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: kGoogleApiKey,
                    mode: Mode.fullscreen,
                    language: Get.locale.languageCode,
                    onError: onError,
                    components: [
                      places.Component(places.Component.country,
                          Get.deviceLocale.countryCode)
                    ]);
                displayPrediction(p);
                // showCupertinoDialog(
                //   context: context,
                //   builder: (_) => CupertinoAlertDialog(
                //     title: new Text("Type the address\n"),
                //     content: CupertinoTextField(
                //       prefix: Padding(
                //         padding: EdgeInsets.all(8.0),
                //       ),
                //       clearButtonMode: OverlayVisibilityMode.editing,
                //       controller: _controller,
                //       placeholder: "Type the address",
                //     ),
                // actions: <Widget>[
                // CupertinoDialogAction(
                //   isDefaultAction: true,
                //   child: Text("Cancel"),
                //   onPressed: () => Navigator.pop(context),
                // ),
                // CupertinoDialogAction(
                //   child: Text("Search"),
                //   onPressed: () async {
                //     places.Prediction p = await PlacesAutocomplete.show(
                //         context: context, apiKey: kGoogleApiKey);
                //     displayPrediction(p);
                //   },
                // )
                // ],

                // title: Text('TextField in Dialog'),
                // content: TextField(
                //   controller: null,
                //   decoration:
                //       InputDecoration(hintText: "Text Field in Dialog"),
                // ),
                // actions: <Widget>[
                //   FlatButton(
                //     child: Text('CANCEL'),
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //   ),
                //   FlatButton(
                //     child: Text('OK'),
                //     onPressed: () {
                //       // print(_textFieldController.text);
                //       Navigator.pop(context);
                //     },
                //   ),
                // ],
                //   ),
                // );

                // Navigator.of(context).push(MaterialPageRoute(
                //   builder: (context) =>
                //   OfflineRegionMapSelection(),
                // ));

                // _onSettingsPressed();
              },
              child: Icon(Icons.add_circle_outline),
            ),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.red[200],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            itemCount: _items.length,
            itemBuilder: (context, index) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () => _goToMap(_items[index]),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _items[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Est. tiles: ${_items[index].estimatedTiles}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _items[index].isDownloading
                    ? Container(
                        child: CircularProgressIndicator(),
                        height: 16,
                        width: 16,
                      )
                    : IconButton(
                        icon: Icon(
                          _items[index].isDownloaded
                              ? Icons.delete
                              : Icons.file_download,
                        ),
                        onPressed: _items[index].isDownloaded
                            ? () => _deleteRegion(_items[index], index)
                            : () => _downloadRegion(_items[index], index),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _showDialog() async {
  //   await showDialog<String>(
  //     context: context,
  //     child: new AlertDialog(
  //       contentPadding: const EdgeInsets.all(16.0),
  //       content: new Row(
  //         children: <Widget>[
  //           new Expanded(
  //             child: new TextField(
  //               autofocus: true,
  //               decoration: new InputDecoration(
  //                   labelText: 'Full Name', hintText: 'eg. John Smith'),
  //             ),
  //           )
  //         ],
  //       ),
  //       actions: <Widget>[
  //         new FlatButton(
  //             child: const Text('CANCEL'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             }),
  //         new FlatButton(
  //             child: const Text('OPEN'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             })
  //       ],
  //     ),
  //   );
  // }

  void _updateListOfRegions() async {
    List<OfflineRegion> offlineRegions = await getListOfRegions(
        accessToken:
            "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w");
    List<OfflineRegionListItem> regionItems = [];
    for (var item in allRegions) {
      final offlineRegion = offlineRegions.firstWhere(
          (offlineRegion) => offlineRegion.metadata['name'] == item.name,
          orElse: () => null);
      if (offlineRegion != null) {
        regionItems.add(item.copyWith(downloadedId: offlineRegion.id));
      } else {
        regionItems.add(item);
      }
    }
    setState(() {
      _items.clear();
      _items.addAll(regionItems);
    });
  }

  void _downloadRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    try {
      final downloadingRegion = await downloadOfflineRegion(
        item.offlineRegionDefinition,
        metadata: {
          'name': regionNames[index],
        },
        accessToken:
            "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w",
      );
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              downloadedId: downloadingRegion.id,
            ));
      });
    } on Exception catch (_) {
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              downloadedId: null,
            ));
      });
      return;
    }
  }

  void _deleteRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    await deleteOfflineRegion(
      item.downloadedId,
      accessToken:
          "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w",
    );

    setState(() {
      _items.removeAt(index);
      _items.insert(
          index,
          item.copyWith(
            isDownloading: false,
            downloadedId: null,
          ));
    });
  }

  _goToMap(OfflineRegionListItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OfflineRegionMap(item),
      ),
    );
  }

  // _goToDownloadMap() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute<void>(
  //       builder: (_) => OfflineRegionMapSelection(offlineRegion: null,),
  //     ),
  //   );
  // }
}
