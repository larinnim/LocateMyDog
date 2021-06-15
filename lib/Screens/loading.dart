import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void showRelevant() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  void initState() {
    super.initState();
    // showRelevant();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white70,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
  // return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: Center(
  //         child: Container(
  //         color: Colors.white,
  //         child: SpinKitCircle(
  //           color: Colors.red,
  //           size: 30.0,
  //         ))
  //     ));
}
