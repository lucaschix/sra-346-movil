class User {
  String usuEmail;
  String usuClave;

  User({this.usuEmail = '', this.usuClave = ''});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(usuEmail: json['usuEmail'], usuClave: json['usuClave']);
  }

  Map<String, dynamic> toJson() {
    return {'usuEmail': usuEmail, 'usuClave': usuClave};
  }
}
