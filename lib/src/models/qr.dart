class QR {
  int idClase;
  String asignatura;
  bool estadoActivo;
  String token;

  QR({this.idClase,this.asignatura,this.estadoActivo,this.token});
  
  factory QR.fromJson(Map<String, dynamic> json) {
    return QR(
      idClase: json['idClase'],
      asignatura:json['asignatura'],
      estadoActivo: json['estadoActivo'],
      token:json['token']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idClase': idClase,
      'estadoActivo':estadoActivo,
      'token': token,
      'asignatura':asignatura
    };
  }

}