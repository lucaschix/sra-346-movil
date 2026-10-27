import 'package:sra_346_movil/src/errors/appException.dart';

import 'apiService.dart';
import 'jwtService.dart';

class SignInResult {
  const SignInResult({
    required this.token,
    required this.username,
    required this.roles,
  });

  final String token;
  final String username;
  final List<String> roles;
}

class LoginService {
  LoginService({ApiService? apiService})
    : apiService = apiService ?? ApiService();

  final ApiService apiService;

  Future<SignInResult> signIn(String email, String password) async {
    final response = await apiService.post(
      'api/login',
      queryParameters: {'username': email, 'password': password},
      includeAuthorization: false,
    );
    final body = _map(response);
    final token = body['token'];
    final user = body['user'];
    if (token is! String || token.isEmpty || user is! Map) {
      throw const InvalidResponseException();
    }
    final username = user['username'];
    final authorities = user['authorities'];
    if (username is! String || username.isEmpty || authorities is! List) {
      throw const InvalidResponseException();
    }
    final roles = <String>[];
    for (final authority in authorities) {
      if (authority is! Map || authority['authority'] is! String) {
        throw const InvalidResponseException();
      }
      roles.add(authority['authority'] as String);
    }
    if (roles.isEmpty) throw const InvalidResponseException();
    return SignInResult(token: token, username: username, roles: roles);
  }

  Future<int> fetchRut(String email, {required String token}) async {
    final body = _map(
      await apiService.post(
        'api/rut',
        queryParameters: {'email': email},
        authorizationToken: token,
      ),
    );
    final rut = body['digitos'];
    if (body['mensaje'] != 'Proceso exitoso' || rut is! int) {
      throw const InvalidResponseException();
    }
    return rut;
  }

  Future<void> recoverPassword(String email) async {
    final body = _map(
      await apiService.post(
        'api/enviar_token',
        queryParameters: {'email': email},
        includeAuthorization: false,
      ),
    );
    if (body['mensaje'] !=
            'Correo de recuperacion enviado, revise su bandeja de entrada' ||
        body['email'] != email) {
      throw const InvalidResponseException();
    }
  }

  Future<void> changePassword(String token, String newPassword) async {
    final validation = _map(
      await apiService.post(
        'api/validar_token',
        queryParameters: {'token': token},
        includeAuthorization: false,
      ),
    );
    if (validation['validezToken'] != true) {
      throw const InvalidResponseException();
    }
    await _saveNewPassword(token, newPassword);
  }

  Future<void> changePasswordInterno(
    String actualPassword,
    String newPassword,
  ) async {
    final validation = _map(
      await apiService.post(
        'api/cambio_interno',
        queryParameters: {'claveActual': actualPassword},
      ),
    );
    final token = validation['token'];
    if (token is! String || token.isEmpty) {
      throw const InvalidResponseException();
    }
    await _saveNewPassword(token, newPassword);
  }

  Future<void> _saveNewPassword(String token, String newPassword) async {
    final body = _map(
      await apiService.post(
        'api/recuperar',
        queryParameters: {'token': token, 'nuevaClave': newPassword},
        includeAuthorization: false,
      ),
    );
    if (body['mensaje'] != 'Clave cambiada con exito') {
      throw const InvalidResponseException();
    }
  }

  Future<dynamic> getMatricula(int asignaturaID) async {
    final rut = await JwtService().getRut();
    if (rut == null)
      throw const InvalidInputException('La sesión no contiene RUT');
    final body = _map(
      await apiService.get(
        'asistencia/estudiante/matricula/',
        queryParameters: {'asignatura': asignaturaID, 'estRut': rut},
      ),
    );
    if (body['matricula'] == null) throw const InvalidResponseException();
    return body['matricula'];
  }

  Map<dynamic, dynamic> _map(dynamic response) {
    if (response is! Map) throw const InvalidResponseException();
    return response;
  }
}
