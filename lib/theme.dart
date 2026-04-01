import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Gruber Darker Palette
const gruberBg = Color(0xFF181818);
const gruberBgDarker = Color(0xFF101010);
const gruberBgLighter = Color(0xFF282828);
const gruberFg = Color(0xFFE4E4EF);
const gruberYellow = Color(0xFFFFDD33);
const gruberGreen = Color(0xFF73C936);
const gruberBrown = Color(0xFFCC8C3C);
const gruberOrange = Color(0xFFFF8833);
const gruberQuartz = Color(0xFF95A99F); // Comments
const gruberNiagara = Color(0xFF96A6C8); // Types
const gruberWisteria = Color(0xFF9E95C7); // Variables
const gruberRed = Color(0xFFF43841);

final portfolioTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.firaCode().fontFamily,

  // Color Scheme
  colorScheme: const ColorScheme.dark(
    primary: gruberYellow,
    surface: gruberBg,
    surfaceContainerHighest: gruberBgLighter,
    onPrimary: Colors.black,
    onSurface: gruberFg,
    tertiary: gruberBrown,
    secondary: gruberGreen,
    error: gruberRed,
  ),

  // Scaffold Background
  scaffoldBackgroundColor: gruberBgDarker,

  // Text Theme
  textTheme: GoogleFonts.firaCodeTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: gruberFg,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: gruberYellow,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: gruberFg,
      ),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: gruberFg),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    elevation: 0,
    color: gruberBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: gruberBgLighter, width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 10),
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: gruberBgLighter,
    disabledColor: gruberBgDarker,
    selectedColor: gruberYellow,
    secondarySelectedColor: gruberYellow,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    labelStyle: const TextStyle(color: gruberFg, fontWeight: FontWeight.w500),
    brightness: Brightness.dark,
  ),

  // Floating Action Button
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: gruberYellow,
    foregroundColor: Colors.black,
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: gruberBgLighter,
    thickness: 1,
    space: 40,
  ),

  // Text Selection Theme
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: gruberYellow.withAlpha((255 * 0.3).round()),
    selectionHandleColor: gruberYellow,
  ),
);
