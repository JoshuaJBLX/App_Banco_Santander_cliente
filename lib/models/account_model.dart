class SavingsAccount {
  final String id;
  final String codCuentaAhorro;
  final String? tipoCuenta;
  final String? moneda;
  final double? saldoCapital;
  final double? saldoInteres;
  final double? tea;
  final String? estado;

  SavingsAccount({
    required this.id,
    required this.codCuentaAhorro,
    this.tipoCuenta,
    this.moneda,
    this.saldoCapital,
    this.saldoInteres,
    this.tea,
    this.estado,
  });

  double get saldoTotal =>
      (saldoCapital ?? 0) + (saldoInteres ?? 0);

  String get saldoFormateado =>
      'S/ ${saldoTotal.toStringAsFixed(2)}';

  factory SavingsAccount.fromJson(Map<String, dynamic> json) {
    return SavingsAccount(
      id: json['id']?.toString() ?? '',
      codCuentaAhorro: json['cod_cuenta_ahorro']?.toString() ?? '',
      tipoCuenta: json['tipo_cuenta']?.toString(),
      moneda: json['moneda']?.toString(),
      saldoCapital: _toDouble(json['saldo_capital']),
      saldoInteres: _toDouble(json['saldo_interes']),
      tea: _toDouble(json['tea']),
      estado: json['estado']?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class CreditAccount {
  final String id;
  final String codCuentaCredito;
  final String? producto;
  final double? montoDesembolsado;
  final double? saldoCapital;
  final double? saldoTotal;
  final int diasMora;
  final String? calificacionInterna;
  final String? estado;
  final String? fechaDesembolso;
  final double? tea;
  final int? cuotasTotal;
  final int? cuotasPagadas;

  CreditAccount({
    required this.id,
    required this.codCuentaCredito,
    this.producto,
    this.montoDesembolsado,
    this.saldoCapital,
    this.saldoTotal,
    this.diasMora = 0,
    this.calificacionInterna,
    this.estado,
    this.fechaDesembolso,
    this.tea,
    this.cuotasTotal,
    this.cuotasPagadas,
  });

  String get saldoFormateado =>
      'S/ ${(saldoTotal ?? 0).toStringAsFixed(2)}';

  factory CreditAccount.fromJson(Map<String, dynamic> json) {
    return CreditAccount(
      id: json['id']?.toString() ?? '',
      codCuentaCredito: json['cod_cuenta_credito']?.toString() ?? '',
      producto: json['producto']?.toString(),
      montoDesembolsado: _toDouble(json['monto_desembolsado']),
      saldoCapital: _toDouble(json['saldo_capital']),
      saldoTotal: _toDouble(json['saldo_total']),
      diasMora: json['dias_mora'] is int
          ? json['dias_mora'] as int
          : int.tryParse(json['dias_mora']?.toString() ?? '0') ?? 0,
      calificacionInterna: json['calificacion_interna']?.toString(),
      estado: json['estado']?.toString(),
      fechaDesembolso: json['fecha_desembolso']?.toString(),
      tea: _toDouble(json['tea']),
      cuotasTotal: json['cuotas_total'] is int
          ? json['cuotas_total'] as int
          : int.tryParse(json['cuotas_total']?.toString() ?? ''),
      cuotasPagadas: json['cuotas_pagadas'] is int
          ? json['cuotas_pagadas'] as int
          : int.tryParse(json['cuotas_pagadas']?.toString() ?? ''),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class Installment {
  final String id;
  final String codCuentaCredito;
  final int nroCuota;
  final String fechaVencimiento;
  final double? montoCuota;
  final double? montoCapital;
  final double? montoInteres;
  final double? saldo;
  final String? estadoCuota;
  final String? fechaPago;

  Installment({
    required this.id,
    required this.codCuentaCredito,
    required this.nroCuota,
    required this.fechaVencimiento,
    this.montoCuota,
    this.montoCapital,
    this.montoInteres,
    this.saldo,
    this.estadoCuota,
    this.fechaPago,
  });

  bool get pagada => estadoCuota?.toLowerCase() == 'pagada';

  String get montoFormateado =>
      'S/ ${(montoCuota ?? 0).toStringAsFixed(2)}';

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      id: json['id']?.toString() ?? '',
      codCuentaCredito: json['cod_cuenta_credito']?.toString() ?? '',
      nroCuota: json['nro_cuota'] is int
          ? json['nro_cuota'] as int
          : int.tryParse(json['nro_cuota']?.toString() ?? '0') ?? 0,
      fechaVencimiento: json['fecha_vencimiento']?.toString() ?? '',
      montoCuota: _toDouble(json['monto_cuota']),
      montoCapital: _toDouble(json['monto_capital']),
      montoInteres: _toDouble(json['monto_interes']),
      saldo: _toDouble(json['saldo']),
      estadoCuota: json['estado_cuota']?.toString(),
      fechaPago: json['fecha_pago']?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class CardInfo {
  final String id;
  final String numeroEnmascarado;
  final String? marca;
  final double? lineaCredito;
  final double? saldoUtilizado;
  final String? fechaCorte;
  final String? fechaPago;
  final String? estado;

  CardInfo({
    required this.id,
    required this.numeroEnmascarado,
    this.marca,
    this.lineaCredito,
    this.saldoUtilizado,
    this.fechaCorte,
    this.fechaPago,
    this.estado,
  });

  double get saldoDisponible =>
      (lineaCredito ?? 0) - (saldoUtilizado ?? 0);

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      id: json['id']?.toString() ?? '',
      numeroEnmascarado: json['numero_enmascarado']?.toString() ?? '',
      marca: json['marca']?.toString(),
      lineaCredito: _toDouble(json['linea_credito']),
      saldoUtilizado: _toDouble(json['saldo_utilizado']),
      fechaCorte: json['fecha_corte']?.toString(),
      fechaPago: json['fecha_pago']?.toString(),
      estado: json['estado']?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class Movement {
  final String id;
  final String codOperacion;
  final String? codCuenta;
  final String? tipo;
  final String? concepto;
  final String? canal;
  final double monto;
  final String? moneda;
  final String fechaOperacion;

  Movement({
    required this.id,
    required this.codOperacion,
    this.codCuenta,
    this.tipo,
    this.concepto,
    this.canal,
    required this.monto,
    this.moneda,
    required this.fechaOperacion,
  });

  bool get esIngreso => tipo == 'CRE' || tipo == 'TRF';
  bool get esEgreso => tipo == 'DEB';

  String get montoFormateado => '${esIngreso ? '+' : '-'} S/ ${monto.toStringAsFixed(2)}';

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: json['id']?.toString() ?? '',
      codOperacion: json['cod_operacion']?.toString() ?? '',
      codCuenta: json['cod_cuenta']?.toString(),
      tipo: json['tipo']?.toString(),
      concepto: json['concepto']?.toString(),
      canal: json['canal']?.toString(),
      monto: _toDouble(json['monto']) ?? 0,
      moneda: json['moneda']?.toString(),
      fechaOperacion: json['fecha_operacion']?.toString() ?? '',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class NotificationInfo {
  final String id;
  final String titulo;
  final String? cuerpo;
  final String? tipo;
  final bool leida;
  final String createdAt;

  NotificationInfo({
    required this.id,
    required this.titulo,
    this.cuerpo,
    this.tipo,
    this.leida = false,
    required this.createdAt,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> json) {
    return NotificationInfo(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      cuerpo: json['cuerpo']?.toString(),
      tipo: json['tipo']?.toString(),
      leida: json['leida'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}