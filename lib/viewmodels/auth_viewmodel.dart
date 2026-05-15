import 'package:flutter/material.dart';

enum AuthState { loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.loading;
  AuthState get state => _state;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Credenciales hardcodeadas
  final String validUser = '12345678';
  final String validPass = '123456';

  void login(String user, String password) {
    _state = AuthState.loading;
    notifyListeners();

    // Simular delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (user == validUser && password == validPass) {
        _state = AuthState.success;
      } else {
        _state = AuthState.error;
        _errorMessage = 'Usuario o contraseña incorrectos';
      }
      notifyListeners();
    });
  }

  void resetState() {
    _state = AuthState.loading;
    notifyListeners();
  }
}