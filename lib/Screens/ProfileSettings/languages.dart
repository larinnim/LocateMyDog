import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading.dart';

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
  String _currentLang = "english";
  int lang = 1;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _buttonOptions = [
    LanguageValue(1, 'english'.tr),
    LanguageValue(2, "french".tr),
    LanguageValue(3, "spanish".tr),
    LanguageValue(4, "portuguese".tr),
  ];

  void _updateLanguage(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (val == 1) {
      _currentLang = "english";
      Get.updateLocale(Locale('en', 'US'));
      prefs.setString('lan', 'en');
      prefs.setString('countryLang', 'US');
    } else if (val == 2) {
      _currentLang = "french";
      Get.updateLocale(Locale('fr', 'CA'));
      prefs.setString('lan', 'fr');
      prefs.setString('countryLang', 'CA');
    } else if (val == 3) {
      _currentLang = "spanish";
      Get.updateLocale(Locale('es', 'ES'));
      prefs.setString('lan', 'es');
      prefs.setString('countryLang', 'ES');
    } else if (val == 4) {
      _currentLang = "portuguese";
      Get.updateLocale(Locale('pt', 'BR'));
      prefs.setString('lan', 'pt');
      prefs.setString('countryLang', 'BR');
    }

    _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .set({'language': val.toString()}, SetOptions(merge: true));
  }

  void getLanguage(String dblang) {
    if (dblang == null) {
      if (Get.locale.languageCode == 'pt') {
        lang = 4;
        _currentLang = "portuguese";
      } else if (Get.locale.languageCode == 'en') {
        lang = 1;
        _currentLang = 'english';
      } else if (Get.locale.languageCode == 'es') {
        lang = 3;
        _currentLang = "spanish";
      } else if (Get.locale.languageCode == 'fr') {
        lang = 2;
        _currentLang = "french";
      }
    }
    if (dblang == "1") {
      lang = 1;
      _currentLang = 'english';
    } else if (dblang == "2") {
      lang = 2;
      _currentLang = "french";
    } else if (dblang == "3") {
      lang = 3;
      _currentLang = "spanish";
    } else if (dblang == "4") {
      lang = 4;
      _currentLang = "portuguese";
    }
  }
  // void getLanguage(String lang) {
  //   if (lang == "English") {
  //     _currentLang = 1;
  //   } else if (lang == "Français") {
  //     _currentLang = 2;
  //   } else if (lang == "Espanhol") {
  //     _currentLang = 3;
  //   } else if (lang == "Português") {
  //     _currentLang = 4;
  //   }
  // }

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
          if (snapshot.connectionState != ConnectionState.done) {
            return Loading();
          } else if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data.data();
            // return Text("Full Name: ${data['full_name']} ${data['last_name']}");
            getLanguage(data['language']);
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                elevation: 1,
                title: Text(
                  "language".tr,
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
                          groupValue: lang,
                          title: Text(langVal._value.tr),
                          value: langVal._key,
                          onChanged: (val) {
                            setState(() {
                              debugPrint('VAL = $val');
                              lang = val;
                              // _currentLang = val;
                            });
                            //                           WidgetsBinding.instance
                            // .addPostFrameCallback((_) => setState(() {
                            // lang = val;
                            // }));
                            _updateLanguage(val);
                          },
                        ))
                    .toList(),
              ),
            );
          } else if (snapshot.hasError) {
            // Manage error
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
