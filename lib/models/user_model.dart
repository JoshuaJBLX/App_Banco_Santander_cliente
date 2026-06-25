class User {
  final String id;
  final String? codCliente;
  final String numeroDocumento;
  final String nombres;
  final String apellidos;
  final String? email;
  final String? telefono;

  User({
    required this.id,
    this.codCliente,
    required this.numeroDocumento,
    required this.nombres,
    required this.apellidos,
    this.email,
    this.telefono,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      codCliente: json['cod_cliente']?.toString(),
      numeroDocumento: json['numero_documento']?.toString() ?? '',
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      email: json['email']?.toString(),
      telefono: json['telefono']?.toString(),
    );
  }
}