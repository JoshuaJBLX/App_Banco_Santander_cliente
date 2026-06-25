import 'package:flutter/material.dart';

class CreditRequest {
  final String numeroExpediente;
  final String estado;
  final String? producto;
  final double montoSolicitado;
  final int plazoMeses;
  final double tea;
  final String? garantia;
  final String? destinoCredito;
  final String? tipoNegocio;
  final String? nombreNegocio;
  final int? antiguedadNegocioMeses;
  final double? ingresosEstimados;
  final double? gastosMensuales;
  final String? telefono;
  final String clienteDocumento;
  final DateTime? fechaSolicitud;
  final String? asesorAsignado;
  final double? montoAprobado;
  final String? motivoRechazo;
  final String canal;

  CreditRequest({
    required this.numeroExpediente,
    required this.estado,
    this.producto,
    required this.montoSolicitado,
    required this.plazoMeses,
    required this.tea,
    this.garantia,
    this.destinoCredito,
    this.tipoNegocio,
    this.nombreNegocio,
    this.antiguedadNegocioMeses,
    this.ingresosEstimados,
    this.gastosMensuales,
    this.telefono,
    required this.clienteDocumento,
    this.fechaSolicitud,
    this.asesorAsignado,
    this.montoAprobado,
    this.motivoRechazo,
    this.canal = 'cliente',
  });

  String get estadoFormateado {
    switch (estado.toLowerCase()) {
      case 'enviado':
        return 'Enviado';
      case 'recibido_comite':
        return 'Recibido por Comité';
      case 'en_evaluacion':
        return 'En Evaluación';
      case 'aprobado':
        return 'Aprobado';
      case 'condicionado':
        return 'Condicionado';
      case 'rechazado':
        return 'Rechazado';
      case 'desembolsado':
        return 'Desembolsado';
      default:
        return estado;
    }
  }

  Color get estadoColor {
    switch (estado.toLowerCase()) {
      case 'enviado':
        return Colors.orange;
      case 'recibido_comite':
        return Colors.deepOrange;
      case 'en_evaluacion':
        return Colors.blue;
      case 'aprobado':
        return Colors.green;
      case 'condicionado':
        return Colors.amber;
      case 'rechazado':
        return Colors.red;
      case 'desembolsado':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get estadoIcon {
    switch (estado.toLowerCase()) {
      case 'enviado':
        return Icons.pending_outlined;
      case 'recibido_comite':
        return Icons.assignment_outlined;
      case 'en_evaluacion':
        return Icons.search_outlined;
      case 'aprobado':
        return Icons.check_circle_outline;
      case 'condicionado':
        return Icons.warning_amber_outlined;
      case 'rechazado':
        return Icons.cancel_outlined;
      case 'desembolsado':
        return Icons.payments_outlined;
      default:
        return Icons.help_outline;
    }
  }

  factory CreditRequest.fromJson(Map<String, dynamic> json) {
    return CreditRequest(
      numeroExpediente: json['numero_expediente']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'enviado',
      producto: json['producto']?.toString(),
      montoSolicitado: _toDouble(json['monto_solicitado']) ?? 0,
      plazoMeses: json['plazo_meses'] is int
          ? json['plazo_meses'] as int
          : int.tryParse(json['plazo_meses']?.toString() ?? '0') ?? 0,
      tea: _toDouble(json['tea']) ?? 0,
      garantia: json['garantia']?.toString(),
      destinoCredito: json['destino_credito']?.toString(),
      tipoNegocio: json['tipo_negocio']?.toString(),
      nombreNegocio: json['nombre_negocio']?.toString(),
      antiguedadNegocioMeses: json['antiguedad_negocio_meses'] is int
          ? json['antiguedad_negocio_meses'] as int
          : int.tryParse(json['antiguedad_negocio_meses']?.toString() ?? ''),
      ingresosEstimados: _toDouble(json['ingresos_estimados']),
      gastosMensuales: _toDouble(json['gastos_mensuales']),
      telefono: json['telefono']?.toString(),
      clienteDocumento: json['cliente_documento']?.toString() ?? '',
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.tryParse(json['fecha_solicitud'].toString())
          : null,
      asesorAsignado: json['asesor_asignado']?.toString(),
      montoAprobado: _toDouble(json['monto_aprobado']),
      motivoRechazo: json['motivo_rechazo']?.toString(),
      canal: json['canal']?.toString() ?? 'cliente',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}