import 'package:shared_preferences/shared_preferences.dart';

class JwtService {
  getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.get("token") ?? "";
    return token;
  }
  getRut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int rut = sharedPreferences.get("rut") ?? "";
    return rut;
  }
  getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.get("username") ?? "";
    return token;
  }

  removeToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("token");
    return getToken();
  }
}
