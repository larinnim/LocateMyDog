import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupport extends StatefulWidget {
  @override
  _HelpSupportState createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("help_support".tr),
        centerTitle: true,
        // backgroundColor: Colors.blueGrey,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            }),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 150.0,
          ),
          Image.asset(
            'assets/images/help.png',
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 30.0,
          ),
          Text(
            "need_help".tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          Text(
            'howtouse'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300, // light
              // fontStyle: FontStyle., // italic
            ),
          ),
          RichText(
            text: TextSpan(
                text: 'sendusemail'.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'support@majel.com',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ]),
          ),
        ],
      )),
    );
  }
}
