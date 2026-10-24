import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/models/asignatura.dart';
import 'package:sra_346_movil/src/screens/TheHeader.dart';
import 'package:sra_346_movil/src/screens/PieChart.dart';
import 'package:sra_346_movil/src/util/parseDouble.dart';
class SubjectPage extends StatelessWidget {
  SubjectPage({this.asignatura});
  final Asignatura asignatura;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _key,
      appBar: TheHeader(this.asignatura.dasNombre),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            _row("Asistencia", parseDouble.parse(this.asignatura.asistencia).toString()),
            SizedBox(height: 30),
            _row("Inasistencia", parseDouble.parse(this.asignatura.inasistencia).toString()),
            SizedBox(height: 30),
            _row("Atrasos", parseDouble.parse(this.asignatura.atraso).toString()),
            SizedBox(height: 30),
            PieChartSample2(asignatura:this.asignatura)
          ],
        ),
        ),
      ),
    );
  }

  _row(col1, col2) => Container(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(col1, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(col2+"%")
          ],
        ),
      );


}
