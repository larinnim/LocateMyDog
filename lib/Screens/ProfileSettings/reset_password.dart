import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../loading.dart';

class LanguageValue {
  // ignore: unused_field
  final int _key;
  // ignore: unused_field
  final String _value;
  LanguageValue(this._key, this._value);
}

class ResetPasswordPage extends StatefulWidget {
  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  bool showNewPassword = true;
  bool showConfirmPassword = true;
  bool showCurrentPassword = true;
  FocusNode _currentPasswordFocus = FocusNode();
  FocusNode _newPasswordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? password, passwordConfirm, currentPassword;
  Color? color;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _currentPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _updatePassword() {
    _firebaseAuth
        .signInWithEmailAndPassword(
            email: _firebaseAuth.currentUser!.email!,
            password: currentPasswordController.text)
        .then((userCredential) {
      _firebaseAuth.currentUser!
          .updatePassword(confirmPasswordController.text)
          .then((value) => {
                Get.dialog(SimpleDialog(
                  title: Text(
                    "Success",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                  children: [
                    Text("    Password successfully updated.",
                        style: TextStyle(fontSize: 20.0)),
                  ],
                ))
              })
          .catchError((error) {
        if (error.code == 'weak-password') {
          Get.dialog(SimpleDialog(
            title: Text(
              "Error",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            children: [
              Text("     Weak Password. Password needs at least 6 characters",
                  style: TextStyle(fontSize: 20.0)),
            ],
          ));
        }
      });
    }).catchError((error) {
      if (error.code == 'invalid-email') {
        Get.dialog(SimpleDialog(
          title: Text(
            "Error",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          children: [
            Text("     Email is not valid", style: TextStyle(fontSize: 20.0)),
          ],
        ));
      } else if (error.code == 'user-disabled') {
        Get.dialog(SimpleDialog(
          title: Text(
            "Error",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          children: [
            Text("     Account is disabled", style: TextStyle(fontSize: 20.0)),
          ],
        ));
      } else if (error.code == 'user-not-found') {
        Get.dialog(SimpleDialog(
          title: Text(
            "Error",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          children: [
            Text("     User not found corresponding to this email",
                style: TextStyle(fontSize: 20.0)),
          ],
        ));
      } else if (error.code == 'wrong-password') {
        Get.dialog(SimpleDialog(
          title: Text(
            "Error",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          children: [
            Text("     " + "wrong_password".tr,
                style: TextStyle(fontSize: 20.0)),
          ],
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _currentPasswordFocus.addListener(() {
      setState(() {
        color = _currentPasswordFocus.hasFocus ? Colors.green : Colors.black;
      });
    });
    _newPasswordFocus.addListener(() {
      setState(() {
        color = _newPasswordFocus.hasFocus ? Colors.green : Colors.black;
      });
    });
    _confirmPasswordFocus.addListener(() {
      setState(() {
        color = _confirmPasswordFocus.hasFocus ? Colors.green : Colors.black;
      });
    });
    return FutureBuilder(
        initialData: false,
        future:
            mounted ? _connectivity.checkConnectivity() : Future.value(null),
        builder: (context, connectivitySnap) {
          if (connectivitySnap.hasData) {
            return Form(
              key: formKey,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: true,
                  elevation: 1,
                  title: Text(
                    "reset_password".tr,
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
                            currentPassword = textValue;
                          });
                        },
                        validator: (currentPassword) {
                          if (currentPassword!.isEmpty) {
                            return 'current_password'.tr;
                          }
                          return null;
                        },
                        controller: currentPasswordController,
                        obscureText: showCurrentPassword,
                        autofocus: false,
                        focusNode: _currentPasswordFocus,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showCurrentPassword = !showCurrentPassword;
                                });
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: "current_password".tr,
                            labelStyle: TextStyle(
                              color: _currentPasswordFocus.hasFocus
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
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (textValue) {
                          setState(() {
                            password = textValue;
                          });
                        },
                        validator: (pwValue) {
                          if (pwValue!.isEmpty) {
                            return 'field_mandatory'.tr;
                          }
                          if (pwValue.length < 8) {
                            return 'password_min_char'.tr;
                          }
                          return null;
                        },
                        obscureText: showNewPassword,
                        autofocus: false,
                        focusNode: _newPasswordFocus,
                        controller: newPasswordController,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showNewPassword = !showNewPassword;
                                });
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: "new_password_char".tr,
                            labelStyle: TextStyle(
                              color: _newPasswordFocus.hasFocus
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (textValue) {
                          setState(() {
                            passwordConfirm = textValue;
                          });
                        },
                        validator: (pwConfirmValue) {
                          if (pwConfirmValue!.isEmpty) {
                            return 'field_mandatory'.tr;
                          }
                          if (pwConfirmValue != password) {
                            return 'password_match'.tr;
                          }
                          return null;
                        },
                        controller: confirmPasswordController,
                        obscureText: showConfirmPassword,
                        autofocus: false,
                        focusNode: _confirmPasswordFocus,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: "confirm_password".tr,
                            labelStyle: TextStyle(
                              color: _confirmPasswordFocus.hasFocus
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
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            side: BorderSide(width: 2, color: Colors.green),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("cancel".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.black)),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            elevation:
                                MaterialStateProperty.resolveWith<double>(
                              // As you said you dont need elevation. I'm returning 0 in both case
                              (Set<MaterialState> states) {
                                return 2;
                              },),
                            padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                                // As you said you dont need elevation. I'm returning 0 in both case
                                (Set<MaterialState> states) {
                                  return EdgeInsets.symmetric(horizontal: 50.0) ;}),
      
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red[200]),
                                
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                          ))),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              if (connectivitySnap.data ==
                                  ConnectivityResult.none) {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (_) => CupertinoAlertDialog(
                                          title: Text("Error"),
                                          content: Text(
                                              "You are offline. Please connect to an active internet connection."),
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
                              } else {
                                _updatePassword();
                              }
                            }
                          },
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
