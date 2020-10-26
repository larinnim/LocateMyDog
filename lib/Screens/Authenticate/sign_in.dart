import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/ForgotPassword.dart';
import 'package:flutter_maps/Screens/Authenticate/Register.dart';
import 'package:flutter_maps/Screens/Authenticate/Sign_in_registered.dart';
import 'package:flutter_maps/Screens/Authenticate/home_sigin_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignIn extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SignIn> {
  PageController pageController = PageController();
  // Duration _animationDuration = Duration(milliseconds: 500);

  // void _changePage(int page) {
  //   pageController.animateToPage(page, duration: _animationDuration, curve: Curves.easeIn);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SafeArea(
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Locate My  ',
                            style: TextStyle(
                                fontSize: 34.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(245, 48, 111, 1.0))),
                        Icon(
                          FontAwesomeIcons.paw,
                          size: 38.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      'Find your pet and be always happy with it.',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    // SizedBox(height: 50.0,),
                  ]))),
          Expanded(
              child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                HomeSignInWidget(
                  gotoSignIn: () {
                    pageController.animateToPage(1,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                  gotoSignUp: () {
                    pageController.animateToPage(2,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                ),
                SignInRegistered(
                  gotoSignUp: () {
                    pageController.animateToPage(2,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                  goToForgotPW: () {
                    pageController.animateToPage(3,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                ),
                Register(
                  cancelBackToHome: () {
                    pageController.animateToPage(0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                ),
                ForgotPassword(
                  gotoSignIn: () {
                    pageController.animateToPage(1,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                ),
              ])),
        ],
      ),
    );
  }
}
