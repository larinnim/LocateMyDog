import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Services/checkWiFiConnection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../loading.dart';

class LanguageValue {
  final int _key;
  final String _value;
  LanguageValue(this._key, this._value);
}

class ChangeEmailPage extends StatefulWidget {
  @override
  ChangeEmailPageState createState() => ChangeEmailPageState();
}

class ChangeEmailPageState extends State<ChangeEmailPage> {
  bool showPassword = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  Color? color;
  final formKey = GlobalKey<FormState>();
  String? emailEntry, passwordEntry;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? user_email = "";
  // String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  // late FToast fToast;

  @override
  void initState() {
    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.greenAccent,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check),
        SizedBox(
          width: 12.0,
        ),
        Text("This is a Custom Toast"),
      ],
    ),
  );

  void _updateEmail() {
    _firebaseAuth
        .signInWithEmailAndPassword(
            email: _firebaseAuth.currentUser!.email!,
            password: passwordController.text)
        .then((userCredential) {
      userCredential.user!.updateEmail(emailController.text).then((value) {
        Get.dialog(SimpleDialog(
          title: Text(
            "Sucess",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          children: [
            Text("     Email Successfully Updated",
                style: TextStyle(fontSize: 20.0)),
          ],
        ));
      }).catchError((error) {
        if (error.code == "invalid-email") {
          Get.dialog(SimpleDialog(
            title: Text(
              "Error",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            children: [
              Text("     Invalid Email", style: TextStyle(fontSize: 20.0))
            ],
          ));
        } else if (error.code == "email-already-in-use") {
          Get.dialog(SimpleDialog(
            title: Text(
              "Error",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            children: [
              Text("    Email Already in Use", style: TextStyle(fontSize: 20.0))
            ],
          ));
        } else {
          Get.dialog(SimpleDialog(
            title: Text(
              "error".tr,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            children: [
              Text("    Error. Please contact our Support Team",
                  style: TextStyle(fontSize: 20.0))
            ],
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    user_email = _firebaseAuth.currentUser!.email;
    // final connectionStatus =
    //     Provider.of<ConnectionStatusModel>(context, listen: false);
    // connectionStatus.initConnectionListen();

    _emailFocus.addListener(() {
      setState(() {
        color = _emailFocus.hasFocus ? Colors.green : Colors.black;
      });
    });

    _passwordFocus.addListener(() {
      setState(() {
        color = _passwordFocus.hasFocus ? Colors.green : Colors.black;
      });
    });

    return FutureBuilder(
        initialData: false,
        future:
            mounted ? _connectivity.checkConnectivity() : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return
                // return connectionProvider.connectionStatus ==
                //             NetworkStatus.Offline ||
                //         snapshot.data == NetworkStatus.Offline
                // ? CupertinoAlertDialog(
                //     title: Text(
                //         'You are offline. Please connect to the internet to continue to use this feature'),
                //     actions: [
                //       CupertinoDialogAction(
                //         child: Text('OK'),
                //         onPressed: () {
                //           Navigator.pop(context);
                //         },
                //       )
                //     ],
                //   )
                //     :
                Form(
              key: formKey,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: true,
                  elevation: 1,
                  title: Text(
                    "change_email".tr,
                    style: TextStyle(color: Colors.green),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.green,
                    ),
                  ),
                ),
                body: Container(
                  padding: EdgeInsets.only(left: 16, top: 25, right: 16),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (textValue) {
                          setState(() {
                            emailEntry = textValue;
                          });
                        },
                        validator: (emailEntry) {
                          if (emailEntry!.isEmpty) {
                            return 'field_mandatory'.tr;
                          }
                          return null;
                        },
                        controller: emailController,
                        focusNode: _emailFocus,
                        autofocus: false,
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green)),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: _emailFocus.hasFocus
                                  ? Colors.green
                                  : Colors.black,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: user_email,
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (textValue) {
                          setState(() {
                            passwordEntry = textValue;
                          });
                        },
                        validator: (passwordEntry) {
                          if (passwordEntry!.isEmpty) {
                            return 'field_mandatory'.tr;
                          }
                          return null;
                        },
                        controller: passwordController,
                        obscureText: showPassword,
                        focusNode: _passwordFocus,
                        autofocus: false,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: "password".tr,
                            labelStyle: TextStyle(
                              color: _passwordFocus.hasFocus
                                  ? Colors.green
                                  : Colors.black,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: "",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("cancel".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.black)),
                        ),
                        RaisedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              if (snapshot.data == ConnectivityResult.none) {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (_) => CupertinoAlertDialog(
                                          title: Text("Error"),
                                          content: Text("You are offline. Please connect to an active internet connection."),
                                          actions: [
                                            // Close the dialog
                                            // You can use the CupertinoDialogAction widget instead
                                            CupertinoButton(
                                                child: Text('Dismiss'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                }),
                                            // CupertinoButton(
                                            //   child: Text('I agree'),
                                            //   onPressed: () {
                                            //     // Do something
                                            //     print('I agreed');
                                            //   },
                                            // )
                                          ],
                                        ));
                                // Fluttertoast.showToast(
                                //   msg: "You are offline. Please connect to the internet to continue to use this feature",
                                //   toastLength: Toast.LENGTH_LONG,
                                //   timeInSecForIosWeb: 5,
                                //   backgroundColor: Colors.red.shade300,
                                //   fontSize: 18.0,
                                // );
                                //  CupertinoAlertDialog(
                                //   title: Text(
                                //       'You are offline. Please connect to the internet to continue to use this feature'),
                                //   actions: [
                                //     CupertinoDialogAction(
                                //       child: Text('OK'),
                                //       onPressed: () {
                                //         Navigator.pop(context);
                                //       },
                                //     )
                                //   ],
                                // );
                              } else {
                                _updateEmail();
                              }
                            }
                          },
                          color: Colors.red[200],
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "save".tr,
                            style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2.2,
                                color: Colors.white),
                          ),
                        )
                      ],
                    )
                  ]),
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
