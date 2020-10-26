import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/Home/wrapper.dart';

class ForgotPassword extends StatefulWidget {
  // final Function gotoSignUp;
  final Function gotoSignIn;

  ForgotPassword({this.gotoSignIn});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  String email;
  PageController pageController = PageController();

  Future forgotPassword({String email}) async {
    return _auth.sendPasswordResetEmail(email: email).then((value) {
      // Navigator.pop(context);
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('A password reset link has been sent to $email'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return Material(child: Wrapper());
                    }));
                  },
                )
              ],
            );
          });
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Text('Forgot Your Password',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 12.0),
            TextFormField(
              onChanged: (textValue) {
                setState(() {
                  email = textValue;
                });
              },
              validator: (emailValue) {
                if (emailValue.isEmpty) {
                  return 'This field is mandatory';
                }

                // String p =
                //     r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                String p =
                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                    r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                    r"{0,253}[a-zA-Z0-9])?)*$";
                RegExp regExp = new RegExp(p);

                if (regExp.hasMatch(emailValue)) {
                  //The email is valid
                  return null;
                }

                return 'This is not a valid email';
              },
              decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter Email',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  focusColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              style: TextStyle(color: Colors.white, fontSize: 22.0),
            ),
            SizedBox(height: 20.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              InkWell(
                onTap: () {
                  widget.gotoSignIn();
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 38.0),
              InkWell(
                onTap: () {
                  forgotPassword(email: email);
                },
                child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 34.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
              )
            ])
          ],
        ),
      ),
    );
  }
}
