import 'dart:async';
import '../models/register.dart';
import 'apiService.dart';

class RegisterService {
  var apiService = ApiService();
  Future<List<Register>> getAll() async {
    final response = await apiService.get('profesor/asistencias');
    final items = response as List<dynamic>;
    return items.map((data) => Register.fromJson(data)).toList();
  }

  add(Register register) async {
    final response = await apiService.post(
      'asistencia/registrarCodigoQR/',
      data: register,
    );
    return response;
  }
}
