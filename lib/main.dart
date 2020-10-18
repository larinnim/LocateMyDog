import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:provider/provider.dart';
import 'locator.dart';
import 'Services/bluetooth_conect.dart';
// void main() => runApp(MyApp());

void main() async {
  // void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: BleModel(),
        ),
      ], child:
    
     MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locate My Pet',
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Material(child: Wrapper()),
      // debugShowCheckedModeBanner: false,
      // title: 'Flutter Maps',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      // home: MyHomePage(title: 'Locate My Dog'),
    ));
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
  // StreamSubscription _locationSubscription;
  // Location _locationTracker = Location();
  // Marker marker;
  // Circle circle;
  // GoogleMapController _controller;
  // Map<PolylineId, Polyline> _mapPolylines = {};
  // int _polylineIdCounter = 1;
  // final List<LatLng> points = <LatLng>[];

  // static final CameraPosition initialLocation = CameraPosition(
  //   target: LatLng(46.520227, -80.954182),
  //   zoom: 14.4746,
  // );

  // Future<Uint8List> getMarker() async {
  //   ByteData byteData =
  //       await DefaultAssetBundle.of(context).load("assets/dog.png");
  //   return byteData.buffer.asUint8List();
  // }

  // void updatePolygon(LocationData newLocalData) {
  //   final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
  //   _polylineIdCounter++;
  //   final PolylineId polylineId = PolylineId(polylineIdVal);
  //   points.add(LatLng(newLocalData.latitude, newLocalData.longitude));

  //   final Polyline polyline = Polyline(
  //     polylineId: polylineId,
  //     consumeTapEvents: true,
  //     color: Colors.red,
  //     width: 5,
  //     points: points
  //   );

  //   setState(() {
  //     _mapPolylines[polylineId] = polyline;
  //   });
  // }

  // void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
  //   LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
  //   this.setState(() {
  //     marker = Marker(
  //         markerId: MarkerId("home"),
  //         position: latlng,
  //         rotation: newLocalData.heading,
  //         draggable: false,
  //         zIndex: 2,
  //         flat: true,
  //         anchor: Offset(0.5, 0.5),
  //         icon: BitmapDescriptor.fromBytes(imageData));
  //     /*
  //     circle = Circle(
  //         circleId: CircleId("car"),
  //         radius: newLocalData.accuracy,
  //         zIndex: 1,
  //         strokeColor: Colors.blue,
  //         center: latlng,
  //         fillColor: Colors.blue.withAlpha(70));
  //         */
  //   });
  // }

  // void getCurrentLocation() async {
  //   try {
  //     Uint8List imageData = await getMarker();
  //     var location = await _locationTracker.getLocation();

  //     updateMarkerAndCircle(location, imageData);

  //     if (_locationSubscription != null) {
  //       _locationSubscription.cancel();
  //     }

  //     _locationSubscription =
  //         _locationTracker.onLocationChanged().listen((newLocalData) {
  //       if (_controller != null) {
  //         _controller.animateCamera(CameraUpdate.newCameraPosition(
  //             new CameraPosition(
  //                 bearing: 192.8334901395799,
  //                 target: LatLng(newLocalData.latitude, newLocalData.longitude),
  //                 tilt: 0,
  //                 zoom: 18.00)));
  //         updateMarkerAndCircle(newLocalData, imageData);
  //         updatePolygon(newLocalData);
  //       }
  //     });
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       debugPrint("Permission Denied");
  //     }
  //   }
  // }

  // @override
  // void dispose() {
  //   if (_locationSubscription != null) {
  //     _locationSubscription.cancel();
  //   }
  //   super.dispose();
  // }

//   @override
//   Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   body: GoogleMap(
    //     mapType: MapType.hybrid,
    //     initialCameraPosition: initialLocation,
    //     markers: Set.of((marker != null) ? [marker] : []),
    //     circles: Set.of((circle != null) ? [circle] : []),
    //     polylines: Set<Polyline>.of(_mapPolylines.values),
    //     onMapCreated: (GoogleMapController controller) {
    //       _controller = controller;
    //     },
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //       child: Icon(Icons.location_searching),
    //       onPressed: () {
    //         getCurrentLocation();
    //       }),
    // );
//   }
// }
