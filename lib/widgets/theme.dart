import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final myTheme = ThemeData(
// Define the default brightness and colors.
  brightness: Brightness.light,
  primaryColor: Color.fromRGBO(9, 79, 239, 1),
  accentColor: Colors.cyan[600],
  textTheme: TextTheme(bodyText1: GoogleFonts.openSans()),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.normal,
  ),

// Define the default font family.
  fontFamily: 'Avenir',

// Define the default TextTheme. Use this to specify the default
// text styling for headlines, titles, bodies of text, and more.
//  textTheme: TextTheme(
//    headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//    title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//    body: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//  ),
);
