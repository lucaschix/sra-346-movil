import 'package:sra_346_movil/src/models/asignatura.dart';

import 'apiService.dart';

class AsignaturaService {
  var apiService = ApiService();

  Future<List<Asignatura>> getAll(rut) async {
    final response = await apiService.get(
      'asistencia/estudiante/asignaturas/?estRut=$rut',
    );
    List<dynamic> aux = response as List<dynamic>;
    return aux.map((data) => Asignatura.fromJson(data)).toList();
  }
}
