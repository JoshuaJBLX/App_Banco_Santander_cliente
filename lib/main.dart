import 'package:flutter/material.dart';
import 'theme/app_theme.dart';  // ← Cambiado: import relativo
import 'views/auth/login_screen.dart';  // ← Cambiado: import relativo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crediscotia Clientes',
      theme: CrediscotiaTheme.lightTheme,
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}