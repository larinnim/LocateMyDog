import 'package:flutter/material.dart';

class AuxFunc {
  Color getColor(String color) {
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

  String colorNamefromColor(Color color) {
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
