import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import './gateway_detail.dart';
import 'functions_aux.dart';

// ignore: must_be_immutable
class DeviceDetail extends StatefulWidget {
  DeviceDetail(
      {Key key,
      this.title,
      this.color,
      this.battery,
      this.id,
      this.senderNumber,
      this.availableColors})
      : super(key: key);
  @override
  _DeviceDetailState createState() => _DeviceDetailState();

  // Fields in a Widget subclass are always marked "final".

  String title;
  Color color;
  int battery;
  String id;
  String senderNumber;
  List<Color> availableColors;
}

class _DeviceDetailState extends State<DeviceDetail> {
  CollectionReference locationDB =
      FirebaseFirestore.instance.collection('locateDog');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _renameController = TextEditingController();

  Color currentColor = Color(0xff443a49);
  Color _pickerColor = Color(0xff443a49);

  @override
  void initState() {
    super.initState();
    changeColor(widget.color);
  }

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => _pickerColor = color);
    DatabaseService(uid: _firebaseAuth.currentUser.uid).updateDeviceColor(
        AuxFunc().colorNamefromColor(_pickerColor), widget.senderNumber);
  }

  void updateName() async {
    await DatabaseService(uid: _firebaseAuth.currentUser.uid)
        .updateDeviceName(_renameController.text, widget.senderNumber);
  }

// raise the [showDialog] widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: 30.0,
          ),
          Icon(
            LineAwesomeIcons.mobile_phone,
            color: _pickerColor,
            size: 100.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ))),
                child: Text(
                  'Pick a color'.toUpperCase(),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            // child: ColorPicker(
                            //   pickerColor: pickerColor,
                            //   onColorChanged: changeColor,
                            //   showLabel: true,
                            //   pickerAreaHeightPercent: 0.8,
                            // ),
                            // Use Material color picker:
                            //
                            // child: MaterialPicker(
                            //   pickerColor: pickerColor,
                            //   onColorChanged: changeColor,
                            //   showLabel: true, // only on portrait mode
                            // ),
                            //
                            // Use Block color picker:
                            //
                            child: BlockPicker(
                              pickerColor: currentColor,
                              onColorChanged: changeColor,
                              availableColors: widget.availableColors,
                            ),
                            //
                            // child: MultipleChoiceBlockPicker(
                            //   pickerColors: currentColors,
                            //   onColorsChanged: changeColors,
                            // ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Save'),
                              onPressed: () {
                                setState(() => currentColor = _pickerColor);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
          SizedBox(
            height: 30.0,
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
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
            title: Text('Rename Device'),
            content: TextField(
              controller: _renameController,
              decoration: InputDecoration(
                  hintText: querySnapshot.data()[widget.senderNumber]["name"]),
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