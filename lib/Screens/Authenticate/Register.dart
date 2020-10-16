import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/profile.dart';
import 'package:flutter_maps/Services/database.dart';

class Register extends StatefulWidget {
  final Function cancelBackToHome;

  Register({this.cancelBackToHome});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _termsAgreed = false;
  bool saveAttempted = false;
  String email, password, passwordConfirm, dogname, ownername, dogbreed;
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _createUser({String email, String pw}) {
    _auth
        .createUserWithEmailAndPassword(email: email, password: pw)
        .then((authResult) async {
      authResult.user.updateProfile(displayName: dogname);
      authResult.user != null
          ? AppUser(authResult.user.uid,
              displayName: authResult.user.displayName)
          : null;
      // create a new document for the user with the uid
      await DatabaseService(uid: authResult.user.uid)
          .updateUserData(dogname, ownername, dogbreed);
      print('yay! ${authResult.user}');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Container(color: Colors.yellow, child: ProfileScreen());
        //  Text('Welcome ${authResult.user.email}'));
      }));
    }).catchError((err) {
      print(err);
      if (err.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'This email already has an account associated with it'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                autovalidate: saveAttempted,
                onChanged: (textValue) {
                  setState(() {
                    dogname = textValue;
                  });
                },
                validator: (dogNameVal) {
                  if (dogNameVal.isEmpty) {
                    return 'This field is mandatory';
                  }
                },
                decoration: InputDecoration(
                    errorStyle: TextStyle(color: Colors.white),
                    hintText: 'Dog Name: ',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                autovalidate: saveAttempted,
                onChanged: (textValue) {
                  setState(() {
                    ownername = textValue;
                  });
                },
                validator: (dogOwnerVal) {
                  if (dogOwnerVal.isEmpty) {
                    return 'This field is mandatory';
                  }
                },
                decoration: InputDecoration(
                    errorStyle: TextStyle(color: Colors.white),
                    hintText: 'Dog Owner: ',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                autovalidate: saveAttempted,
                onChanged: (textValue) {
                  setState(() {
                    dogbreed = textValue;
                  });
                },
                validator: (dogBreedVal) {
                  if (dogBreedVal.isEmpty) {
                    return 'This field is mandatory';
                  }
                },
                decoration: InputDecoration(
                    errorStyle: TextStyle(color: Colors.white),
                    hintText: 'Dog Breed: ',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                autovalidate: saveAttempted,
                onChanged: (textValue) {
                  setState(() {
                    email = textValue;
                  });
                },
                validator: (emailValue) {
                  if (emailValue.isEmpty) {
                    return 'This field is mandatory';
                  }

                  String p =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
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
              TextFormField(
                autovalidate: saveAttempted,
                onChanged: (textValue) {
                  setState(() {
                    password = textValue;
                  });
                },
                validator: (pwValue) {
                  if (pwValue.isEmpty) {
                    return 'This field is mandatory';
                  }
                  if (pwValue.length < 8) {
                    return 'Passoword must be at least 8 characters';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                    errorStyle: TextStyle(color: Colors.white),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                autovalidate: saveAttempted,
                onChanged: (textValue) {
                  setState(() {
                    passwordConfirm = textValue;
                  });
                },
                validator: (pwConfirmValue) {
                  if (pwConfirmValue.isEmpty) {
                    return 'This field is mandatory';
                  }
                  if (pwConfirmValue != password) {
                    return 'Passwords must match';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                    errorStyle: TextStyle(color: Colors.white),
                    hintText: 'Re-enter Password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              SizedBox(height: 12.0),
              Row(children: <Widget>[
                Checkbox(
                  activeColor: Colors.orange,
                  value: _termsAgreed,
                  onChanged: (newValue) {
                    setState(() {
                      _termsAgreed = newValue;
                    });
                  },
                ),
                // SizedBox(width: 38.0),
                Text('Agreed to Terms & Condition',
                    style: TextStyle(color: Colors.white, fontSize: 16.0))
              ]),
              SizedBox(width: 20.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        widget.cancelBackToHome();
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
                        setState(() {
                          saveAttempted = true;
                        });
                        if (formKey.currentState.validate()) {
                          formKey.currentState.save();
                          _createUser(email: email, pw: password);
                        }
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 34.0),
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
      ),
    );
  }
}
