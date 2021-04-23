import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/task_route.dart';
import 'package:get/get.dart';

class WifiPage extends StatefulWidget {
  WifiPage(this.ssid, this.bssid, [this.espIP = ""]);

  final String ssid;
  final String bssid;
  final String espIP;

  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  bool isBroad = true;
  TextEditingController password = TextEditingController();
  TextEditingController deviceCount = TextEditingController(text: "1");
  bool _obscureText = false;

  Widget normalState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 50.0,
        ),
        widget.espIP != ""
            ? Image.asset(
                'assets/images/Wifi-On.png',
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/Wifi-Off.png',
                fit: BoxFit.cover,
              ),
        SizedBox(
          height: 50.0,
        ),
        widget.espIP != ""
            ? Text(
                'connected'.tr,
                style: TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightGreen),
              )
            : Text(
                'disconnected'.tr,
                style: TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "ssid".tr + " : \t ",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.pink,
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: widget.ssid,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ])),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "ip_address".tr + ' : \t',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.pink,
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: widget.espIP,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ])),
        SizedBox(
          height: 6,
        ),
        SizedBox(
          height: 30,
        ),
        TextField(
          obscureText: _obscureText,
          controller: password,
          cursorColor: Colors.black,
          decoration: InputDecoration(
              labelText: "password".tr + ' :',
              suffixIcon: IconButton(
                icon: _obscureText
                    ? Icon(Icons.visibility, color: Colors.grey)
                    : Icon(Icons.visibility_off, color: Colors.grey),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.red),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.black),
              )),
        ),
        SizedBox(
          height: 30,
        ),
        SizedBox(
          width: 150.0,
          height: 50.0,
          child: ElevatedButton(
              onPressed: () async {
                print(password.text);
                print(deviceCount.text);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskRoute(widget.ssid, widget.bssid,
                        password.text, deviceCount.text, isBroad)));
                // _stream = EsptouchSmartconfig.run(widget.ssid, widget.bssid,
                //     password.text, deviceCount.text, isBroad);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red[300],
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
              ),
              child: Text("confirm".tr)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(child: normalState(context))))));
  }
}
