class Register {
  int idClase;
  String estadoAsistencia;
  String numeroMatricula;
  String token;
  bool isExpanded = false;

  Register({
    this.idClase = 0,
    this.estadoAsistencia = '',
    this.numeroMatricula = '',
    this.token = '',
  });

  factory Register.fromJson(Map<String, dynamic> json) {
    return Register(
      idClase: json['idClase'],
      numeroMatricula: json['numeroMatricula'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idClase': idClase,
      'numeroMatricula': numeroMatricula,
      'token': token,
      //'estadoAsistencia':estadoAsistencia
    };
  }
}
