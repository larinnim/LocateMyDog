import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:flutter_maps/locator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
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
    await locator.get<UserController>().signInWithFacebook()
        .catchError((error, stackTrace) async {
      // error is SecondError
      print("outer: $error");
      // Get.dialog(SimpleDialog());

    });

    // final facebookLogin = FacebookLogin();
    // final result = await facebookLogin.logIn(['email']);
    // final token = result.accessToken.token;
    // final graphResponse = await http.get(
    //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    // print(graphResponse.body);
    // await locator.get<UserController>().signInWithEmailAndPassword()
  }

  void _signInGoogle() async {
    // try {
    //   await _googleSignIn.signIn();
    // } catch (error) {
    //   print(error);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Column(children: <Widget>[
        InkWell(
          onTap: () {
            _signInGoogle();
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.google,
                      color: Colors.lightGreen, size: 30.0),
                  Text(
                    ' | Sign in with Google',
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
            _signInFacebook();
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.facebookF,
                      color: Colors.lightGreen, size: 30.0),
                  Text(
                    ' | Sign in with Facebook',
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
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.envelope,
                      color: Colors.lightGreen, size: 30.0),
                  Text(
                    ' | Sign Up',
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
            'Already Registered? Sign in',
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
}
