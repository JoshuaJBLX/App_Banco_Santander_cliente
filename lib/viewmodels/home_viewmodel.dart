import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/account_model.dart';
import '../models/credit_request_model.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _api;

  User? _user;
  User? get user => _user;

  List<SavingsAccount> _savingsAccounts = [];
  List<SavingsAccount> get savingsAccounts => _savingsAccounts;

  List<CreditAccount> _creditAccounts = [];
  List<CreditAccount> get creditAccounts => _creditAccounts;

  List<Movement> _movements = [];
  List<Movement> get movements => _movements;

  List<CardInfo> _cards = [];
  List<CardInfo> get cards => _cards;

  List<NotificationInfo> _notifications = [];
  List<NotificationInfo> get notifications => _notifications;

  List<CreditRequest> _solicitudes = [];
  List<CreditRequest> get solicitudes => _solicitudes;

  bool _loading = false;
  bool get loading => _loading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Saldo total de todas las cuentas
  double get totalBalance {
    double total = 0;
    for (final acc in _savingsAccounts) {
      total += acc.saldoTotal;
    }
    return total;
  }

  HomeViewModel(this._api);

  Future<void> loadUserProfile() async {
    try {
      final result = await _api.get('/cliente/perfil');
      _user = User.fromJson(result);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Error al cargar perfil';
      notifyListeners();
    }
  }

  Future<void> loadAllData() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Cargar todo en paralelo
      final results = await Future.wait([
        _api.get('/cliente/perfil'),
        _api.get('/cliente/cuentas'),
        _api.get('/cliente/creditos'),
        _api.get('/cliente/movimientos?limit=20'),
        _api.get('/cliente/tarjetas'),
        _api.get('/cliente/notificaciones'),
      ]);

      _user = User.fromJson(results[0] as Map<String, dynamic>);
      _savingsAccounts = (results[1] as List<dynamic>)
          .map((j) => SavingsAccount.fromJson(j as Map<String, dynamic>))
          .toList();
      _creditAccounts = (results[2] as List<dynamic>)
          .map((j) => CreditAccount.fromJson(j as Map<String, dynamic>))
          .toList();
      _movements = (results[3] as List<dynamic>)
          .map((j) => Movement.fromJson(j as Map<String, dynamic>))
          .toList();
      _cards = (results[4] as List<dynamic>)
          .map((j) => CardInfo.fromJson(j as Map<String, dynamic>))
          .toList();
      _notifications = (results[5] as List<dynamic>)
          .map((j) => NotificationInfo.fromJson(j as Map<String, dynamic>))
          .toList();

      _errorMessage = '';
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar datos';
    }

    _loading = false;
    notifyListeners();
  }

  Future<List<Installment>> loadInstallments(String creditCode) async {
    try {
      final result = await _api.get('/cliente/creditos/$creditCode/cronograma')
          as List<dynamic>;
      return result
          .map((j) => Installment.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> realizarOperacion({
    required String cuentaOrigen,
    String? cuentaDestino,
    required String tipo,
    required double monto,
  }) async {
    try {
      await _api.post('/cliente/operaciones', {
        'cod_cuenta_origen': cuentaOrigen,
        'cod_cuenta_destino': cuentaDestino,
        'tipo': tipo,
        'monto': monto,
        'moneda': 'PEN',
      });
      // Recargar datos después de la operación
      await loadAllData();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Error al realizar operación';
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> crearSolicitudCredito({
    required double monto,
    required int plazoMeses,
    required String producto,
    required double tea,
    required String garantia,
    required String destinoCredito,
    required String tipoNegocio,
    required String nombreNegocio,
    required int antiguedadNegocioMeses,
    required double ingresosEstimados,
    required double gastosMensuales,
    required String telefono,
    double? lat,
    double? lng,
  }) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _api.post('/cliente/solicitudes', {
        'cliente_documento': _user?.numeroDocumento ?? '',
        'canal': 'cliente',
        'producto': producto,
        'monto_solicitado': monto,
        'plazo_meses': plazoMeses,
        'tea': tea,
        'garantia': garantia,
        'destino_credito': destinoCredito,
        'tipo_negocio': tipoNegocio,
        'nombre_negocio': nombreNegocio,
        'antiguedad_negocio_meses': antiguedadNegocioMeses,
        'ingresos_estimados': ingresosEstimados,
        'gastos_mensuales': gastosMensuales,
        'telefono': telefono,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      });

      _loading = false;
      notifyListeners();
      return result as Map<String, dynamic>;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error al registrar solicitud';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadSolicitudes() async {
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _api.get('/cliente/solicitudes') as List<dynamic>;
      _solicitudes = result
          .map((j) => CreditRequest.fromJson(j as Map<String, dynamic>))
          .toList();
      _errorMessage = '';
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar solicitudes';
    }

    notifyListeners();
  }

  Future<CreditRequest?> getSolicitudDetalle(String numeroExpediente) async {
    try {
      final result = await _api.get('/cliente/solicitudes/$numeroExpediente');
      return CreditRequest.fromJson(result as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void logout() {
    _user = null;
    _savingsAccounts = [];
    _creditAccounts = [];
    _movements = [];
    _cards = [];
    _notifications = [];
    _solicitudes = [];
    notifyListeners();
  }
}