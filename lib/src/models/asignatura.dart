class Asignatura {
  int asgId;
  String dasNombre;
  double asistencia;
  double atraso;
  double inasistencia;
  bool isExpanded = false;

  Asignatura(
      {this.asgId,
      this.dasNombre,
      this.asistencia,
      this.atraso,
      this.inasistencia});
  factory Asignatura.fromJson(Map<String, dynamic> json) {
    return Asignatura(
        asgId: json['asgId'],
        dasNombre: json['dasNombre'],
        asistencia: double.parse(json['asistencia'].toString()),
        atraso: double.parse(json['atraso'].toString()),
        inasistencia: double.parse(json['inasistencia'].toString()));
  }

  Map<String, dynamic> toJson() {
    return {
      'asgId': asgId,
      'dasNombre': dasNombre,
      'asistencia': asistencia,
      'atraso': atraso,
      'inasistencia': inasistencia
    };
  }
}
