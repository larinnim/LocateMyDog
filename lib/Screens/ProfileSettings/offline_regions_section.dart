import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'offline_regions.dart';

class OfflineRegionMapSelection extends StatefulWidget {
  @override
  _OfflineRegionMapSelectionState createState() =>
      _OfflineRegionMapSelectionState();
}

class _OfflineRegionMapSelectionState extends State<OfflineRegionMapSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Region Selection'),
        centerTitle: true,
      ),
      body:
          //  Center(
          //         child: Text('HI'),
          //       )
          FutureBuilder(
              future: _center,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  // while data is loading:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  // data loaded:
                  return Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: MapboxMap(
                            initialCameraPosition: CameraPosition(
                              target: snapshot.data,
                              zoom: 12,
                            ),
                            minMaxZoomPreference: MinMaxZoomPreference(
                              12,
                              18,
                            ),
                            // styleString: widget.item.offlineRegionDefinition.mapStyleUrl,
                            // cameraTargetBounds: CameraTargetBounds(
                            //   widget.item.offlineRegionDefinition.bounds,
                            // ),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.098,
                        child: TextButton(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Download   ",style: TextStyle(fontSize: 20)
                                  ),
                                  WidgetSpan(
                                    child: Icon(Icons.download_rounded, size: 25),
                                  ),
                                ],
                              ),

                            ),
                            // Text("Download".toUpperCase(),

                            //     style: TextStyle(fontSize: 20)),
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(
                                            color: Colors.red[300])))),
                            onPressed: () => null),
                      ),
                    ],
                  );
                }
              }),
    );
  }

  Future<LatLng> get _center async {
    // final bounds = widget.item.offlineRegionDefinition.bounds;
    Position position = await _determinePosition();

    final lat = position.latitude;
    final lng = position.longitude;
    return LatLng(lat, lng);
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
