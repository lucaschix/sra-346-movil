import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/models/asignatura.dart';
import 'package:sra_346_movil/src/screens/SubjectPage.dart';

class AttendanceExpansionPanel extends StatefulWidget {
  AttendanceExpansionPanel({Key? key, required this.generateItems})
    : super(key: key);
  final Future<List<Asignatura>> generateItems;

  @override
  _AttendanceExpansionPanelState createState() =>
      _AttendanceExpansionPanelState(data: generateItems);
}

class _AttendanceExpansionPanelState extends State<AttendanceExpansionPanel> {
  Future<List<Asignatura>> data;
  _AttendanceExpansionPanelState({required this.data});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: FutureBuilder<List<Asignatura>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Asignatura> items = snapshot.data!.toList();

            return ListView(children: [_buildPanel(items)]);
          } else if (snapshot.hasError) {
            return Text('Error al cargar API. Error: ${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildPanel(List<Asignatura> studentAttendaces) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          studentAttendaces[index].isExpanded = isExpanded;
        });
      },
      children: studentAttendaces.map<ExpansionPanel>((
        Asignatura studentAttendace,
      ) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(title: Text(studentAttendace.dasNombre));
          },
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubjectPage(asignatura: studentAttendace),
                        ),
                      );
                    },
                    textColor: Colors.white,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "Ver detalles",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isExpanded: studentAttendace.isExpanded,
        );
      }).toList(),
    );
  }
}
