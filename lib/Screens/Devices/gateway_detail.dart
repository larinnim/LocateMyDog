import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Services/database.dart';

// ignore: must_be_immutable
class GatewayDetails extends StatefulWidget {
  String title;
  GatewayDetails({Key key, @required this.title}) : super(key: key);

  @override
  _GatewayDetailsState createState() => _GatewayDetailsState();
}

class _GatewayDetailsState extends State<GatewayDetails> {
  CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _renameController = TextEditingController();

  void updateName() async {
    await DatabaseService(uid:_firebaseAuth.currentUser.uid).updateGatewayName(_renameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            }),
      ),
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: 30.0,
          ),
          Icon(
            Icons.router_outlined,
            color: Colors.green,
            size: 100.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
            child: Text(
              'Rename'.toUpperCase(),
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {
              _displayTextInputDialog(context);
            },
          ),
          SizedBox(
            height: 30.0,
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  tileColor: Colors.white70,
                  leading: Icon(LineAwesomeIcons.wifi),
                  title: Text('Wifi Connection Status'),
                  trailing: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    child: Text(
                      'Connected'.toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {},
                  ),
                ),
                ListTile(
                    tileColor: Colors.white70,
                    leading: Icon(LineAwesomeIcons.bluetooth),
                    title: Text('Bluetooth Connection Status'),
                    trailing: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                      child: Text(
                        'Connected'.toUpperCase(),
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {},
                    )),
                ListTile(
                  tileColor: Colors.white70,
                  leading: Icon(LineAwesomeIcons.battery_1_2_full),
                  title: Text('Baterry Level'),
                  trailing: Text('50%'),
                ),
                SizedBox(
                  height: 30.0,
                ),
                ListTile(
                  tileColor: Colors.white70,
                  title: Text('Manufacturer'),
                  trailing: Text('Majel Tecnologies'),
                ),
                ListTile(
                  tileColor: Colors.white70,
                  title: Text('Model'),
                  trailing: Text('1.0'),
                ),
                ListTile(
                  tileColor: Colors.white70,
                  title: Text('Serial Number'),
                  trailing: Text('ABCD12345'),
                ),
              ],
            ),
          ),
        ],
      )),
      endDrawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                  height: 80.0,
                  child: DrawerHeader(
                    child: Text('Devices'.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    decoration: BoxDecoration(color: Colors.red[300]),
                  ),
                  margin: EdgeInsets.all(0.0),
                  padding: EdgeInsets.all(0.0)),
              ListTile(
                title: Text('Item 1'.toUpperCase(),
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                leading: Icon(LineAwesomeIcons.mobile_phone),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Item 2'.toUpperCase(),
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                leading: Icon(LineAwesomeIcons.mobile_phone),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    locationDB
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((DocumentSnapshot querySnapshot) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rename Gateway'),
            content: TextField(
              controller: _renameController,
              decoration: InputDecoration(
                  hintText: querySnapshot.data()["gateway"]["name"]),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  print(_renameController.text);
                  updateName();
                  setState(() {
                    widget.title = _renameController.text;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
  }
}
