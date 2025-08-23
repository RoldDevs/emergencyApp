import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; 

class AppTheme {
  // Main colors
  static const Color primaryColor = Color(0xFFE53935); 
  static const Color secondaryColor = Color(0xFFFFFFFF); 
  static const Color accentColor = Color(0xFFC62828); 
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Background colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  
  // Get the light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      // Set Poppins as the default font family
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: secondaryColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      // ... existing code ...
    );
  }
  
  // Configure system UI overlay style
  static void configureSystemUI() {
    // Apply system UI style with explicit colors
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: primaryColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: secondaryColor, 
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    
    // Show both top and bottom system UI elements
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, // Changed back to edgeToEdge for better appearance
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
}