import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/task_route.dart';
import 'package:get/get.dart';

class WifiPage extends StatefulWidget {
  WifiPage(this.ssid, this.bssid);

  final String ssid;
  final String bssid;

  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  bool isBroad = true;
  TextEditingController password = TextEditingController();
  TextEditingController deviceCount = TextEditingController(text: "1");
  bool _obscureText = false;
  String _espIP = "";

  void espIPReceived(String receivedIP) {
    setState(() => _espIP = receivedIP);
  }

  void goToTaskRoute() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => TaskRoute(widget.ssid, widget.bssid,
                password.text, deviceCount.text, isBroad)))
        .then((value) {
      password.clear();
      espIPReceived(value);
    });
  }

  Widget normalState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 50.0,
        ),
        _espIP != ""
            ? Image.asset(
                'assets/images/wifi_connected.png',
                // fit: BoxFit.fill,
              )
            : Image.asset(
                'assets/images/wifi_disconnected.png',
                fit: BoxFit.cover,
              ),
        SizedBox(
          height: 30.0,
        ),
        _espIP != ""
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
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[300]),
              ),
        SizedBox(
          height: 30.0,
        ),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "ssid".tr + " : \t ",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
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
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: _espIP,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ])),
        SizedBox(
          height: 60,
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
          height: 60,
        ),
        SizedBox(
          width: 150.0,
          height: 50.0,
          child: ElevatedButton(
              onPressed: () async {
                print(password.text);
                print(deviceCount.text);
                goToTaskRoute();
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => TaskRoute(widget.ssid, widget.bssid,
                //         password.text, deviceCount.text, isBroad)));
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
