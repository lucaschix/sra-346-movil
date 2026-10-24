import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:sra_346_movil/src/models/qr.dart';
import 'package:sra_346_movil/src/screens/AttendancePage.dart';
import 'package:sra_346_movil/src/screens/ConfirmationAttendance.dart';
import 'package:sra_346_movil/src/screens/ErrorNotification.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';

class QrScan extends StatefulWidget {
  final barcode;

  const QrScan({Key key, this.barcode}) : super(key: key);
  _QrScanState createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  String _barcode = "";
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.add_a_photo),
        title: Text('Ingresar a clase'),
        onTap: () async {
          await scan();
          await next();
        });
  }

  Future next() async {
    try {
      var qrJson = jsonDecode(this._barcode);
      if (qrJson["estadoActivo"]) {
        int asignaturaID = qrJson["asignaturaId"];
        String matricula =
            await LoginService().getMatricula(asignaturaID);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmationAttendance(
                    codQr: qrJson,
                    username: matricula,
                  )),
        );
      }
    } on FormatException catch (e) {
      print("Código inválido: " + e.toString());
      ErrorNotification()
          .alert(context, "Código QR no válido", AttendancePage());
    } on TypeError catch (e) {
      print(e);
      ErrorNotification().alert(context, this._barcode, AttendancePage());
    } catch (e) {
      print("Error no identificado: " + e.toString());
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this._barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this._barcode = 'Permiso para acceso a la cámara no concedido';
        });
      } else {
        setState(() => this._barcode = 'Error desconocido $e');
      }
    } on FormatException {
      setState(() => this._barcode =
          'Nulo, el usuario presionó el botón de volver antes de escanear algo)');
    } catch (e) {
      setState(() => this._barcode = 'Error desconocido : $e');
    }
    print(this._barcode);
  }
}
