import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthState { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  String? _token;
  String? get token => _token;

  AuthViewModel(ApiService apiService) : _authService = AuthService(apiService);

  Future<void> login(String documento, String password) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.login(documento, password);
      _token = result['access_token'] as String;
      _user = User.fromJson(result['cliente'] as Map<String, dynamic>);
      _state = AuthState.success;
    } on ApiException catch (e) {
      if (e.isBlocked) {
        _errorMessage = 'Usuario bloqueado por intentos fallidos';
      } else if (e.isUnauthorized) {
        _errorMessage = 'Usuario o contraseña incorrectos';
      } else {
        _errorMessage = e.message;
      }
      _state = AuthState.error;
    } on http.ClientException catch (e) {
      _errorMessage = 'No se puede conectar al servidor. Verifica tu conexión e intenta de nuevo.';
      _state = AuthState.error;
    } catch (e) {
      _errorMessage = 'Error de conexión: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  void logout() {
    _authService.logout();
    _token = null;
    _user = null;
    _state = AuthState.initial;
    _errorMessage = '';
    notifyListeners();
  }

  void resetState() {
    _state = AuthState.initial;
    _errorMessage = '';
    notifyListeners();
  }
}