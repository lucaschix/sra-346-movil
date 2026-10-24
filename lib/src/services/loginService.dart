import 'package:shared_preferences/shared_preferences.dart';

import 'apiService.dart';

class LoginService {
  var apiService = ApiService();

  signIn(String email, pass) async {
    // User eo = new User(usuEmail: email, usuClave: pass);
    var jsonResponse = await apiService.post(
      "api/login?username=$email&password=$pass",
    );
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("token", jsonResponse["token"]);
      sharedPreferences.setString("username", jsonResponse["user"]["username"]);
      print("Token y nombre usuario guardados");
    } catch (e) {
      print("Error en sharedPreferences: " + e.toString());
    }

    return jsonResponse;
  }

  recoverPassword(email) async {
    return await apiService.post('api/enviar_token?email=$email');
  }

  changePassword(token, newPassword) async {
    try {
      var response = await apiService.post('api/validar_token?token=$token');
      if (response["validezToken"]) {
        return await apiService.post(
          'api/recuperar?token=$token&nuevaClave=$newPassword',
        );
      }
    } catch (e) {
      print(e.toString());
      throw new Exception("Error sl cambiar contraseña");
    }
  }

  //TODO Por verificar funcionamiento, cambio interno error 500 si clave actual es rechazada
  changePasswordInterno(String actualPassword, newPassword) async {
    try {
      var response = await apiService.post(
        'api/cambio_interno?claveActual=$actualPassword',
      );
      if (response["token"] != null) {
        String token = response["token"];
        return await apiService.post(
          'api/recuperar?token=$token&nuevaClave=$newPassword',
        );
      }
    } catch (e) {
      print(e.toString());
      throw new Exception("Error al cambiar contraseña");
    }
  }

  fetchRut(String email) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      var rut = await apiService.post('api/rut/?email=$email');
      if (rut["mensaje"] == "Proceso exitoso") {
        int rutDigitos = rut["digitos"];
        sharedPreferences.setInt("rut", rutDigitos);
      }
    } catch (e) {
      print(e.toString());
      throw new Exception("Error en fetchRut");
    }
  }

  getMatricula(int asignaturaID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      final rutDigitos = sharedPreferences.getInt("rut");
      if (rutDigitos == null) throw StateError('La sesión no contiene RUT');
      var responseMat = await apiService.get(
        'asistencia/estudiante/matricula/?asignatura=$asignaturaID&estRut=$rutDigitos',
      );
      return responseMat["matricula"];
    } catch (e) {
      print(e.toString());
      throw new Exception("Error en GetMatricula");
    }
  }
}
