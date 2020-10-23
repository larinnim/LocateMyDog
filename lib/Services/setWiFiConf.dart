import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetWiFiConf extends StatefulWidget {
  @override
  _SetWiFiConfPageState createState() => _SetWiFiConfPageState();
}

class _SetWiFiConfPageState extends State<SetWiFiConf> {
  bool checkbox1 = true;
  bool checkbox2 = false;
  String gender = 'male';
  String dropdownValue = 'A';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi'),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(children: [
                Text('WiFi SSID'),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: 'Please type the Wi-Fi SSID',
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(5.0))),
                  onChanged: (value) {
                    //Do something with this value
                  },
                ),
                SizedBox(height: 10.0),
                Text('Wi-Fi Password'),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Please Type the WiFi Password',
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(5.0))),
                ),
                SizedBox(height: 50.0),
                MaterialButton(
                  color: Colors.orange,
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    //Do Something
                  },
                ),
                SizedBox(height: 10.0),
                      FlatButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)),
                    onPressed: () {},
                    child: Text("Connect")),
              ]),
              )),
    );
  }
}
