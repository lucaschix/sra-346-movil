import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/models/asignatura.dart';
import 'package:sra_346_movil/src/screens/QRLectorComponent.dart';
import 'package:sra_346_movil/src/screens/TheHeader.dart';
import 'package:sra_346_movil/src/services/asignaturaService.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';

import 'AttendanceExpansionPanel.dart';
import 'DrawerWidget.dart';

class AttendancePage extends StatelessWidget {
  final qrScan = QrScan();
  final String title = "Mis Cursos";

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

    Future<List<Asignatura>> _getData() async {
      int rut=await JwtService().getRut();
      print(rut);
      return AsignaturaService().getAll(rut);
    }

    return Scaffold(
      key: _key,
      appBar: TheHeader(this.title),
     // floatingActionButton: qrScan,
      endDrawer: DrawerPage(),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 20),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: AttendanceExpansionPanel(
                    generateItems: _getData(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
