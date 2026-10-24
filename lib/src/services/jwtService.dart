import 'package:shared_preferences/shared_preferences.dart';

class JwtService {
  Future<String> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token') ?? '';

  Future<int?> getRut() async =>
      (await SharedPreferences.getInstance()).getInt('rut');

  Future<String> getUsername() async =>
      (await SharedPreferences.getInstance()).getString('username') ?? '';

  Future<String> removeToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('rut');
    await preferences.remove('username');
    return getToken();
  }
}
