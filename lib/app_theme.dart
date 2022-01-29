import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Color> kDefaultRainbowColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

ThemeData appTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF52b788),
      secondary: Color(0xFF80ffdb),
    ),
    textTheme: TextTheme(
      headline1: GoogleFonts.kaushanScript(
        textStyle: const TextStyle(
          letterSpacing: 2,
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      headline2: GoogleFonts.ibmPlexMono(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
      headline3: GoogleFonts.ibmPlexMono(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      headline4: GoogleFonts.ibmPlexMono(
        textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    ),
  );
}
