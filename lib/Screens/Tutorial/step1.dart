import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Tutorial/step2.dart';

class Step1 extends StatefulWidget {
  @override
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50.0,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Step 1 of 5',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20.0,
                      fontFamily: 'RobotoMono'),
                ),
              )
            ],
          ),
          AnimatedTextKit(
              pause: Duration(milliseconds: 5000),
              totalRepeatCount: 1,
              animatedTexts: [
                TyperAnimatedText('Welcome to IAT \n Let\'s Start',
                    textStyle:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    speed: Duration(milliseconds: 200)),
              ]),
          // SizedBox(
          //   height: 50.0,
          // ),
          
          SizedBox(
            height: 20.0,
          ),
          Image.asset(
            'assets/images/power_on.png',
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 30.0,
          ),
          Text(
            "Turn on your Gateway IAT Device",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Step2(),
              ));
            },
          ),
        ],
      )),
    ));
  }
}