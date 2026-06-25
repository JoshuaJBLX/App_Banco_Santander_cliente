import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  Future<Map<String, dynamic>> login(String documento, String password) async {
    final result = await _api.post(
      '/cliente/login',
      {
        'numero_documento': documento,
        'password': password,
      },
    );
    final token = result['access_token'] as String;
    _api.setToken(token);
    return result as Map<String, dynamic>;
  }

  void logout() {
    _api.clearToken();
  }
}