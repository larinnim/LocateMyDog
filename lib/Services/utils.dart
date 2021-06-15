import 'package:flutter/material.dart';

class AppRoutes {
  static void push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => page),
    );
  }
}

showSnackBar(
  BuildContext context, {
  required String title,
  int milliseconds = 3000,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    new SnackBar(
      backgroundColor: Colors.red,
      duration: Duration(milliseconds: milliseconds),
      content: Container(
        constraints: BoxConstraints(minHeight: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(
              title,
              style:
                  TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    inherit: false,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}