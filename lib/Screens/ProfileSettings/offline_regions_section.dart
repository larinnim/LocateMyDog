
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import './offline_regions.dart';

class OfflineMapRegion {
  final LatLng latitude_longitude;

  OfflineMapRegion(this.latitude_longitude);
}

class OfflineRegionMapSelection extends StatefulWidget {
  // Declare a field that holds the Todo.
  final OfflineMapRegion? offlineRegion;

  OfflineRegionMapSelection({this.offlineRegion});

  @override
  _OfflineRegionMapSelectionState createState() =>
      _OfflineRegionMapSelectionState();
}

class _OfflineRegionMapSelectionState extends State<OfflineRegionMapSelection> {
  late MapboxMapController mapController;
  int _numberOfRegions = 0;
  LatLngBounds? mapBounds;
  CameraPosition? _position;

  @override
  void initState() {
    super.initState();
    _getListOfRegions();
  }

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
                  onMapCreated: onMapCreated,
                  trackCameraPosition: true,
                  initialCameraPosition: CameraPosition(
                    target: widget.offlineRegion!.latitude_longitude,
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
                              side: BorderSide(color: Colors.red[300]!)))),
                  onPressed: () {
                    _downloadRegion();
                  }),
            ),
          ],
        ));
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
  }

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();
    });
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;

    if (mapController.isCameraMoving) {
      mapController.getVisibleRegion().then((newLatLngBounds) {
        mapBounds = newLatLngBounds;

        // double n_lat = newLatLngBounds.northeast.latitude;
        // double n_lng = newLatLngBounds.northeast.longitude;
        // double s_lat = newLatLngBounds.southwest.latitude;
        // double s_lng = newLatLngBounds.southwest.longitude;

        // mapController.moveCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        //     southwest: LatLng(s_lat, s_lng), northeast: LatLng(n_lat, n_lng))));
      });
    }
  }

  void _downloadRegion() async {
    // setState(() {
    //   _items.removeAt(index);
    //   _items.insert(index, item.copyWith(isDownloading: true));
    // });

    try {

      if (mapBounds == null) {
        mapBounds = await mapController.getVisibleRegion();
      }

      final downloadingRegion = await downloadOfflineRegion(
        OfflineRegionDefinition(
          bounds: mapBounds!,
          minZoom: _position!.zoom - 1,
          maxZoom: _position!.zoom + 1,
          mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
        ),
        metadata: {
          'name': 'Map ' + _numberOfRegions.toString(),

          // 'name': 'Map ' + _numberOfRegions.toString(),
        },
        accessToken:
            "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w",
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OfflineRegionBody(),
        ),
      );
      // setState(() {
      //   _items.removeAt(index);
      //   _items.insert(
      //       index,
      //       item.copyWith(
      //         isDownloading: false,
      //         downloadedId: downloadingRegion.id,
      //       ));
      // });
    } on Exception catch (exception) {
      print(exception.toString());

      // setState(() {
      //   _items.removeAt(index);
      //   _items.insert(
      //       index,
      //       item.copyWith(
      //         isDownloading: false,
      //         downloadedId: null,
      //       ));
      // });
      return;
    } catch (error) {
      print(error.toString());
      // executed for errors of all types other than Exception
    }
  }

  void _getListOfRegions() async {
    List<OfflineRegion> offlineRegions = await getListOfRegions(
        accessToken:
            "pk.eyJ1IjoibGFyaW5uaW1hbGhlaXJvcyIsImEiOiJja200M2s2NmQwMHQwMnZwdTUxZng1enFrIn0.ZeWhg3_t_0o4QOQooXf-9w");
    setState(() {
      _numberOfRegions = offlineRegions.length;
    });
  }
}
