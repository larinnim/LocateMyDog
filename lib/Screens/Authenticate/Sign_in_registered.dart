import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Authenticate/signed.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Screens/Tutorial/step1.dart';
import 'package:flutter_maps/Screens/Tutorial/step3.dart';
import 'package:flutter_maps/Screens/loading.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
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
  final _passwordField = TextEditingController();

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
    if (this.mounted) {
      setState(() {
        userHasTouchID = isUsingBio == 'true';
      });
    }
  }

  void authenticate() async {
    final canCheck = await auth.canCheckBiometrics;
    if (canCheck) {
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (Platform.isIOS || Platform.isAndroid) {
        if (availableBiometrics.contains(BiometricType.face)) {
          //Face ID
          try {
            final authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Use faceID to authenticate',
              useErrorDialogs: true,
              stickyAuth: true,
            );

            if (authenticated) {
              final userStoredEmail = await storage.read(key: 'email');
              final userStoredPassword = await storage.read(key: 'password');
              if (this.mounted) {
                if (userStoredEmail == null || userStoredPassword == null) {
                  setState(() {
                    _useTouchID = false;
                    userHasTouchID = false;
                    storage.write(key: 'usingBiometric', value: 'false');
                  });
                }

                _signIn(em: userStoredEmail, pw: userStoredPassword);
              }
              // if (!mounted) return;
            }
          } on PlatformException catch (e) {
            print(e);
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          //Touch ID
          try {
            final authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Scan your fingerprint to authenticate',
              useErrorDialogs: true,
              stickyAuth: true,
            );

            if (authenticated) {
              final userStoredEmail = await storage.read(key: 'email');
              final userStoredPassword = await storage.read(key: 'password');
              if (this.mounted) {
                if (userStoredEmail == null || userStoredPassword == null) {
                  setState(() {
                    _useTouchID = false;
                    userHasTouchID = false;
                    storage.write(key: 'usingBiometric', value: 'false');
                  });
                }

                _signIn(em: userStoredEmail, pw: userStoredPassword);
              }
              // if (!mounted) return;
            }
          } on PlatformException catch (e) {
            print(e);
          }
        }
      }
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

  // void _signInFacebook() async {
  //   await locator
  //       .get<UserController>()
  //       .signInWithFacebook()
  //       .catchError((error, stackTrace) async {
  //     print("outer: $error");
  //   });
  // }

  void _signIn({String em, String pw}) async {
    SocialSignInSingleton socialSiginSingleton = SocialSignInSingleton();

    await locator
        .get<UserController>()
        .signInWithEmailAndPassword(email: em, password: pw)
        .then((currentUser) async {
      socialSiginSingleton.isSocialLogin = false;

      if (currentUser == null) {
        final prefs = await SharedPreferences.getInstance();
        final signinError = prefs.getString("siginError");
        Get.dialog(SimpleDialog(
          title: Text(
            "Sign in Error",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          titlePadding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          children: [
            Text(signinError,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
          ],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 20,
          ),
        ));
        return;
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          // builder: (context) => Step1(), ENABLE when hardware is ready
          builder: (context) => ProfileScreen(
            password: password,
            wantsTouchId: _useTouchID,
          ),
        ));
      }
    }).catchError((error, stackTrace) {
      // error is SecondError
      print("_signIn: $error");
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

      //   await FirebaseFirestore.instance
      //       .collection('locateDog')
      //       .doc(FirebaseAuth.instance.currentUser.uid)
      //       .get()
      //       .then((doc) {
      //     if (doc.exists) {
      //       FirebaseFirestore.instance
      //         ..collection('locateDog')
      //             .doc(FirebaseAuth.instance.currentUser.uid)
      //             .collection('gateway')
      //             .limit(1)
      //             .get()
      //             .then((sub) {
      //           if (sub.docs.length > 0) {
      //             FirebaseFirestore.instance
      //               ..collection('locateDog')
      //                   .doc(FirebaseAuth.instance.currentUser.uid)
      //                   .collection('endDevice')
      //                   .limit(1)
      //                   .get()
      //                   .then((endSub) {
      //                 if (endSub.docs.length > 0) {
      //                   print('Gatway Collection and EndDevice exists!');
      //                   // obtain shared preferences
      //                   Navigator.pushReplacement(context,
      //                       MaterialPageRoute(builder: (context) {
      //                     return Signed(
      //                       // user: authResult.user,
      //                       user: FirebaseAuth.instance.currentUser,
      //                       wantsTouchID: _useTouchID,
      //                       password: password,
      //                     );
      //                   }));
      //                 }
      //               });
      //           } else {
      //             Navigator.of(context).push(MaterialPageRoute(
      //               // builder: (context) => Step1(), ENABLE when hardware is ready
      //               builder: (context) => ProfileScreen(),
      //             ));
      //           }
      //         });
      //     }
      //   });
      // } else {
      //   final prefs = await SharedPreferences.getInstance();

      //   // Try reading data from the counter key. If it doesn't exist, return 0.
      //   final siginError = prefs.getString("siginError");

      //   bool checkValue = prefs.containsKey('value');
      //   print("Is there any key? " + checkValue.toString());
      //   Get.dialog(SimpleDialog(
      //     title: Text(
      //       "Sign In Error",
      //       style: TextStyle(fontWeight: FontWeight.bold),
      //     ),
      //     shape: RoundedRectangleBorder(
      //         borderRadius: new BorderRadius.circular(10.0)),
      //     children: [
      //       Text("Please type your password", style: TextStyle(fontSize: 20.0))
      //     ],
      //   ));
      //   print("No user");
      //   //Remove String
      //   prefs.remove("siginError");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SocialSignInProvider(),
        child: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final provider = Provider.of<SocialSignInProvider>(context);

              if (provider.isSigningIn) {
                return Loading();
              } else if (provider.isCancelledByUser) {
                Get.dialog(SimpleDialog(
                  title: Text(
                    "Error",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                  children: [
                    Text("     Operation Cancelled By User",
                        style: TextStyle(fontSize: 20.0))
                  ],
                ));
                return Container();
              } else if (provider.isError) {
                Get.dialog(SimpleDialog(
                  title: Text(
                    "Error",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                  children: [
                    Text(
                        "     Error Occurred. Please contact our support team.",
                        style: TextStyle(fontSize: 20.0))
                  ],
                ));
                return Container();
              } else if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return Material(child: ProfileScreen());
                    })));
                return Container();
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) {
                //   return Material(child: ProfileScreen());
                // }));
              } else {
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
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                focusColor: Colors.white,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                            style:
                                TextStyle(color: Colors.white, fontSize: 22.0),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            controller: _passwordField,
                            onChanged: (textVal) {
                              setState(() {
                                password = textVal;
                              });
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                focusColor: Colors.white,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                            style:
                                TextStyle(color: Colors.white, fontSize: 22.0),
                          ),
                          SizedBox(height: 12.0),
                          userHasTouchID
                              ? InkWell(
                                  onTap: () => authenticate(),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      padding: EdgeInsets.all(10.0),
                                      child:
                                          Icon(FontAwesomeIcons.fingerprint)),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                      Checkbox(
                                        activeColor: Colors.orange,
                                        value: _useTouchID,
                                        onChanged: (newValue) {
                                          if (this.mounted) {
                                            setState(() {
                                              _useTouchID = newValue;
                                            });
                                          }
                                        },
                                      ),
                                      Text('Use TouchID',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0))
                                    ]),
                          SizedBox(height: 20.0),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    _passwordField.text.isNotEmpty
                                        ? _signIn(em: email, pw: password)
                                        : Get.dialog(SimpleDialog(
                                            title: Text(
                                              "Sign in Error",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            titlePadding: EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        10.0)),
                                            children: [
                                              Text("Please type your password",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20.0)),
                                            ],
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 20,
                                            ),
                                          ));
                                  },
                                  child: Container(
                                      // width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 34.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
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
                                    Provider.of<SocialSignInProvider>(context,
                                        listen: false);
                                    provider.loginGoogle();
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      child: Icon(FontAwesomeIcons.google,
                                          color: Colors.lightGreen)),
                                ),
                                SizedBox(width: 38.0),
                                InkWell(
                                  onTap: () {
                                    // _signInFacebook();
                                    Provider.of<SocialSignInProvider>(context,
                                        listen: false);
                                    provider.loginFacebook();
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
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
            }));
  }
}
