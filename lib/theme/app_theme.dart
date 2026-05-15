import 'package:flutter/material.dart';

class CrediscotiaTheme {
  // Actualizar color primario a Rojo
  static const Color primary = Color.fromARGB(255, 255, 0, 43); // Código rojo de ejemplo
  static const Color secondary = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFFFFFFF);

  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 255, 0, 43),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 255, 0, 43), // App Bar Roja
      foregroundColor: Colors.white, // Texto e íconos blancos
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 0, 43), // Botón Rojo
        foregroundColor: Colors.white, // Texto del botón blanco
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromARGB(255, 255, 0, 43), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black87),
    ),
  );
}