import 'package:flutter/material.dart';

class MyTheme {
  static Color background = PhoneTheme.background;
  static Color foreground = PhoneTheme.foreground;
  static Color background51 = PhoneTheme.background51;
  static Color foreground62 = PhoneTheme.foreground62;
  static TextStyle miniStyle = PhoneTheme.miniStyle;
  static TextStyle narmalStyle = PhoneTheme.narmalStyle;
  static TextStyle bigStyle = PhoneTheme.bigStyle;
  static double minIconSize = PhoneTheme.minIconSize;
  static double narmalIconSize = PhoneTheme.narmalIconSize;
  static double bigIconSize = PhoneTheme.bigIconSize;
}

class PhoneTheme {
  static Color background = const Color.fromRGBO(31, 31, 41, 1);
  static Color foreground = const Color.fromRGBO(37, 39, 51, 1);
  static Color background51 = const Color.fromRGBO(37, 39, 51, 1);
  static Color foreground62 = const Color.fromRGBO(48, 50, 62, 1);
  static TextStyle miniStyle =
      const TextStyle(color: Colors.white, fontSize: 13);
  static TextStyle narmalStyle =
      const TextStyle(color: Colors.white, fontSize: 15);
  static TextStyle bigStyle =
      const TextStyle(color: Colors.white, fontSize: 17);
  static double minIconSize = 20;
  static double narmalIconSize = 25;
  static double bigIconSize = 35;
}
