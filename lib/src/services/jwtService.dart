import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JwtService {
  Future<String> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token') ?? '';

  Future<int?> getRut() async =>
      (await SharedPreferences.getInstance()).getInt('rut');

  Future<String> getUsername() async =>
      (await SharedPreferences.getInstance()).getString('username') ?? '';

  Future<void> saveSession({
    required String token,
    required int rut,
    required String username,
  }) async {
    if (!_isUsableToken(token, DateTime.now()) ||
        rut <= 0 ||
        username.trim().isEmpty) {
      await removeToken();
      throw StateError('La respuesta no contiene una sesión completa');
    }

    final preferences = await SharedPreferences.getInstance();
    await removeToken();
    try {
      final usernameSaved = await preferences.setString('username', username);
      final rutSaved = await preferences.setInt('rut', rut);
      final tokenSaved = await preferences.setString('token', token);
      if (!usernameSaved || !rutSaved || !tokenSaved) {
        throw StateError('No se pudo persistir la sesión');
      }
    } catch (_) {
      await removeToken();
      rethrow;
    }
  }

  /// Comprueba integridad local, no autenticidad criptográfica del JWT.
  ///
  /// Los JWT de tres segmentos deben contener un payload JSON decodificable y,
  /// si declaran `exp`, no pueden estar vencidos. Los tokens opacos sin puntos
  /// se aceptan por compatibilidad; su validez definitiva corresponde al API.
  Future<bool> hasUsableSession({DateTime? now}) async {
    final token = await getToken();
    final rut = await getRut();
    final username = await getUsername();
    final usable =
        rut != null &&
        rut > 0 &&
        username.trim().isNotEmpty &&
        _isUsableToken(token, now ?? DateTime.now());
    if (!usable && (token.isNotEmpty || rut != null || username.isNotEmpty)) {
      await removeToken();
    }
    return usable;
  }

  bool _isUsableToken(String token, DateTime now) {
    if (token.isEmpty || token.trim() != token) return false;
    final parts = token.split('.');
    if (parts.length == 1) return true;
    if (parts.length != 3 || parts.any((part) => part.isEmpty)) return false;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return false;
      final expiration = payload['exp'];
      if (expiration == null) return true;
      if (expiration is! num) return false;
      return expiration.toDouble() > now.millisecondsSinceEpoch / 1000;
    } catch (_) {
      return false;
    }
  }

  Future<String> removeToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('rut');
    await preferences.remove('username');
    return getToken();
  }
}
