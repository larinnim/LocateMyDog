import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInRegistered extends StatefulWidget {
  final Function gotoSignUp;
  SignInRegistered({this.gotoSignUp});

  @override
  _SignInRegisteredState createState() => _SignInRegisteredState();
}

class _SignInRegisteredState extends State<SignInRegistered> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _rememberPassword = false;
  String email, password;

  void _signIn({String em, String pw}) {
    _auth.signInWithEmailAndPassword(email: em, password: pw).then((authResult) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Container(
            color: Colors.yellow,
            child: Text('Welcome ${authResult.user.email}'));
      }));
    }).catchError((err){
       if (err.code == 'ERROR_WRONG_PASSWORD') {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'The password was incorrect, please try again.'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
      //TODO Create if user doesnt exist
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              Text('SIGN IN',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 12.0),
              TextField(
                onChanged: (textVal) {
                  setState(() {
                    email = textVal;
                  });
                },
                decoration: InputDecoration(
                    hintText: 'Enter Email',
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
                onChanged: (textVal) {
                  setState(() {
                    password = textVal;
                  });
                },
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
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.orange,
                      value: _rememberPassword,
                      onChanged: (newValue) {
                        setState(() {
                          _rememberPassword = newValue;
                        });
                      },
                    ),
                    Text('Use TouchID',
                        style: TextStyle(color: Colors.white, fontSize: 16.0))
                  ]),
              SizedBox(height: 20.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _signIn(em: email, pw: password);
                      },
                      child: Container(
                          // width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 34.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Text(
                            'LOG IN',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ]),
              SizedBox(height: 20.0),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                  Widget>[
                Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Icon(FontAwesomeIcons.google, color: Colors.red)),
                SizedBox(width: 38.0),
                Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Icon(FontAwesomeIcons.facebookF, color: Colors.red)),
              ]),
              SizedBox(height: 20.0),
              Text('FORGOT PASSWORD?',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            widget.gotoSignUp();
          },
          child: Container(
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              color: Colors.black.withOpacity(0.2),
              child: Text('DON\'T HAVE AN ACCOUNT? SIGN UP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700))),
        ),
      ],
    );
  }
}
