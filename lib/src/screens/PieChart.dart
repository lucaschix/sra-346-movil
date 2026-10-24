import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/models/asignatura.dart';
import 'package:sra_346_movil/src/util/parseDouble.dart';

import 'Indicator.dart';

class PieChartSample2 extends StatefulWidget {
  final Asignatura asignatura;
  PieChartSample2({required this.asignatura});
  @override
  State<StatefulWidget> createState() => PieChart2State(asignatura: asignatura);
}

class PieChart2State extends State {
  int touchedIndex = -1;
  Asignatura asignatura;
  PieChart2State({required this.asignatura});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(height: 18),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (!mounted) return;
                        setState(() {
                          touchedIndex = event.isInterestedForInteractions
                              ? response?.touchedSection?.touchedSectionIndex ??
                                    -1
                              : -1;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Indicator(
                  color: Colors.green,
                  text: 'Asistencias',
                  isSquare: true,
                ),
                SizedBox(height: 4),
                Indicator(
                  color: Colors.red,
                  text: 'Inasistencias',
                  isSquare: true,
                ),
                SizedBox(height: 4),
                Indicator(
                  color: Colors.yellow,
                  text: 'Retrasos',
                  isSquare: true,
                ),
                SizedBox(height: 18),
              ],
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: parseDouble.parse(this.asignatura.asistencia),
            title: '${parseDouble.parse(asignatura.asistencia)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: parseDouble.parse(this.asignatura.inasistencia),
            title: '${parseDouble.parse(asignatura.inasistencia)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.yellow,
            value: parseDouble.parse(this.asignatura.atraso),
            title: '${parseDouble.parse(asignatura.atraso)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        default:
          throw StateError("Sección de asistencia desconocida");
      }
    });
  }
}
