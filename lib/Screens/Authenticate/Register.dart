import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function cancelBackToHome;

  Register({this.cancelBackToHome});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _termsAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          Text('CREATE YOUR LOGIN',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 12.0),
          TextField(
            decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
            style: TextStyle(color: Colors.white, fontSize: 22.0),
          ),
          SizedBox(height: 20.0),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
            style: TextStyle(color: Colors.white, fontSize: 22.0),
          ),
          SizedBox(height: 12.0),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
                hintText: 'Re-enter Password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
            style: TextStyle(color: Colors.white, fontSize: 22.0),
          ),
          SizedBox(height: 12.0),
          Row(children: <Widget>[
            Checkbox(
              activeColor: Colors.orange,
              value: _termsAgreed,
              onChanged: (newValue) {
                setState(() {
                  _termsAgreed = newValue;
                });
              },
            ),
            // SizedBox(width: 38.0),
            Text('Agreed to Terms & Condition',
                style: TextStyle(color: Colors.white, fontSize: 16.0))
          ]),
          SizedBox(width: 20.0),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            InkWell(
              onTap: () {
                widget.cancelBackToHome();
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 38.0),
            Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 34.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ))
          ])
        ],
      ),
    );
  }
}
