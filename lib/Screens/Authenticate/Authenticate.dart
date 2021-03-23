import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
            // Color.fromRGBO(255, 123, 67, 1.0),
            Colors.red[300],
            Colors.lightGreen[300]
            // Color.fromRGBO(245, 50, 111, 1.0)
          ])),
      child: SignIn(),
      // backgroundColor: Colors.black,
    ));
    // return
    // Container(
    //   decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //           begin: Alignment.topCenter,
    //           end: Alignment.bottomCenter,
    //           colors: [
    //         Color.fromRGBO(255, 123, 67, 1.0),
    //         Color.fromRGBO(245, 50, 111, 1.0)
    //       ])),
    //   child: Scaffold(resizeToAvoidBottomPadding: false, body: SignIn(), backgroundColor: Colors.black,),
    // );
  }
}
