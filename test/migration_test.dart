import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sra_346_movil/main.dart';
import 'package:sra_346_movil/src/models/asignatura.dart';
import 'package:sra_346_movil/src/screens/AttendanceExpansionPanel.dart';
import 'package:sra_346_movil/src/screens/SubjectPage.dart';
import 'package:sra_346_movil/src/errors/appException.dart';
import 'package:sra_346_movil/src/models/qr.dart';
import 'package:sra_346_movil/src/models/register.dart';
import 'package:sra_346_movil/src/services/apiService.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Contrato HTTP conservado durante la migración', () {
    test('registro mantiene método, ruta, JSON y autorización', () async {
      final api = ApiService(
        baseUrl: 'https://sra.example',
        tokenProvider: () async => 'fixture-session',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/asistencia/registrarCodigoQR/');
          expect(request.headers['authorization'], 'Bearer fixture-session');
          expect(jsonDecode(request.body), {
            'idClase': 4,
            'numeroMatricula': 'fixture-matricula',
            'token': 'fixture-qr',
          });
          return http.Response(
            'Alumno ingresado con exito->Alumno: fixture',
            200,
          );
        }),
      );
      expect(
        await api.post(
          'asistencia/registrarCodigoQR/',
          data: Register(
            idClase: 4,
            numeroMatricula: 'fixture-matricula',
            token: 'fixture-qr',
          ),
        ),
        startsWith('Alumno ingresado con exito'),
      );
    });

    test('sesión vacía no envía un Bearer inválido', () async {
      final api = ApiService(
        tokenProvider: () async => '',
        client: MockClient((request) async {
          expect(request.headers.containsKey('authorization'), isFalse);
          return http.Response('{"mensaje":"fixture"}', 200);
        }),
      );
      expect(await api.get('api/fixture'), {'mensaje': 'fixture'});
    });

    test('401 conserva el rechazo de autenticación', () async {
      final api = ApiService(
        tokenProvider: () async => '',
        client: MockClient((_) async => http.Response('No autorizado', 401)),
      );
      expect(api.get('api/fixture'), throwsA(isA<UnauthorisedException>()));
    });
  });

  group('Lectura QR sin registrar asistencia automáticamente', () {
    final fixture = <String, dynamic>{
      'idClase': 4,
      'asignaturaId': 8,
      'asignatura': 'Curso de prueba',
      'estadoActivo': true,
      'token': 'fixture-qr',
    };

    test('QR válido conserva clase, asignatura y token', () {
      final qr = QR.fromScan(jsonEncode(fixture));
      expect(qr.idClase, 4);
      expect(qr.asignaturaId, 8);
      expect(qr.toJson(), fixture);
    });
    test('JSON inválido se rechaza', () {
      expect(() => QR.fromScan('no-es-json'), throwsFormatException);
    });
    test('JSON de otro tipo se rechaza', () {
      expect(() => QR.fromScan('[]'), throwsFormatException);
    });
    test('clase inactiva se rechaza', () {
      expect(
        () => QR.fromScan(jsonEncode({...fixture, 'estadoActivo': false})),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'mensaje',
            contains('inactivo'),
          ),
        ),
      );
    });
    test(
      'asignatura sin identificador se rechaza antes de consultar matrícula',
      () {
        final invalid = {...fixture}..remove('asignaturaId');
        expect(() => QR.fromScan(jsonEncode(invalid)), throwsFormatException);
      },
    );
    test('token vacío se rechaza', () {
      expect(
        () => QR.fromScan(jsonEncode({...fixture, 'token': ''})),
        throwsFormatException,
      );
    });
  });

  test('preferencias conservan sesión y eliminan datos al salir', () async {
    SharedPreferences.setMockInitialValues({
      'token': 'fixture-session',
      'rut': 123,
      'username': 'fixture-user',
    });
    final jwt = JwtService();
    expect(await jwt.getToken(), 'fixture-session');
    expect(await jwt.getRut(), 123);
    expect(await jwt.getUsername(), 'fixture-user');
    expect(await jwt.removeToken(), '');
    expect(await jwt.getRut(), isNull);
    expect(await jwt.getUsername(), '');
  });

  testWidgets('login y validación caben en el tamaño lógico del iPhone 11', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(828, 1792);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(App(token: ''));
    expect(find.text('BIENVENIDO'), findsOneWidget);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Correo no puede quedar en blanco'), findsOneWidget);
    expect(find.text('Contraseña no puede estar en blanco'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('los cursos se expanden y contraen con la API moderna', (
    tester,
  ) async {
    final curso = Asignatura(asgId: 8, dasNombre: 'Curso de prueba');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttendanceExpansionPanel(generateItems: Future.value([curso])),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ver detalles').hitTestable(), findsNothing);
    await tester.tap(find.byType(ExpandIcon));
    await tester.pumpAndSettle();
    expect(find.text('Ver detalles').hitTestable(), findsOneWidget);
    await tester.tap(find.byType(ExpandIcon));
    await tester.pumpAndSettle();
    expect(find.text('Ver detalles').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final totalCero in [false, true]) {
    testWidgets(
      'detalle y gráfico con porcentajes ${totalCero ? "cero" : "normales"}',
      (tester) async {
        tester.view.physicalSize = const Size(828, 1792);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: SubjectPage(
              asignatura: Asignatura(
                asgId: 8,
                dasNombre: 'Curso de prueba',
                asistencia: totalCero ? 0 : 70,
                inasistencia: totalCero ? 0 : 20,
                atraso: totalCero ? 0 : 10,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Curso de prueba'), findsOneWidget);
        expect(find.text('Asistencias'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
