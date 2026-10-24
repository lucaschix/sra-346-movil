import 'dart:convert';

class QR {
  const QR({
    required this.idClase,
    required this.asignaturaId,
    required this.asignatura,
    required this.estadoActivo,
    required this.token,
  });

  final int idClase;
  final int asignaturaId;
  final String asignatura;
  final bool estadoActivo;
  final String token;

  factory QR.fromJson(Map<String, dynamic> json) {
    if (json['idClase'] is! int ||
        json['asignaturaId'] is! int ||
        json['asignatura'] is! String ||
        json['estadoActivo'] is! bool ||
        json['token'] is! String ||
        (json['token'] as String).isEmpty) {
      throw const FormatException('El código QR no contiene una clase válida');
    }
    return QR(
      idClase: json['idClase'],
      asignaturaId: json['asignaturaId'],
      asignatura: json['asignatura'],
      estadoActivo: json['estadoActivo'],
      token: json['token'],
    );
  }

  factory QR.fromScan(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('El código QR no contiene una clase válida');
    }
    final qr = QR.fromJson(decoded);
    if (!qr.estadoActivo)
      throw const FormatException('El código QR está inactivo');
    return qr;
  }

  Map<String, dynamic> toJson() => {
    'idClase': idClase,
    'asignaturaId': asignaturaId,
    'asignatura': asignatura,
    'estadoActivo': estadoActivo,
    'token': token,
  };
}
