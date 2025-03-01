import 'package:flutter/material.dart';

class ColorPalette {
  static const scaffoldColor = Color.fromARGB(255, 213, 219, 223);
  static const primaryColor = Color(0xFF27379B);
  static const light1 = Color(0xFFF5F6FA);
  static const light2 = Color(0xFF8F959E);
  static const dark1 = Color(0xFF1D1E20);
  static const dark2 = Color(0xFF29363D);
  static const darkgreen = Color.fromARGB(255, 41, 135, 24);
}

ThemeData buildTheme() {
  return ThemeData(
    scaffoldBackgroundColor: ColorPalette.scaffoldColor,
    primaryColor: ColorPalette.primaryColor,
    colorScheme: ColorScheme.light(
      primary: ColorPalette.primaryColor,
      secondary: ColorPalette.light2,
      surface: ColorPalette.light1,
      onPrimary: Colors.white,
      onSecondary: ColorPalette.dark1,
      onSurface: ColorPalette.dark1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorPalette.scaffoldColor,
      titleTextStyle: TextStyle(
        color: ColorPalette.dark2,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      surfaceTintColor: ColorPalette.scaffoldColor,
      iconTheme: IconThemeData(color: ColorPalette.dark2),
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorPalette.light1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorPalette.light2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorPalette.light2),
      ),
      hintStyle: TextStyle(color: ColorPalette.light2),
      labelStyle: TextStyle(color: ColorPalette.dark1),
    ),
    textTheme: TextTheme(
        // headline1: TextStyle(
        //   fontSize: 32,
        //   fontWeight: FontWeight.bold,
        //   color: ColorPalette.dark1,
        // ),
        // bodyText1: TextStyle(
        //   fontSize: 16,
        //   color: ColorPalette.dark1,
        // ),
        // bodyText2: TextStyle(
        //   fontSize: 14,
        //   color: ColorPalette.light2,
        // ),
        // button: TextStyle(
        //   fontSize: 16,
        //   color: Colors.white,
        //   fontWeight: FontWeight.bold,
        // ),
        ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      buttonColor: ColorPalette.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    iconTheme: IconThemeData(color: ColorPalette.dark1),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorPalette.primaryColor,
      foregroundColor: Colors.white,
    ),
    dividerColor: ColorPalette.light2,
    chipTheme: ChipThemeData(
      backgroundColor: ColorPalette.light1,
      selectedColor: ColorPalette.primaryColor,
      secondarySelectedColor: ColorPalette.primaryColor.withOpacity(0.7),
      labelStyle: TextStyle(color: ColorPalette.dark1),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.light,
    ),
  );
}
