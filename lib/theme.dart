import 'package:flutter/material.dart';

const primaryColor = Color(0xFFFFD600); // A strong, vibrant yellow
const backgroundColor = Colors.black; // A deep, dark background
const surfaceColor = Color(0xFF1E1E1E); // A slightly lighter dark for cards
const onPrimaryColor = Colors.black;
const onSurfaceColor = Colors.white;

final portfolioTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Iosevka',

  // Color Scheme
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    surface: surfaceColor,
    onPrimary: onPrimaryColor,
    onSurface: onSurfaceColor,
    tertiary: primaryColor,
  ),

  // Scaffold Background
  scaffoldBackgroundColor: backgroundColor,

  // Text Theme
  textTheme: const TextTheme(
    // For main headers like the name
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: onSurfaceColor,
    ),
    // For section titles
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: primaryColor, // Use primary color for emphasis
    ),
    // For project/job titles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: onSurfaceColor,
    ),
    // For body text/descriptions
    bodyMedium: TextStyle(
      fontSize: 16,
      height: 1.5, // Improved readability
      color: onSurfaceColor,
    ),
    // For skill chips/tags
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: onPrimaryColor,
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    elevation: 4,
    color: surfaceColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 10),
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    // backgroundColor: primaryColor, // Removed to rely on AnimatedContainer
    disabledColor: backgroundColor,
    selectedColor: primaryColor,
    secondarySelectedColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    labelStyle: const TextStyle(
      color: onPrimaryColor, // Reverted to original
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(),
    brightness: Brightness.dark,
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: surfaceColor,
    thickness: 1,
    space: 40,
  ),

  // Text Selection Theme
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: primaryColor.withAlpha((255 * 0.4).round()),
    selectionHandleColor: primaryColor,
  ),
);
