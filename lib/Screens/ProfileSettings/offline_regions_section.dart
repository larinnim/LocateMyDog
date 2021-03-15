import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class OfflineMapRegion {
  final LatLng latitude_longitude;

  OfflineMapRegion(this.latitude_longitude);
}

class OfflineRegionMapSelection extends StatefulWidget {
  // Declare a field that holds the Todo.
  final OfflineMapRegion offlineRegion;

  OfflineRegionMapSelection({this.offlineRegion});

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                child: MapboxMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.offlineRegion.latitude_longitude,
                    zoom: 12,
                  ),
                  minMaxZoomPreference: MinMaxZoomPreference(
                    13,
                    15,
                  ),
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
                            text: "Download   ",
                            style: TextStyle(fontSize: 20)),
                        WidgetSpan(
                          child: Icon(Icons.download_rounded, size: 25),
                        ),
                      ],
                    ),
                  ),
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.red[300])))),
                  onPressed: () => null),
            ),
          ],
        ));
  }
}
