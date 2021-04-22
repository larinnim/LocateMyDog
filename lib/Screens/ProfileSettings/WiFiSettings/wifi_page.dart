import 'package:esptouch_smartconfig/esp_touch_result.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/ProfileSettings/WiFiSettings/task_route.dart';
import 'package:flutter_maps/Screens/loading.dart';
import 'package:get/get.dart';

class WifiPage extends StatefulWidget {
  WifiPage(this.ssid, this.bssid);

  final String ssid;
  final String bssid;

  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  late Stream<ESPTouchResult>? _stream;

  bool isBroad = true;
  TextEditingController password = TextEditingController();
  TextEditingController deviceCount = TextEditingController(text: "1");
  bool _connectionStatus = false;
  String _currentIP = "NONE";
  bool _obscureText = false;
  @override
  void initState() {
    _stream = EsptouchSmartconfig.run(
        widget.ssid, widget.bssid, password.text, deviceCount.text, isBroad);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget error(BuildContext context, String s) {
    return Center(
      child: Text(
        s,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget noneState(BuildContext context) {
    return Center(
        child: Text(
      'None',
      style: TextStyle(fontSize: 24),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: StreamBuilder<ESPTouchResult>(
                stream: _stream,
                builder: (context, AsyncSnapshot<ESPTouchResult> snapshot) {
                  if (snapshot.hasError) {
                    return error(context, 'Error in StreamBuilder');
                  } else {
                    if (snapshot.hasData) {
                      setState(() {
                        _currentIP = snapshot.data!.ip;
                        _connectionStatus = true;
                      });
                      if (snapshot.connectionState == ConnectionState.active) {
                        return Loading();
                      }
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50.0,
                        ),
                        _connectionStatus == true
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
                        _connectionStatus == true
                            ? Text(
                                'Connected',
                                style: TextStyle(
                                    fontSize: 72.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen),
                              )
                            : Text(
                                'Disconnected',
                                style: TextStyle(
                                    fontSize: 72.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: "SSID: \t ",
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
                              text: "IP Address: \t",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: _currentIP,
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
                              labelText: "Password:",
                              suffixIcon: IconButton(
                                icon: _obscureText
                                    ? Icon(Icons.visibility, color: Colors.grey)
                                    : Icon(Icons.visibility_off,
                                        color: Colors.grey),
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
                                
                                EsptouchSmartconfig.run(
                                    widget.ssid,
                                    widget.bssid,
                                    password.text,
                                    deviceCount.text,
                                    isBroad);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red[300],
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              child: Text("CONFIRM")),
                        ),
                      ],
                    );
                  }
                }),
          ),
        ),
      ),
    ));
  }
}
