import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_maps/Screens/Profile/avatar.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../locator.dart';
import '../loading.dart';
import 'functions_aux.dart';
import 'dart:io';

// ignore: must_be_immutable
class DeviceDetail extends StatefulWidget {
  // obtain shared preferences
  DeviceDetail(
      {Key? key,
      this.title,
      this.color,
      this.battery,
      this.senderID,
      this.availableColors})
      : super(key: key);
  @override
  _DeviceDetailState createState() => _DeviceDetailState();

  // Fields in a Widget subclass are always marked "final".

  String? title;
  Color? color;
  int? battery;
  String? senderID;
  List<Color>? availableColors;
}

class _DeviceDetailState extends State<DeviceDetail> {
  CollectionReference senderCollection =
      FirebaseFirestore.instance.collection('sender');
  TextEditingController _renameController = TextEditingController();

  Color? currentColor = Color(0xff443a49);
  Color? _pickerColor = Color(0xff443a49);

  final picker = ImagePicker();
  late File _image;
  String senderImagePic = "";

  bool _isUploadingImage = false;
  @override
  void initState() {
    super.initState();
    changeColor(widget.color);
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   getSenderImage();
    // });
  }

  Future<String> _getSenderImage() async {
    return await DatabaseService(uid: widget.senderID).getSenderPicture();
  }

// ValueChanged<Color> callback
  void changeColor(Color? color) async {
    setState(() => _pickerColor = color);
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    // Add color on cache to be used on ble
    prefs.setString('color-' + widget.senderID.toString(),
        AuxFunc().colorNamefromColor(color));

    DatabaseService(uid: widget.senderID)
        .updateDeviceColor(AuxFunc().colorNamefromColor(_pickerColor));
  }

  void updateName() async {
    await DatabaseService(uid: widget.senderID)
        .updateDeviceName(_renameController.text);
  }

  Future getImage() async {
    await picker
        .getImage(source: ImageSource.gallery)
        .then((pickedImage) async {
      if (pickedImage != null) {
        setState(() {
          _isUploadingImage = true;
        });
        await locator
            .get<UserController>()
            .uploadSenderPicture(File(pickedImage.path), widget.senderID!)
            .then((value) {
          setState(() {
            _isUploadingImage = false;
          });
        });
      } else {
        print('No image selected.');
        setState(() {
          _isUploadingImage = false;
        });
      }
    });
  }
// raise the [showDialog] widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: senderCollection.doc(widget.senderID).snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> docsnapshot) {
            if (docsnapshot.hasError) {
              return Text('Something went wrong');
            }

            if (docsnapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            }
            return Center(
                child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                ),
                FutureBuilder<String>(
                    future: _getSenderImage(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Avatar(
                            avatarUrl: 'uploading',
                            onTap: () async {
                              // getImage();
                              // locator
                              //     .get<UserController>()
                              //     .uploadSenderPicture(_image, widget.senderID!);
                              // setState(() {});
                            },
                          );
                        default:
                          if (snapshot.hasError || snapshot.data == '') {
                            return Container(
                              width: 200,
                              child: Avatar(
                                avatarUrl: null,
                                onTap: () async {
                                  getImage();
                                  // locator
                                  //     .get<UserController>()
                                  //     .uploadSenderPicture(_image, widget.senderID!);
                                  // setState(() {});
                                },
                              ),
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                border: new Border.all(
                                  color: _pickerColor ?? Colors.black,
                                  width: 4.0,
                                ),
                              ),
                            );
                          } else {
                            return _isUploadingImage
                                ? Avatar(
                                    avatarUrl: 'uploading',
                                    onTap: () async {
                                      // getImage();
                                      // locator
                                      //     .get<UserController>()
                                      //     .uploadSenderPicture(_image, widget.senderID!);
                                      // setState(() {});
                                    },
                                  )
                                : Container(
                                    width: 200,
                                    child: Avatar(
                                      avatarUrl: snapshot.data,
                                      onTap: () async {
                                        getImage();
                                        // locator
                                        //     .get<UserController>()
                                        //     .uploadSenderPicture(_image, widget.senderID!);
                                        // setState(() {});
                                      },
                                    ),
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: new Border.all(
                                        color: _pickerColor ?? Colors.black,
                                        width: 4.0,
                                      ),
                                    ),
                                  );
                          }
                      }
                    }),

                // Icon(
                //   LineAwesomeIcons.mobile_phone,
                //   color: _pickerColor,
                //   size: 100.0,
                // ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                                  child: BlockPicker(
                                    pickerColor: currentColor!,
                                    onColorChanged: changeColor,
                                    availableColors: widget.availableColors!,
                                  ),
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
                                      setState(
                                          () => currentColor = _pickerColor);
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
                        leading: docsnapshot.data!['batteryLevel'] < 20
                            ? Icon(LineAwesomeIcons.battery_1_4_full)
                            : 20 < docsnapshot.data!['batteryLevel'] &&
                                    docsnapshot.data!['batteryLevel'] < 50
                                ? Icon(LineAwesomeIcons.battery_1_2_full)
                                : 50 < docsnapshot.data!['batteryLevel'] &&
                                        docsnapshot.data!['batteryLevel'] < 80
                                    ? Icon(LineAwesomeIcons.battery_3_4_full)
                                    : docsnapshot.data!['batteryLevel'] > 80
                                        ? Icon(LineAwesomeIcons.battery_full)
                                        : Icon(LineAwesomeIcons.battery_empty),
                        title: Text('Baterry Level'),
                        trailing: Text(
                            docsnapshot.data!['batteryLevel'].toString() + '%'),
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
                        title: Text('Version'),
                        trailing: Text(docsnapshot.data!['version']),
                      ),
                      ListTile(
                        tileColor: Colors.white70,
                        title: Text('Serial Number'),
                        trailing: Text(docsnapshot.data!['senderMac']),
                      ),
                    ],
                  ),
                ),
              ],
            ));
          }),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    senderCollection
        .doc(widget.senderID)
        .get()
        .then((DocumentSnapshot querySnapshot) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rename Device'),
            content: TextField(
              controller: _renameController,
              decoration:
                  InputDecoration(hintText: querySnapshot.data()!["name"]),
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
