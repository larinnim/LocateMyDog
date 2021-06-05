
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/offline_regions_section.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'offline_region_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart' as places;

const kGoogleApiKey = 'AIzaSyA7Rxja6yV7o3YdM8O8bPbQV8r3QcNepdY';
places.GoogleMapsPlaces _places =
    places.GoogleMapsPlaces(apiKey: kGoogleApiKey);

// final String defaultLocale = Get.deviceLocale.toLanguageTag();

// final LatLngBounds hawaiiBounds = LatLngBounds(
//   southwest: const LatLng(17.26672, -161.14746),
//   northeast: const LatLng(23.76523, -153.74267),
// );

// final LatLngBounds santiagoBounds = LatLngBounds(
//   southwest: const LatLng(-33.5597, -70.49102),
//   northeast: const LatLng(-33.33282, -153.74267),
// );

// final LatLngBounds aucklandBounds = LatLngBounds(
//   southwest: const LatLng(-36.87838, 174.73205),
//   northeast: const LatLng(-36.82838, 174.79745),
// );

// final List<OfflineRegionDefinition> regionDefinitions = [
//   OfflineRegionDefinition(
//     bounds: hawaiiBounds,
//     minZoom: 3.0,
//     maxZoom: 8.0,
//     mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
//   ),
//   OfflineRegionDefinition(
//     bounds: santiagoBounds,
//     minZoom: 10.0,
//     maxZoom: 16.0,
//     mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
//   ),
//   OfflineRegionDefinition(
//     bounds: aucklandBounds,
//     minZoom: 13.0,
//     maxZoom: 16.0,
//     mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
//   ),
// ];

// final List<String> regionNames = ['Hawaii', 'Santiago', 'Auckland'];
final List<String?> regionNames = [];

class OfflineRegionListItem {
  OfflineRegionListItem({
    required this.offlineRegionDefinition,
    required this.downloadedId,
    required this.isDownloading,
    required this.name,
    // @required this.estimatedTiles,
  });

  final OfflineRegionDefinition offlineRegionDefinition;
  final int? downloadedId;
  final bool isDownloading;
  String? name;
  // final int estimatedTiles;

  OfflineRegionListItem copyWith({
    int? downloadedId,
    bool? isDownloading,
  }) =>
      OfflineRegionListItem(
        offlineRegionDefinition: offlineRegionDefinition,
        name: name,
        // estimatedTiles: estimatedTiles,
        downloadedId: downloadedId,
        isDownloading: isDownloading ?? this.isDownloading,
      );

  bool get isDownloaded => downloadedId != null;
}

// final List<OfflineRegionListItem> allRegions = [
// OfflineRegionListItem(
//   offlineRegionDefinition: regionDefinitions[0],
//   downloadedId: null,
//   isDownloading: false,
//   name: regionNames[0],
//   // estimatedTiles: 61,
// ),
//   OfflineRegionListItem(
//     offlineRegionDefinition: regionDefinitions[1],
//     downloadedId: null,
//     isDownloading: false,
//     name: regionNames[1],
//     // estimatedTiles: 3580,
//   ),
//   OfflineRegionListItem(
//     offlineRegionDefinition: regionDefinitions[2],
//     downloadedId: null,
//     isDownloading: false,
//     name: regionNames[2],
//     // estimatedTiles: 202,
//   ),
// ];

class OfflineRegionBody extends StatefulWidget {
  const OfflineRegionBody();

  @override
  _OfflineRegionsBodyState createState() => _OfflineRegionsBodyState();
}

class _OfflineRegionsBodyState extends State<OfflineRegionBody> {
  List<OfflineRegionListItem> _items = [];
  bool updatedName = false;
  String newMapName = '';
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _updateListOfRegions();
  }

  Future<Null> displayPrediction(places.Prediction? p) async {
    if (p != null) {
      places.PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);

      // var placeId = p.placeId;
      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;

      List<Location> locations = await locationFromAddress(p.description!);

      // var address = await Geocoder.local.findAddressesFromQuery(p.description);

      locations.map((value) {
        print(value.latitude);
        print(value.longitude);
        print(value.timestamp);
      });

      print(lat);
      print(lng);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OfflineRegionMapSelection(
            offlineRegion: OfflineMapRegion(LatLng(lat, lng)),
          ),
        ),
      );
    }
  }

  void onError(places.PlacesAutocompleteResponse response) {
    Get.dialog(Text(response.errorMessage!));
  }

  Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
   final connectionStatus =
        Provider.of<ConnectionStatusModel>(context, listen: false);
        
    connectionStatus.initConnectionListen();
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
                bool isConnected = await checkConnection();
                if(!isConnected){
                  showCupertinoDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                          title: Text("Error"),
                          content: Text(
                              "You are offline. Please connect to an active internet connection to search places."),
                          actions: [
                            // Close the dialog
                            // You can use the CupertinoDialogAction widget instead
                            CupertinoButton(
                                child: Text('Dismiss'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ],
                  ));
                }else{
                  places.Prediction? p = await PlacesAutocomplete.show(
                    offset: 0,
                    radius: 1000,
                    types: []
                    context: context,
                    strictbounds: false,
                    region:'ar',
                    apiKey: kGoogleApiKey,
                    mode: Mode.fullscreen,
                    language: Get.locale!.languageCode,
                    onError: onError,
                    components: [
                      places.Component(places.Component.country,
                          Get.deviceLocale!.countryCode!)
                    ]);
                  displayPrediction(p);
                }
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
                InkWell(
                  onTap: () {
                    Get.defaultDialog(
                        title: 'Rename Map',
                        textConfirm: 'Save',
                        buttonColor: Colors.red[300],
                        textCancel: 'Cancel',
                        onConfirm: () => updateMapName(
                            _items[index], textController.text, index),
                        cancelTextColor: Colors.red,
                        // backgroundColor: Colors.red[200],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: textController,
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  labelText: _items[index].name,
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintMaxLines: 1,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.green, width: 4.0))),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                          ],
                        ),
                        radius: 10.0);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        updatedName ? newMapName : _items[index].name!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // Text(
                      //   'Est. tiles: ${_items[index].estimatedTiles}',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ],
                  ),
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
                            ? () async {
                              
                                _deleteRegion(_items[index], index);
                            } 
                            : () async {
                              // bool isConnected = await checkConnection();
                              // if(!isConnected){
                              //   showCupertinoDialog(
                              //     context: context,
                              //     builder: (_) => CupertinoAlertDialog(
                              //           title: Text("Error"),
                              //           content: Text(
                              //               "You are offline. Please connect to an active internet connection to download the Map."),
                              //           actions: [
                              //             // Close the dialog
                              //             // You can use the CupertinoDialogAction widget instead
                              //             CupertinoButton(
                              //                 child: Text('Dismiss'),
                              //                 onPressed: () {
                              //                   Navigator.of(context).pop();
                              //                 }),
                              //           ],
                              //   ));
                              // }else{
                                _downloadRegion(_items[index], index);
                              // }
                            }
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateMapName(
      OfflineRegionListItem item, String mapName, int index) async {
    await updateOfflineRegionMetadata(item.downloadedId!, {'name': mapName},
        accessToken:
            "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w");
    setState(() {
      _items[index].name = mapName;
      // updatedName = true;
      // newMapName = mapName;
    });
    Navigator.pop(context);
  }

  void _updateListOfRegions() async {
    List<OfflineRegion> offlineRegions = await getListOfRegions(
        accessToken:
            "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w");
    List<OfflineRegionListItem> regionItems = [];

    for (var region in offlineRegions) {
      regionItems.add(OfflineRegionListItem(
        offlineRegionDefinition: OfflineRegionDefinition(
          bounds: region.definition.bounds,
          minZoom: region.definition.minZoom,
          maxZoom: region.definition.maxZoom,
          mapStyleUrl: region.definition.mapStyleUrl,
        ),
        downloadedId: region.id,
        isDownloading: false,
        name: region.metadata['name'],
      ));
      regionNames.add(region.metadata['name']);
    }
    // setState(() {
    // offlineRegions.map((region) {
    //   _items.add(OfflineRegionListItem(
    //     offlineRegionDefinition: OfflineRegionDefinition(
    //       bounds: region.definition.bounds,
    //       minZoom: region.definition.minZoom,
    //       maxZoom: region.definition.maxZoom,
    //       mapStyleUrl: region.definition.mapStyleUrl,
    //     ),
    //     downloadedId: region.id,
    //     isDownloading: false,
    //     name: region.metadata['name'],
    //   ));
    // });
    // });
    // for (var item in allRegions) {
    //   final offlineRegion = offlineRegions.firstWhere(
    //       (offlineRegion) => offlineRegion.metadata['name'] == item.name,
    //       orElse: () => null);
    //   if (offlineRegion != null) {
    //     regionItems.add(item.copyWith(downloadedId: offlineRegion.id));
    //   } else {
    //     regionItems.add(item);
    //   }
    // }
    setState(() {
      _items.clear();
      _items.addAll(regionItems);
    });
    // setState(() {
    //   _items;
    // });
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
      item.downloadedId!,
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
}
