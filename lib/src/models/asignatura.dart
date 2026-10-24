class Asignatura {
  int asgId;
  String dasNombre;
  double asistencia;
  double atraso;
  double inasistencia;
  bool isExpanded = false;

  Asignatura({
    this.asgId = 0,
    this.dasNombre = '',
    this.asistencia = 0,
    this.atraso = 0,
    this.inasistencia = 0,
  });
  factory Asignatura.fromJson(Map<String, dynamic> json) {
    return Asignatura(
      asgId: json['asgId'],
      dasNombre: json['dasNombre'],
      asistencia: double.parse(json['asistencia'].toString()),
      atraso: double.parse(json['atraso'].toString()),
      inasistencia: double.parse(json['inasistencia'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asgId': asgId,
      'dasNombre': dasNombre,
      'asistencia': asistencia,
      'atraso': atraso,
      'inasistencia': inasistencia,
    };
  }
}
