import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LanguageValue {
  final int _key;
  final String _value;
  LanguageValue(this._key, this._value);
}

class LanguagesPage extends StatefulWidget {
  @override
  LanguagesPageState createState() => LanguagesPageState();
}

class LanguagesPageState extends State<LanguagesPage> {
  int _currentLang = 1;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _buttonOptions = [
    LanguageValue(1, "English"),
    LanguageValue(2, "Français"),
    LanguageValue(3, "Espanhol"),
    LanguageValue(4, "Português"),
  ];

  void _updateLanguage(int val) {
    String lang;

    if (val == 1) {
      lang = "English";
    } else if (val == 2) {
      lang = "Français";
    } else if (val == 3) {
      lang = "Espanhol";
    } else if (val == 4) {
      lang = "Português";
    }

    _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .set({'language': lang}, SetOptions(merge: true));
  }

  void getLanguage(String lang) {
    if (lang == "English") {
      _currentLang = 1;
    } else if (lang == "Français") {
      _currentLang = 2;
    } else if (lang == "Espanhol") {
      _currentLang = 3;
    } else if (lang == "Português") {
      _currentLang = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(_firebaseAuth.currentUser.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
// if (snapshot.hasError) {
//           return Text("Something went wrong");
//         }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            // return Text("Full Name: ${data['full_name']} ${data['last_name']}");
            getLanguage(data['language']);
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                elevation: 1,
                title: Text(
                  "Languages",
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
              body: ListView(
                padding: EdgeInsets.all(8.0),
                children: _buttonOptions
                    .map((langVal) => RadioListTile(
                          activeColor: Colors.red[300],
                          groupValue: _currentLang,
                          title: Text(langVal._value),
                          value: langVal._key,
                          onChanged: (val) {
                            _updateLanguage(val);
                            setState(() {
                              debugPrint('VAL = $val');
                              _currentLang = val;
                            });
                          },
                        ))
                    .toList(),
              ),
            );
          }
          return Container(
            color: Colors.white,
            child: SpinKitCircle(
              color: Colors.red,
              size: 30.0,
            ),
          );
        });
  }
}
