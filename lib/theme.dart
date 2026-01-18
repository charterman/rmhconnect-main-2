import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CharityConnectTheme {
  static const Color primaryColor = Color(0xFF0B3BA3); // Deep blue
  static const Color accentColor = Color(0xFF6C63FF); // Accent purple
  static const Color backgroundColor = Color(0xFFF8FAFB); // Light background
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF222B45); // Dark text
  static const Color secondaryTextColor = Color(0xFF8F9BB3); // Secondary text
  static const Color buttonColor = Color(0xFF4F8CFF); // Button blue
  static const Color successColor = Color(0xFF00C48C); // Green
  static const Color warningColor = Color(0xFFFFA726); // Orange
  static const Color errorColor = Color(0xFFFF3D71); // Red

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.atkinsonHyperlegibleTextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.atkinsonHyperlegible(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.atkinsonHyperlegible(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: cardColor,
        hintStyle: TextStyle(color: secondaryTextColor),
      ),
    );
  }
}