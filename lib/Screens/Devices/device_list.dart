import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Devices/gateway_detail.dart';

import '../loading.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  CollectionReference gatewayCollection =
      FirebaseFirestore.instance.collection('gateway');

  @override
  void initState() {
    super.initState();
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
        body: StreamBuilder<QuerySnapshot>(
            stream: gatewayCollection.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.separated(
                              itemCount: snapshot.data!.docs.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(height: 1),
                              itemBuilder: (context, index) {
                                return Column(children: <Widget>[
                                  SizedBox(height: 20.0),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey[200]!,
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
                                        "Gateway: " +
                                            snapshot.data!.docs[index]['name'],
                                        style: TextStyle(fontSize: 25),
                                      ),
                                      trailing:
                                          Icon(Icons.arrow_forward_ios_rounded),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GatewayDetails(
                                                        title: snapshot.data!
                                                                .docs[index]
                                                            ['name'],
                                                        gatewayMAC: snapshot.data!.docs[index]['gatewayMAC'])));
                                      },
                                    ),
                                  )
                                ]);
                              })),
                    ),
                  ],
                ));
              } else {
                return Loading();
              }
            }));
  }
}
