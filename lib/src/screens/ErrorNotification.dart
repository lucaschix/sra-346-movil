import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sra_346_movil/src/errors/appException.dart';

class ErrorNotification {
  throwErrors(e, context, to) {
    if (e.toString().contains('Network is unreachable')) {
      alert(context, "No internet", to);
    } else if (e.toString().contains('Connection refused')) {
      alert(context, "Servidor no responde", to);
    } else if (e is UnauthorisedException) {
      alert(context, "Credenciales invalidas", to);
    } else {
      alert(context, "Error no identificado", to);
      throw new Exception(e.toString());
    }
  }

  alert(context, error, to) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "ERROR",
      desc: error,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => to),
          ),
          width: 120,
        ),
      ],
    ).show();
  }
}
