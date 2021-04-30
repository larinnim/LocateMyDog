import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';
import 'package:flutter_maps/Screens/Tutorial/step4.dart';
import 'package:lottie/lottie.dart';


class LottiePage extends StatefulWidget {
  @override
  _LottiePageState createState() => _LottiePageState();
}

class _LottiePageState extends State<LottiePage> {

   @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).push(
            // MaterialPageRoute(builder: (context) => Step1(),));

        MaterialPageRoute(builder: (context) => Wrapper(),));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Lottie Animation Demo"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                  'assets/lottie/lottie_file.json',
                repeat: true,
                reverse: true,
                animate: true,
              ),
            ],
          ),
        ),
    );
  }
}
