import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:http/http.dart' as http;

/// Cliente HTTP del backend FastAPI mobile (puerto 8003).
///
/// Base URL según el dispositivo:
///  - Emulador Android: http://10.0.2.2:8003
///  - iOS simulator / Web local: http://localhost:8003
///  - Dispositivo físico (misma WiFi): IP LAN de tu PC -> http://192.168.x.x:8003
///
/// Mantiene el token JWT en memoria y lo adjunta como Bearer en cada request.
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8003',
  );

  String? _token;

  void setToken(String? token) => _token = token;
  void clearToken() => _token = null;
  bool get hasToken => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) async {
    final url = _uri(path);
    if (kDebugMode) {
      debugPrint('TOKEN: ${_token != null ? "${_token!.substring(0, 20)}..." : "null"}');
      debugPrint('GET URL: $url');
    }
    final res = await _http
        .get(url, headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (kDebugMode) {
      debugPrint('STATUS: ${res.statusCode}');
      debugPrint(
          'BODY: ${res.body.length > 500 ? "${res.body.substring(0, 500)}..." : res.body}');
    }
    return _procesar(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final url = _uri(path);
    if (kDebugMode) {
      debugPrint('POST URL: $url');
      debugPrint('BODY: $body');
    }
    final res = await _http
        .post(url, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (kDebugMode) {
      debugPrint('STATUS: ${res.statusCode}');
      debugPrint('RESPONSE: ${res.body}');
    }
    return _procesar(res);
  }

  final http.Client _http;

  ApiService([http.Client? client]) : _http = client ?? http.Client();

  dynamic _procesar(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final cuerpo = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (ok) return cuerpo;
    final detalle = (cuerpo is Map && cuerpo['detail'] != null)
        ? cuerpo['detail'].toString()
        : 'Error ${res.statusCode}';
    throw ApiException(res.statusCode, detalle);
  }
}

/// Error de API con código HTTP y mensaje del backend (campo `detail`).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isBlocked => statusCode == 423;
}