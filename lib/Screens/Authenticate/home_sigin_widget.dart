import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Authenticate/background_painter.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Screens/loading.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_maps/locator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class HomeSignInWidget extends StatelessWidget {
  final Function gotoSignUp;
  final Function gotoSignIn;
  HomeSignInWidget({this.gotoSignUp, this.gotoSignIn});

  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     'https://www.googleapis.com/auth/contacts.readonly',
  //   ],
  // );

  void _signInFacebook() async {
    await locator
        .get<UserController>()
        .signInWithFacebook()
        .catchError((error, stackTrace) async {
      print("outer: $error");
    });
  }

  // void _signInGoogle() async {

  //   await locator.get<UserController>().signInWithGoogle().then((value) {
  //   }).catchError((error, stackTrace) async {
  //     print("outer: $error");
  //   });
  // }

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
                  Text("     Error Occurred. Please contact our support team.",
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
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 30.0),
                child: Column(children: <Widget>[
                  InkWell(
                    onTap: () {
                      // _signInGoogle();
                      Provider.of<SocialSignInProvider>(context, listen: false);
                      provider.loginGoogle();
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.google,
                                color: Colors.lightGreen, size: 30.0),
                            Text(
                              ' | ' + 'sign_in_google'.tr,
                              style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            )
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: () {
                      Provider.of<SocialSignInProvider>(context, listen: false);
                      provider.loginFacebook();
                      // _signInFacebook();
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.facebookF,
                                color: Colors.lightGreen, size: 30.0),
                            Text(
                              ' | ' + 'sign_in_facebook'.tr,
                              style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            )
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: () {
                      gotoSignUp();
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.envelope,
                                color: Colors.lightGreen, size: 30.0),
                            Text(
                              ' | ' + 'register'.tr,
                              style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            )
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  InkWell(
                    onTap: () {
                      gotoSignIn();
                    },
                    child: Text(
                      'already_registered'.tr,
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ]),
              );
            }
          }),
    );
  }

  Widget buildLoading() => Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: BackgroundPainter()),
          Center(child: CircularProgressIndicator()),
        ],
      );
}
