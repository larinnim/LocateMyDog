import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/Screens/Profile/avatar.dart';
import 'package:flutter_maps/Screens/ProfileSettings/settings_page.dart';
import 'package:flutter_maps/Services/constants.dart';
import 'package:flutter_maps/Services/user_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
              buildTextField("Full Name", "Dor Alex", false),
              buildTextField("E-mail", "alexd@gmail.com", false),
              buildTextField("Password", "********", true),
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
                    onPressed: () {},
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

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
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
            )),
      ),
    );
  }
}
