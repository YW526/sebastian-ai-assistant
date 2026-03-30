import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    fontFamily: 'Mona12',
    //accentColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
    ),
  );

  // 👉 스플래시 전용 배경색 추가
  static const splash = Colors.black;
}