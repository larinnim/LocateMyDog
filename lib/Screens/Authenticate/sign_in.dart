import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignIn extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Locate My  ', style: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold, color: Color.fromRGBO(245,48,111, 1.0))),
                  Icon(FontAwesomeIcons.paw, size: 38.0, color: Colors.white,),
                ],
              ),
              SizedBox(height: 20.0,),
              Text('Find your pet and be always happy with it.', style: TextStyle(color: Colors.white, fontSize: 18.0), textAlign: TextAlign.center,),
              SizedBox(height: 85.0,),
              Container(padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Icon(FontAwesomeIcons.google, color: Colors.red, size: 30.0),
                  Text(' | Sign in with Google', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),)
                ],)
              ),
              SizedBox(height: 20.0,),
              Container(padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Icon(FontAwesomeIcons.facebookF, color: Colors.red, size: 30.0),
                  Text(' | Sign in with Facebook', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),)
                ],)
              ),
              SizedBox(height: 20.0,),
              Container(padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Icon(FontAwesomeIcons.envelope, color: Colors.red, size: 30.0),
                  Text(' | Sign Up', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),)
                ],)
              ),
              SizedBox(height: 20.0,),
              Text('Already Registered? Sign in', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 16.0, fontWeight: FontWeight.bold),)
            ],
          )
        )
      ),
    );
  }
}