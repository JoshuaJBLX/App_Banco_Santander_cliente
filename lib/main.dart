import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'views/auth/login_screen.dart';

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
      home: LoginScreen(apiService: ApiService()),
      debugShowCheckedModeBanner: false,
    );
  }
}