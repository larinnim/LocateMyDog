import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/avatar.dart';
import 'package:flutter_maps/Screens/ProfileSettings/settings_page.dart';
import 'package:flutter_maps/Services/constants.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:flutter_maps/Services/user_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../locator.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool showPassword = false;
  AppUser _currentUser = locator.get<UserController>().currentUser;

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String username = "";
  String user_email = "";

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    username = _firebaseAuth.currentUser.displayName;
    user_email = _firebaseAuth.currentUser.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.lightGreen,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.lightGreen,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SettingsPage()));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          // color: Theme.of(context).primaryColor,
                          borderRadius:
                              BorderRadius.circular(kSpacingUnit.w * 3)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Avatar(
                            avatarUrl: _currentUser?.avatarUrl,
                            onTap: () async {
                              File image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);

                              await locator
                                  .get<UserController>()
                                  .uploadProfilePicture(image);

                              setState(() {});
                            },
                          ),
                          // SizedBox(height: kSpacingUnit.w * 2),
                          // Text(
                          //   "Where is  ${_firebaseAuth.currentUser.displayName} ?",
                          //   // style: kTitleTextStyle,
                          //   style: TextStyle(fontSize: 18.0),
                          // ),
                        ],
                      ),
                    ),
                    // Container(
                    //   width: 130,
                    //   height: 130,
                    //   decoration: BoxDecoration(
                    //       border: Border.all(
                    //           width: 4,
                    //           color: Theme.of(context).scaffoldBackgroundColor),
                    //       boxShadow: [
                    //         BoxShadow(
                    //             spreadRadius: 2,
                    //             blurRadius: 10,
                    //             color: Colors.black.withOpacity(0.1),
                    //             offset: Offset(0, 10))
                    //       ],
                    //       shape: BoxShape.circle,
                    //       image: DecorationImage(
                    //           fit: BoxFit.cover,
                    //           image: NetworkImage(
                    //             "https://images.pexels.com/photos/3307758/pexels-photo-3307758.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=250",
                    //           ))),
                    // ),
                    // Positioned(
                    //     bottom: 0,
                    //     right: 0,
                    //     child: Container(
                    //       height: 40,
                    //       width: 40,
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         border: Border.all(
                    //           width: 4,
                    //           color: Theme.of(context).scaffoldBackgroundColor,
                    //         ),
                    //         color: Colors.lightGreen,
                    //       ),
                    //       child: Icon(
                    //         Icons.edit,
                    //         color: Colors.white,
                    //       ),
                    //     )),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              buildTextField("Full Name", username, true, false, false),
              buildTextField("E-mail", user_email, false, true, false),
              buildTextField("Password", "********", false, false, true),
              // buildTextField("Location", "TLV, Israel", false),
              SizedBox(
                height: 35,
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
                    child: Text("CANCEL",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (emailController.text !=
                          _firebaseAuth.currentUser.email) {
                        //                         _firebaseAuth.signInWithEmailAndPassword(email: null, password: null)
                        // .signInWithEmailAndPassword('you@domain.com', 'correcthorsebatterystaple')
                        // .then(function(userCredential) {
                        //     userCredential.user.updateEmail('newyou@domain.com')
                        // })

                        _firebaseAuth.currentUser
                            .updateEmail(emailController.text)
                            .then((value) => null)
                            .catchError((error) {
                          if (error.code == "invalid-email") {
                            Get.dialog(SimpleDialog(
                              title: Text(
                                "Error",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)),
                              children: [
                                Text(
                                    "     Invalid Email",
                                    style: TextStyle(fontSize: 20.0))
                              ],
                            ));
                          } else if (error.code == "email-already-in-use") {
                            Get.dialog(SimpleDialog(
                              title: Text(
                                "Error",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)),
                              children: [
                                Text(
                                    "    Email Already in Use",
                                    style: TextStyle(fontSize: 20.0))
                              ],
                            ));
                          } else {
                            Get.dialog(SimpleDialog(
                              title: Text(
                                "Error",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)),
                              children: [
                                Text(
                                    "    Error. Please contact our Support Team",
                                    style: TextStyle(fontSize: 20.0))
                              ],
                            ));
                          }
                        });
                      }
                      _firebaseAuth.currentUser
                          .updateProfile(displayName: usernameController.text)
                          .then((value) {
                        print("Profile has been changed successfully");
                        //DO Other compilation here if you want to like setting the state of the app
                      }).catchError((e) {
                        print("There was an error updating profile");
                      });
                      // setState(() {
                      //   username = usernameController.text;
                      // });
                      // updateUserData();
                    },
                    color: Colors.red[200],
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder, bool isFullName,
      bool isEmail, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: isFullName
            ? usernameController
            : isEmail
                ? emailController
                : null,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )
            ),
      ),
    );
  }
}
