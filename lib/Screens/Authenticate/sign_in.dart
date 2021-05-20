import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/ForgotPassword.dart';
import 'package:flutter_maps/Screens/Authenticate/Register.dart';
import 'package:flutter_maps/Screens/Authenticate/Sign_in_registered.dart';
import 'package:flutter_maps/Screens/Authenticate/home_sigin_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

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
    TextStyle defaultStyle = TextStyle(color: Colors.white, fontSize: 12.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue, fontSize: 12.0);
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
                        Text('iat  ',
                            style: GoogleFonts.handlee(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40.0)),
                        // TextStyle(
                        //     fontSize: 34.0,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //     )),
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
                      'entry_message'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    // Text(
                    //   'Find your pet and be always happy with it.',
                    //   style: TextStyle(color: Colors.white, fontSize: 18.0),
                    //   textAlign: TextAlign.center,
                    // ),
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
          Align(
              alignment: Alignment.bottomCenter,
              child: RichText(
                text: TextSpan(
                  style: defaultStyle,
                  children: <TextSpan>[
                    TextSpan(text: 'By clicking Sign Up, you agree to our '),
                    TextSpan(
                        text: 'Terms of Service',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return SingleChildScrollView(
                                    child: AlertDialog(
                                      // contentPadding: EdgeInsets.only(left: 25, right: 25),
                                      title: Center(child: Text("terms_service".tr)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      content: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text('terms_condition'.tr)],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 120.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                child: ElevatedButton(
                                                  style:ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(Color(0xFF121A21)),
                                                  shape:
                                                      MaterialStateProperty.all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ))),
                                                  child: new Text(
                                                    'Close',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                            
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          }),
                    TextSpan(text: ' and that you have read our '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return SingleChildScrollView(
                                    child: AlertDialog(
                                      // contentPadding: EdgeInsets.only(left: 25, right: 25),
                                      title: Center(child: Text("privacy_policy".tr)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      content: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                                'terms_condition'.tr),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 120.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                child: ElevatedButton(
                                                  style:ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(Color(0xFF121A21)),
                                                  shape:
                                                      MaterialStateProperty.all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ))),
                                                  child: new Text(
                                                    'Close',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          }),
                  ],
                ),
              )
              //           RichText(
              //   text: TextSpan(
              //     text: 'Hello ',
              //     style: DefaultTextStyle.of(context).style,
              //     children: <TextSpan>[
              //       TextSpan(
              //           text: 'By signing up you are indicating that you have read and agree with the!',
              //           style: TextStyle(fontWeight: FontWeight.bold)),
              //       TextSpan(
              //           text: ' click here!',
              //           recognizer:
              //            TapGestureRecognizer()
              //             ..onTap = () => print('click')
              //             // ),
              //       )],
              //   ),
              // )
              //     Text.rich(TextSpan(
              //       children: <InlineSpan>[
              //         TextSpan(text: 'By signing up you are indicating that you have read and agree with the', style: TextStyle(color: Colors.white)
              //     InkWell(
              //     child: new Text('Open Browser'),
              //     onTap: () => launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html')
              // ),
              // TextSpan(text: 'Powered by Majel Tecnologies', style: TextStyle(color: Colors.white),),
              //     WidgetSpan(
              //       alignment: ui.PlaceholderAlignment.middle,
              //       child: ImageIcon(AssetImage('assets/icon/icon.png'),
              //           size: 40, color: Colors.white,),
              //     ),
              //   ],
              // ))
              // )
              )
        ],
      ),
    );
  }
}
