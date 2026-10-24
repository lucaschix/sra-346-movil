import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/models/register.dart';
import 'package:sra_346_movil/src/screens/AttendancePage.dart';
import 'package:sra_346_movil/src/screens/ErrorNotification.dart';
import 'package:sra_346_movil/src/screens/TheHeader.dart';
import 'package:sra_346_movil/src/services/registerService.dart';

class ConfirmationAttendance extends StatelessWidget {
  final String title = "Confirme Asistencia";
  final codQr;
  final username;
  ConfirmationAttendance({this.codQr, this.username});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
    var date = new DateTime.now().toIso8601String();
    var asignatura = this.codQr["asignatura"];
    var idClase = this.codQr["idClase"];
    var token = this.codQr["token"];
    var estado = "ATRASADO";
    var registro = Register(
      numeroMatricula: this.username,
      token: token,
      idClase: idClase,
      estadoAsistencia: estado,
    );
    return Scaffold(
      key: _key,
      appBar: TheHeader(this.title),
      body: Column(
        children: <Widget>[
          SizedBox(height: 30),
          _row("Asignatura", asignatura),
          SizedBox(height: 30),
          _row("Tu Matricula", this.username),
          SizedBox(height: 30),
          _row("Fecha", date),
          SizedBox(height: 30),
          _rowBtn(context, registro),
        ],
      ),
    );
  }

  _row(col1, col2) => Container(
    padding: EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(col1, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(col2),
      ],
    ),
  );

  _rowBtn(context, registro) => Container(
    padding: EdgeInsets.all(40.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new MaterialButton(
          padding: const EdgeInsets.all(8.0),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () async {
            var response = await RegisterService().add(registro);
            if (!response.toString().contains("Error")) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendancePage()),
              );
            } else {
              ErrorNotification().alert(context, response, AttendancePage());
            }
          },
          child: new Text("Confirmar"),
        ),
        new MaterialButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendancePage()),
          ),
          textColor: Colors.white,
          color: Colors.red,
          padding: const EdgeInsets.all(8.0),
          child: new Text("Cancelar"),
        ),
      ],
    ),
  );
}
