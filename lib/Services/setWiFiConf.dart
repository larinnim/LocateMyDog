import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/wifi.dart';
import 'bluetooth_conect.dart';
import 'dart:convert' show utf8;

class SetWiFiConf extends StatefulWidget {
  @override
  _SetWiFiConfPageState createState() => _SetWiFiConfPageState();
}

class _SetWiFiConfPageState extends State<SetWiFiConf> {
  String _wifiName = '';
  int level = 0;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  List<WifiResult> ssidList = [];
  List<String> processedSSIDList = [];
  String ssid = '', password = '';
  TextEditingController wifiNameController = TextEditingController();
  TextEditingController wifiPasswordController = TextEditingController();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget itemSSID(index) {
    if (index == 0) {
      return Column(children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Visibility(
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          icon: Icon(Icons.wifi),
                          hintText: _wifiName,
                          // labelText: 'ssid',
                          // labelText: _wifiName,
                          // suffixIcon: Padding(
                          //   //suffixIcon, this way it don't disapear when the TextField is unfocused
                          //   padding: EdgeInsets.only(
                          //       top: 20), //padding to put closer to the line
                          //   child: Text(
                          //     _wifiName,
                          //     style: TextStyle(
                          //       color: Colors.grey,
                          //     ),
                          //   ),
                          // ),`
                        ),
                        keyboardType: TextInputType.text,
                        readOnly: true,
                        // onChanged: (value) {
                        //   ssid = value;
                        // },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          icon: Icon(Icons.lock_outline),
                          hintText: 'Your wifi password',
                          // labelText: 'password',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                         SizedBox(height: 50.0),
              MaterialButton(
                color: Colors.orange,
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  submitAction();
                },
              ),
                    ])),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: _visible,
              ),
            ),
          ],
        )
      ]);
    } else {
    //   processedSSIDList.add(ssidList[index - 1].ssid);
    //   print("The length:" + processedSSIDList.length.toString());
      return ssidList[index - 1].ssid != ""
          ? Container(
              color: Color(0xffd3d3d3),
              child: Column(children: <Widget>[
                Visibility(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(children: <Widget>[
                      Flexible(
                        child: ListTile(
                          // onTap: _getWifiName(),
                          onTap: () {
                            setState(() {
                              _wifiName = ssidList[index - 1].ssid;
                            });
                          },
                          tileColor: Colors.white,
                          leading: Image.asset(
                              'images/wifi${ssidList[index - 1].level}.png',
                              width: 28,
                              height: 21),
                          title: Text(
                            ssidList[index - 1].ssid,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16.0,
                            ),
                          ),
                          dense: true,
                        ),
                      ),
                      Divider(),
                    ]),
                  ),
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: _visible,
                )
              ]),
            )
          : Column();
    }
  }

  // Future<Null> _getWifiName(String arg) async {
  void _getWifiName(String arg) {
    // int l = await Wifi.level;
    // String wifiName = await Wifi.ssid;
    setState(() {
      // level = l;
      _wifiName = arg;
    });
    // return arg;
  }

  void loadData() async {
    Wifi.list('').then((list) {
      setState(() {
        ssidList = [
          ...{...list}
        ];
      });
    });
  }

  void submitAction() {
    var wifiData = '${wifiNameController.text},${wifiPasswordController.text}';
    writeData(wifiData);
  }

  Future<void> writeData(String data) async {
    // final bleData = Provider.of<BleModel>(context);

    if (context.read<BleModel>().characteristics.elementAt(2) == null) return;

    List<int> bytes = utf8.encode(data);
    await context.read<BleModel>().characteristics.elementAt(2).write(bytes);
  }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    var cupertinoVal = true;
    return Scaffold(
      backgroundColor: Color(0xffd3d3d3),
      appBar: AppBar(
        title: Text('WiFi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: ListTile(
              tileColor: Colors.white,
              title: Text('WiFi'),
              trailing: CupertinoSwitch(
                value: _visible,
                onChanged: (bool value) {
                  _toggle();
                  // setState(() {
                  //   _visible = !_visible;
                  //   cupertinoVal = false;
                  // });
                },
              ),
              onTap: () {},
            ),
          ),
          // Visibility(
          //   maintainSize: true,
          //   maintainAnimation: true,
          //   maintainState: true,
          //   visible: _visible,
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.all(8.0),
              itemCount: ssidList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                //Verify if the SSID is not duplicated
                // if (index >= 1 && index<= ssid.length) {
                print("Index" + index.toString());
                // processedSSIDList.add(ssidList[index].ssid);
                // if (!processedSSIDList.contains(ssidList[index])) {
                return itemSSID(index);
                //   }
                //   else {
                //     return Column();
                //   }
                // }
                // else {
                //     return Column();
                //   }
              },
            ),
          ),
          // ),
        ]),
      ),
    );
  }
}
