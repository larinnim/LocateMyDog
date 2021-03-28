import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Devices/gateway_detail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _gatewayName = '';

  @override
  void initState() {
    super.initState();
    _getGatewayName();
  }

  Future<void> _getGatewayName() async {
    await locationDB.doc(_firebaseAuth.currentUser.uid).get().then((value) {
      setState(() {
        _gatewayName = value.data()['gateway']['name'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Gateway"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              }),
        ),
        backgroundColor: Colors.grey[100],
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: list(),
              ),
            ),
          ],
        )));
  }

  list() {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(children: <Widget>[
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey[200],
                      blurRadius: 10,
                      spreadRadius: 3,
                      offset: Offset(3, 4))
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.router_outlined,
                  color: Colors.green,
                  size: 30.0,
                ),
                title: Text(
                  "Gateway: " + _gatewayName,
                  style: TextStyle(fontSize: 25),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GatewayDetails(title: _gatewayName)));
                },
              ),
            )
          ]);
        });
  }
}
