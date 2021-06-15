import 'package:flutter/material.dart';

class AuxFunc {
  String colorCodeFromName(String colorName) {
    var _color = "";
    switch (colorName) {
      case "green":
        {
          _color = '#00ff08';
        }
        break;

      case "orange":
        {
          _color = "#ff6200";
        }
        break;

      case "purple":
        {
          _color = "#a200ff";
        }
        break;

      default:
        {
          _color = "#ff0000";
        }
        break;
    }
    return _color;
  }

  Color getColor(String? color) {
    var _color = Colors.white;
    switch (color) {
      case "green":
        {
          _color = Colors.green;
        }
        break;

      case "orange":
        {
          _color = Colors.orange;
        }
        break;

      case "purple":
        {
          _color = Colors.purple;
        }
        break;

      default:
        {
          _color = Colors.red;
        }
        break;
    }
    return _color;
  }

  String colorNamefromColor(Color? color) {
    var _color = 'white';
    if (color == Colors.green) {
      _color = 'green';
    } else if (color == Colors.orange) {
      _color = 'orange';
    } else if (color == Colors.purple) {
      _color = 'purple';
    } else {
      _color = 'red';
    }
    return _color;
  }
}
