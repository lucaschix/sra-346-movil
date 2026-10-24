import 'dart:async';
import 'dart:convert';
import '../models/register.dart';
import 'apiService.dart';

class RegisterService {
  var apiService = ApiService();
  Future<List<Register>> getAll() async {
    final response = await apiService.get('profesor/asistencias');
    if (response.statusCode == 200) {
      List<dynamic> aux = jsonDecode(response.body) as List<dynamic>;
      return aux.map((data) => Register.fromJson(data)).toList();
    } else {
      throw Exception(
          'Error en GET Register:' + response.statusCode.toString());
    }
  }

  add(Register register) async {
    final response = await apiService.post('asistencia/registrarCodigoQR/', data:register);
    return response;
  }
}
