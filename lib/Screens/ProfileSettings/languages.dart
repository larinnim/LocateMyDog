import 'package:flutter/material.dart';

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

  final _buttonOptions = [
    LanguageValue(1, "English"),
    LanguageValue(2, "Français"),
    LanguageValue(3, "Espanhol"),
    LanguageValue(4, "Português"),
  ];

  @override
  Widget build(BuildContext context) {
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
}
