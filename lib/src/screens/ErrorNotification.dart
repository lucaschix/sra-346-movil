import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sra_346_movil/src/errors/appException.dart';

class ErrorNotification {
  void throwErrors(Object error, BuildContext context, [Widget? _]) {
    alert(context, _messageFor(error));
  }

  String _messageFor(Object error) {
    if (error is NetworkException) {
      return 'No fue posible conectar con el servicio';
    }
    if (error is RequestTimeoutException) {
      return 'El servicio demoró demasiado. El resultado no está confirmado';
    }
    if (error is UnauthorisedException) return 'Credenciales inválidas';
    if (error is ForbiddenException) {
      return 'El acceso fue rechazado. Verifique su sesión o permisos';
    }
    if (error is BadRequestException) return 'La solicitud fue rechazada';
    if (error is ServerException) {
      return 'El servicio no pudo completar la solicitud';
    }
    if (error is InvalidResponseException) {
      return 'El servicio entregó una respuesta no reconocida';
    }
    return 'No fue posible completar la operación';
  }

  void alert(BuildContext context, Object error, [Widget? _]) {
    final description = error is AppException
        ? _messageFor(error)
        : error is String
        ? error
        : 'No fue posible completar la operación';
    Alert(
      context: context,
      type: AlertType.error,
      title: 'ERROR',
      desc: description,
      buttons: [
        DialogButton(
          width: 120,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Ok',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }
}
