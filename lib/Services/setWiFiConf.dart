import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Models/WiFiModel.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
  bool _visible = true;
  bool _loading = true;
  dynamic _percentage = 0.8;

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
                          hintText:
                              _wifiName == "" ? "Tap your network" : _wifiName,
                        ),
                        keyboardType: TextInputType.text,
                        readOnly: true,
                      ),
                      TextField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          icon: Icon(Icons.lock_outline),
                          hintText: 'Your wifi password',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      SizedBox(height: 40.0),
                      MaterialButton(
                        color: Colors.orange,
                        child: Text('Submit',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          submitAction();
                        },
                      ),
                      SizedBox(height: 20.0),
                      Visibility(
                        child: Row(children: <Widget>[
                          getPercentageIndicator(context, _percentage,
                              ((_percentage * 100).round().toString() + "%"))
                        ]),
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: _loading,
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
      return Consumer<WiFiModel>(builder: (_, wifiProvider, child) {
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
                            onTap: () {
                              setState(() {
                                _wifiName = ssidList[index - 1].ssid;
                              });
                            },
                            tileColor: Colors.white,
                            leading: Image.asset(
                                'assets/images/wifi${ssidList[index - 1].level}.png',
                                width: 28,
                                height: 21),
                            title: Text(
                              ssidList[index - 1].ssid,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16.0,
                              ),
                            ),
                            trailing: wifiProvider.ssid.toString() ==
                                    ssidList[index - 1].ssid.toString()
                                ? Wrap(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Connected",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      Icon(
                                        LineAwesomeIcons.check_circle_1,
                                        color: Colors.green,
                                      )
                                    ],
                                  )
                                : Wrap(),
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
      });
    }
  }

  void loadData() async {
    Wifi.list('').then((list) {
      setState(() {
        List<WifiResult> resArr = [];
        list.forEach((item) {
          var i = resArr.indexWhere((x) => x.ssid == item.ssid);
          if (i <= -1) {
            resArr.add(item);
            print(item.ssid);
          }
        });
        ssidList = resArr;
      });
    });
  }

  void submitAction() {
    // var wifiData = '${wifiNameController.text},${wifiPasswordController.text}';
    var wifiData = '$_wifiName,$password';
    writeData(wifiData);
    writeLocale();
  }

  getPercentageIndicator(context, var1, var2) {
    return LinearPercentIndicator(
      width: MediaQuery.of(context).size.width - 50,
      animation: true,
      lineHeight: 20.0,
      animationDuration: 2000,
      percent: var1,
      center: Text(var2),
      linearStrokeCap: LinearStrokeCap.roundAll,
      progressColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.2),
    );
  }

  Future<void> writeLocale() async {
    if (context.read<BleModel>().characteristics.elementAt(4) == null)
      return; //UserID Characteristic

    List<int> bytes = utf8.encode(Localizations.localeOf(context).toString());

    await context
        .read<BleModel>()
        .characteristics
        .elementAt(4)
        .write(bytes); //Write UserID to ESP32
  }

  Future<void> writeData(String data) async {
    // final bleData = Provider.of<BleModel>(context);

    if (context.read<BleModel>().characteristics.elementAt(2) == null)
      return; //WiFi Characteristic

    List<int> bytes = utf8.encode(data);
    await context
        .read<BleModel>()
        .characteristics
        .elementAt(2)
        .write(bytes); //Write WiFi to ESP32
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd3d3d3),
      appBar: AppBar(
        title: Text('WiFi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.all(8.0),
              itemCount: ssidList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                return itemSSID(index);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
