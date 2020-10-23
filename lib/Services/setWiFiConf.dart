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
bool val1 = true, val2 = false, val3 = true;

  bool newval1, newval2, newval3; 

   onChangedFunction1(bool newval1) {
    setState(() {
      val1 = newval1;
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Wi-Fi'
        ),
      ),
      body: Column(
        children: [
          stringSwitch('Wi-Fi', val1, newval1, onChangedFunction1),
          
        ]),
    );
  }
}

 Widget stringSwitch(
      String text, bool val, bool newval, Function onChangedMethod) {
    return Padding(
      padding: EdgeInsets.only(top: 22.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 30.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                // color: Hexcolor('#676767')
                ),
          ),
          Spacer(),
          CupertinoSwitch(
              // trackColor: Hexcolor('#dee7f5'),
              // activeColor: Hexcolor('#0565ac'),
              value: val,
              onChanged: (newval) {
                onChangedMethod(newval);
              })
        ],
      ),
    );
  }

  