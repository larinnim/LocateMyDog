import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 1,
        title: Text(
          "Change Email",
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
        child: Column(
  children: <Widget>[
                  Padding(
            padding: const EdgeInsets.only(bottom: 35.0),
            child: TextField(
              // obscureText: isPasswordTextField ? showPassword : false,
              decoration: InputDecoration(
                  // suffixIcon: isPasswordTextField
                  //     ? IconButton(
                  //         onPressed: () {
                  //           setState(() {
                  //             showPassword = !showPassword;
                  //           });
                  //         },
                  //         icon: Icon(
                  //           Icons.remove_red_eye,
                  //           color: Colors.grey,
                  //         ),
                  //       )
                  //     : null,
                  contentPadding: EdgeInsets.only(bottom: 3),
                  labelText: "Email",
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
                height: 35,
              ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35.0),
            child: TextField(
              obscureText: showPassword,
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
                  labelText: "Password",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
          ),
   ] ),
      ),
    );
  }
}
