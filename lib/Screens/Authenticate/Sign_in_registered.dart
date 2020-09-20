import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInRegistered extends StatefulWidget {
  @override
  _SignInRegisteredState createState() => _SignInRegisteredState();
}

class _SignInRegisteredState extends State<SignInRegistered> {
  bool _rememberPassword = false;
  @override
  Widget build(BuildContext context) {
      return Container(
        child: Column(children: <Widget>[
          Text('SIGN IN', style: TextStyle(color: Colors.white, fontSize: 26.0, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.0),
          TextField(decoration: InputDecoration(hintText: 'Enter Email', hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)), focusColor: Colors.white, focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))), style: TextStyle(color: Colors.white, fontSize: 22.0),),
          SizedBox(height: 20.0),
          TextField(obscureText: true, decoration: InputDecoration(hintText: 'Password', hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)), focusColor: Colors.white, focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))), style: TextStyle(color: Colors.white, fontSize: 22.0),),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Checkbox(activeColor: Colors.orange, value: _rememberPassword, onChanged: (newValue) {
              setState(() {
                _rememberPassword = newValue;
              });
            },),   
            Text('Remember Password', style: TextStyle(color: Colors.white, fontSize: 16.0))
          ]
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[  
              Container(
                // width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 34.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)), child: Text('LOG IN', style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),)
              ) 
            ]
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)), 
                child: Icon(FontAwesomeIcons.google, color: Colors.red)),
              SizedBox(width: 38.0),
              Container(
                padding: EdgeInsets.all(20.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)), 
                child: Icon(FontAwesomeIcons.facebookF, color: Colors.red)), 
            ]
          ),
          SizedBox(height: 20.0),
          Text('FORGOT PASSWORD?', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 16.0, fontWeight: FontWeight.bold)),
          Column(children: <Widget>[
            Container(
            color: Colors.black.withOpacity(0.2), child:
            Text('DON\'T HAVE AN ACCOUNT? SIGN UP', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 16.0, fontWeight: FontWeight.bold))
          )
          ]),
        ],
        ),
      );

  }
}
