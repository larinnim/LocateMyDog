import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Providers/SocialSignin.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class HomeSignInWidget extends StatelessWidget {
  final Function? gotoSignUp;
  final Function? gotoSignIn;
  HomeSignInWidget({this.gotoSignUp, this.gotoSignIn});

  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     'https://www.googleapis.com/auth/contacts.readonly',
  //   ],
  // );

 
  // void _signInGoogle() async {

  //   await locator.get<UserController>().signInWithGoogle().then((value) {
  //   }).catchError((error, stackTrace) async {
  //     print("outer: $error");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialSignInProvider>(builder: (_, controller, __) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(children: <Widget>[
          InkWell(
            onTap: () async {
              final isOK = await controller.loginGoogle();
              if (isOK) {
                WidgetsBinding.instance!.addPostFrameCallback((_) =>
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return Material(child: Wrapper());
                    })));
              }
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
            onTap: () async {
              final isOk = await controller.loginFacebook();
              if (!isOk) {
                showCupertinoDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                          title: Text("Error"),
                          content: Text(
                              "Error occured. Please check your internet connection."),
                          actions: [
                            // Close the dialog
                            // You can use the CupertinoDialogAction widget instead
                            CupertinoButton(
                                child: Text('Dismiss'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ],
                        ));
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) =>
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return Material(child: Wrapper());

                      // return Material(child: ProfileScreen());
                    })));
              }
              // _signInFacebook();
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
              gotoSignUp!();
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
              gotoSignIn!();
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
    });
    // return ChangeNotifierProvider(
    //   create: (context) => SocialSignInProvider(),
    //   child: StreamBuilder(
    //       stream: FirebaseAuth.instance.authStateChanges(),
    //       builder: (context, snapshot) {
    //         if (provider.isSigningIn!) {
    //           return Loading();
    //         } else if (provider.isCancelledByUser!) {
    //           showCupertinoDialog(
    //               context: context,
    //               builder: (_) => CupertinoAlertDialog(
    //                     title: Text("Error"),
    //                     content: Text(
    //                         "Error occured. Please check your internet connection."),
    //                     actions: [
    //                       // Close the dialog
    //                       // You can use the CupertinoDialogAction widget instead
    //                       CupertinoButton(
    //                           child: Text('Dismiss'),
    //                           onPressed: () {
    //                             Navigator.of(context).pop();
    //                           }),
    //                     ],
    //                   ));
    //           // Get.dialog(SimpleDialog(
    //           //   title: Text(
    //           //     "Error",
    //           //     style: TextStyle(fontWeight: FontWeight.bold),
    //           //   ),
    //           //   shape: RoundedRectangleBorder(
    //           //       borderRadius: new BorderRadius.circular(10.0)),
    //           //   children: [
    //           //     Text("     Operation Cancelled By User",
    //           //         style: TextStyle(fontSize: 20.0))
    //           //   ],
    //           // ));
    //           // WidgetsBinding.instance!.addPostFrameCallback((_) =>
    //           //     Navigator.pushReplacement(context,
    //           //         MaterialPageRoute(builder: (context) {
    //           //       return Material(child: Authenticate());
    //           //     })));
    //           // return Container();
    //         }
    //         // else if (provider.isError!) {
    //         //   Get.dialog(SimpleDialog(
    //         //     title: Text(
    //         //       "Error",
    //         //       style: TextStyle(fontWeight: FontWeight.bold),
    //         //     ),
    //         //     shape: RoundedRectangleBorder(
    //         //         borderRadius: new BorderRadius.circular(10.0)),
    //         //     children: [
    //         //       Text("     Error Occurred. Please contact our support team.",
    //         //           style: TextStyle(fontSize: 20.0))
    //         //     ],
    //         //   ));
    //         //   WidgetsBinding.instance!.addPostFrameCallback((_) =>
    //         //       Navigator.pushReplacement(context,
    //         //           MaterialPageRoute(builder: (context) {
    //         //         return Material(child: Authenticate());
    //         //       })));
    //         //   return Container();
    //         // }

    //         else if (snapshot.hasData) {
    // WidgetsBinding.instance!.addPostFrameCallback((_) =>
    //     Navigator.pushReplacement(context,
    //         MaterialPageRoute(builder: (context) {
    //       return Material(child: Wrapper());

    //       // return Material(child: ProfileScreen());
    //     })));
    //           return Container();
    //           // Navigator.pushReplacement(context,
    //           //     MaterialPageRoute(builder: (context) {
    //           //   return Material(child: ProfileScreen());
    //           // }));
    //           // } else {

    //         }
    //       }),
    // );
  }
}
