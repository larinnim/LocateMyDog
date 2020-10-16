import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class HomeSignInWidget extends StatelessWidget {
  final Function gotoSignUp;
  final Function gotoSignIn;
  HomeSignInWidget({this.gotoSignUp, this.gotoSignIn});

  void _signInFacebook() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    print(graphResponse.body);
    // if (result.status == FacebookLoginStatus.loggedIn) {
    //   final credential = FacebookAuthProvider.getCredential(token)
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Column(children: <Widget>[
        Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.google, color: Colors.red, size: 30.0),
                Text(
                  ' | Sign in with Google',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                )
              ],
            )),
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
              color: Colors.white, borderRadius: BorderRadius.circular(30.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesomeIcons.facebookF, color: Colors.red, size: 30.0),
              Text(
                ' | Sign in with Facebook',
                style: TextStyle(
                    color: Colors.red,
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
                      color: Colors.red, size: 30.0),
                  Text(
                    ' | Sign Up',
                    style: TextStyle(
                        color: Colors.red,
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
            gotoSignIn();
          },
          child: Text(
            'Already Registered? Sign in',
            style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
        )
      ]),
    );
  }
}
