import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Authenticate/signed.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Screens/Tutorial/step1.dart';
import 'package:flutter_maps/Screens/Tutorial/step3.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../locator.dart';

class SignInRegistered extends StatefulWidget {
  final Function gotoSignUp;
  final Function goToForgotPW;
  SignInRegistered({this.gotoSignUp, this.goToForgotPW});

  @override
  _SignInRegisteredState createState() => _SignInRegisteredState();
}

class _SignInRegisteredState extends State<SignInRegistered> {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _useTouchID = false;
  bool userHasTouchID = false;
  String email, password;

  @override
  void initState() {
    super.initState();
    getSecureStorage();
  }

  void getSecureStorage() async {
    final isUsingBio = await storage.read(key: 'usingBiometric');
    setState(() {
      userHasTouchID = isUsingBio == 'true';
    });
  }

  void authenticate() async {
    final canCheck = await auth.canCheckBiometrics;
    if (canCheck) {
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          //Face ID
          final authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Enable Face ID to sign in more easily');
          if (authenticated) {
            final userStoredEmail = await storage.read(key: 'email');
            final userStoredPassword = await storage.read(key: 'password');

            _signIn(em: userStoredEmail, pw: userStoredPassword);
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          //Touch ID
        }
      }
    } else {
      print('cant check');
    }
  }

  // void _signInGoogle() async {
  //   await locator.get<UserController>().signInWithGoogle().then((value) {
  //     Navigator.of(context).push(MaterialPageRoute(
  //       // builder: (context) => Step1(), ENABLE when hardware is ready
  //       builder: (context) => ProfileScreen(),
  //     ));
  //   }).catchError((error, stackTrace) async {
  //     print("outer: $error");
  //   });
  // }

  void _signInFacebook() async {
    await locator
        .get<UserController>()
        .signInWithFacebook()
        .catchError((error, stackTrace) async {
      print("outer: $error");
    });
  }

  void _signIn({String em, String pw}) async {
    SocialSignInSingleton socialSiginSingleton = SocialSignInSingleton();

    await locator
        .get<UserController>()
        .signInWithEmailAndPassword(email: em, password: pw)
        .then((value) {
      socialSiginSingleton.isSocialLogin = false;

      Navigator.of(context).push(MaterialPageRoute(
        // builder: (context) => Step1(), ENABLE when hardware is ready
        builder: (context) => ProfileScreen(),
      ));
    }).catchError((error, stackTrace) {
      // error is SecondError
      print("outer: $error");
    });

    if (FirebaseAuth.instance.currentUser != null) {
      //check if docs.length > 0 a subcollection cannot be null, nor empty. If a collection does not contain any documents, it does not exist at all.
      // final prefs = await SharedPreferences.getInstance();

      // final gatewaySSID = prefs.getString('gatewaySSID') ?? '';
      // obtain shared preferences
      final prefs = await SharedPreferences.getInstance();

      // set value
      // ;
      // prefs.getString('endDeviceSSID') ?? '';

      await FirebaseFirestore.instance
          .collection('locateDog')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          FirebaseFirestore.instance
            ..collection('locateDog')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection('gateway')
                .limit(1)
                .get()
                .then((sub) {
              if (sub.docs.length > 0) {
                FirebaseFirestore.instance
                  ..collection('locateDog')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .collection('endDevice')
                      .limit(1)
                      .get()
                      .then((endSub) {
                    if (endSub.docs.length > 0) {
                      print('Gatway Collection and EndDevice exists!');
                      // obtain shared preferences
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Signed(
                          // user: authResult.user,
                          user: FirebaseAuth.instance.currentUser,
                          wantsTouchID: _useTouchID,
                          password: password,
                        );
                      }));
                    }
                  });
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                  // builder: (context) => Step1(), ENABLE when hardware is ready
                  builder: (context) => ProfileScreen(),
                ));
              }
            });
        }
      });
      // var docResult = await FirebaseFirestore.instance
      //     .collection("locateDog")
      //     .doc(FirebaseAuth.instance.currentUser.uid)
      //     .collection('sub-collection')
      //     .limit(1)
      //     .get()
      //     .then(sub => {
      //     if (sub.docs.length > 0) {
      //       console.log('usernames subcollection exists!');
      //     }
      //   });
    } else {
      final prefs = await SharedPreferences.getInstance();

      // Try reading data from the counter key. If it doesn't exist, return 0.
      final siginError = prefs.getString("siginError");

      bool checkValue = prefs.containsKey('value');
      print("Is there any key? " + checkValue.toString());

      showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Sign In Error"),
            content: new Text(siginError),
          ));
      print("No user");
      //Remove String
      prefs.remove("siginError");
    }
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
              userHasTouchID
                  ? InkWell(
                      onTap: () => authenticate(),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(30.0)),
                          padding: EdgeInsets.all(10.0),
                          child: Icon(FontAwesomeIcons.fingerprint)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          Checkbox(
                            activeColor: Colors.orange,
                            value: _useTouchID,
                            onChanged: (newValue) {
                              setState(() {
                                _useTouchID = newValue;
                              });
                            },
                          ),
                          Text('Use TouchID',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0))
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
                                color: Colors.lightGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ]),
              SizedBox(height: 20.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        // _signInGoogle();
                      },
                      child: Container(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Icon(FontAwesomeIcons.google,
                              color: Colors.lightGreen)),
                    ),
                    SizedBox(width: 38.0),
                    InkWell(
                      onTap: () {
                        _signInFacebook();
                      },
                      child: Container(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Icon(FontAwesomeIcons.facebookF,
                              color: Colors.lightGreen)),
                    ),
                  ]),
              SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  widget.goToForgotPW();
                },
                child: Text('FORGOT PASSWORD?',
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold)),
              ),
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
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700))),
        ),
      ],
    );
  }
}
