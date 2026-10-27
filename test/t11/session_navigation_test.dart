import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sra_346_movil/main.dart';
import 'package:sra_346_movil/src/screens/DrawerWidget.dart';
import 'package:sra_346_movil/src/screens/LoginPage.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';

String _jwtWithExpiration(int expiration) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'none'})));
  final payload = base64Url.encode(
    utf8.encode(jsonEncode({'exp': expiration})),
  );
  return '$header.$payload.synthetic-signature';
}

class _FakeLoginService extends LoginService {
  _FakeLoginService({
    required this.authentication,
    this.rutError,
    this.signInGate,
    this.recoverPasswordGate,
    this.passwordChangeGate,
    this.passwordChangeError,
  });

  final SignInResult authentication;
  final int rut = 12345678;
  final Object? rutError;
  final Completer<void>? signInGate;
  final Completer<void>? recoverPasswordGate;
  final Completer<void>? passwordChangeGate;
  final Object? passwordChangeError;
  int signInCalls = 0;
  int recoverPasswordCalls = 0;
  int passwordChangeCalls = 0;
  String? submittedPassword;

  @override
  Future<SignInResult> signIn(String email, String password) async {
    signInCalls++;
    submittedPassword = password;
    await signInGate?.future;
    return authentication;
  }

  @override
  Future<int> fetchRut(String email, {required String token}) async {
    if (rutError != null) throw rutError!;
    return rut;
  }

  @override
  Future<void> recoverPassword(String email) async {
    recoverPasswordCalls++;
    await recoverPasswordGate?.future;
  }

  @override
  Future<void> changePassword(String token, String newPassword) async {
    passwordChangeCalls++;
    await passwordChangeGate?.future;
    if (passwordChangeError != null) throw passwordChangeError!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('C03: sesión local completa', () {
    test('rechaza y limpia una sesión parcial', () async {
      SharedPreferences.setMockInitialValues({'token': 'opaque-token'});
      final jwt = JwtService();

      expect(await jwt.hasUsableSession(), isFalse);
      expect(await jwt.getToken(), isEmpty);
    });

    test('rechaza y limpia JWT vencido o corrupto', () async {
      final jwt = JwtService();
      final now = DateTime.fromMillisecondsSinceEpoch(2000 * 1000);
      for (final token in [_jwtWithExpiration(1999), 'a.not-base64.c']) {
        SharedPreferences.setMockInitialValues({
          'token': token,
          'rut': 12345678,
          'username': 'fixture-user',
        });
        expect(await jwt.hasUsableSession(now: now), isFalse);
        expect(await jwt.getToken(), isEmpty);
      }
    });

    test('acepta token opaco solo con RUT y usuario completos', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'opaque-server-token',
        'rut': 12345678,
        'username': 'fixture-user',
      });
      expect(await JwtService().hasUsableSession(), isTrue);
    });

    testWidgets('arranque parcial muestra autenticación', (tester) async {
      SharedPreferences.setMockInitialValues({'token': 'partial-token'});
      await tester.pumpWidget(
        App(
          signedInPage: const Text('PROTECTED'),
          signedOutPage: const Text('AUTH'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AUTH'), findsOneWidget);
      expect(find.text('PROTECTED'), findsNothing);
    });
  });

  group('login atómico', () {
    testWidgets('persiste al final y conserva la contraseña exacta', (
      tester,
    ) async {
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'opaque-token',
          username: 'fixture-user',
          roles: <String>['ROLE_ESTUD'],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            loginService: service,
            signedInPage: const Scaffold(body: Text('PROTECTED')),
          ),
        ),
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@example.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), ' secret ');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(service.submittedPassword, ' secret ');
      expect(find.text('PROTECTED'), findsOneWidget);
      expect(await JwtService().getToken(), 'opaque-token');
      expect(await JwtService().getRut(), 12345678);
      expect(await JwtService().getUsername(), 'fixture-user');
    });

    testWidgets('falla RUT, revierte y no navega', (tester) async {
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'opaque-token',
          username: 'fixture-user',
          roles: <String>['ROLE_ESTUD'],
        ),
        rutError: StateError('fixture failure'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            loginService: service,
            signedInPage: const Scaffold(body: Text('PROTECTED')),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'student@test');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(await JwtService().getToken(), isEmpty);
      expect(await JwtService().getRut(), isNull);
      expect(await JwtService().getUsername(), isEmpty);
    });

    testWidgets('un rol sin flujo móvil no abre rutas de estudiante', (
      tester,
    ) async {
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'opaque-token',
          username: 'fixture-teacher',
          roles: <String>['ROLE_PROFE'],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            loginService: service,
            signedInPage: const Scaffold(body: Text('PROTECTED')),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'teacher@test');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('PROTECTED'), findsNothing);
      expect(
        find.text('Esta cuenta no tiene un flujo habilitado en la app móvil.'),
        findsOneWidget,
      );
      expect(await JwtService().getToken(), isEmpty);
      expect(await JwtService().getRut(), isNull);
    });

    testWidgets('bloquea el segundo envío mientras espera', (tester) async {
      final gate = Completer<void>();
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'opaque-token',
          username: 'fixture-user',
          roles: <String>['ROLE_ESTUD'],
        ),
        signInGate: gate,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            loginService: service,
            signedInPage: const Scaffold(body: Text('PROTECTED')),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'student@test');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      final button = tester.widget<MaterialButton>(find.byType(MaterialButton));
      expect(button.onPressed, isNull);
      expect(service.signInCalls, 1);
      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('respuesta tardía tras dispose no restaura sesión', (
      tester,
    ) async {
      final gate = Completer<void>();
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'opaque-token',
          username: 'fixture-user',
          roles: <String>['ROLE_ESTUD'],
        ),
        signInGate: gate,
      );
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(loginService: service)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'student@test');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      gate.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(await JwtService().getToken(), isEmpty);
      expect(await JwtService().getRut(), isNull);
      expect(await JwtService().getUsername(), isEmpty);
    });
  });

  testWidgets(
    'C17: cambio recuperado bloquea doble envío y no confirma un error',
    (tester) async {
      final gate = Completer<void>();
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'unused',
          username: 'unused',
          roles: <String>['ROLE_ESTUD'],
        ),
        passwordChangeGate: gate,
        passwordChangeError: StateError('synthetic failure'),
      );
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(loginService: service)),
      );

      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'student@test');
      await tester.tap(find.text('Cambiar contraseña'));
      await tester.pumpAndSettle();
      expect(service.recoverPasswordCalls, 1);

      final modalFields = find.byType(TextFormField);
      expect(modalFields, findsNWidgets(3));
      final tokenField = modalFields.at(1);
      final passwordField = modalFields.at(2);
      await tester.enterText(tokenField, 'synthetic-token');
      await tester.enterText(passwordField, ' new password ');
      await tester.tap(find.byType(DialogButton));
      await tester.pump();
      await tester.tap(find.byType(DialogButton));
      await tester.pump();
      expect(service.passwordChangeCalls, 1);

      gate.complete();
      await tester.pumpAndSettle();
      expect(
        find.text('No se pudo confirmar el cambio de contraseña.'),
        findsOneWidget,
      );
      expect(find.byType(DialogButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'C17: respuesta tardía no cierra Login si el modal se cerró con X',
    (tester) async {
      final gate = Completer<void>();
      final service = _FakeLoginService(
        authentication: const SignInResult(
          token: 'unused',
          username: 'unused',
          roles: <String>['ROLE_ESTUD'],
        ),
        passwordChangeGate: gate,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LoginPage(loginService: service),
                  ),
                ),
                child: const Text('OPEN LOGIN'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('OPEN LOGIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'student@test');
      await tester.tap(find.text('Cambiar contraseña'));
      await tester.pumpAndSettle();

      final modalFields = find.byType(TextFormField);
      await tester.enterText(modalFields.at(1), 'synthetic-token');
      await tester.enterText(modalFields.at(2), 'new password');
      await tester.tap(find.byType(DialogButton));
      await tester.pump();
      expect(service.passwordChangeCalls, 1);

      final closeIcon = find.byWidgetPredicate((widget) {
        if (widget is! Container || widget.decoration is! BoxDecoration) {
          return false;
        }
        final image = (widget.decoration as BoxDecoration).image?.image;
        return image is AssetImage && image.assetName.endsWith('close.png');
      });
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('OPEN LOGIN'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('C17: no permite cancelar recuperación mientras está pendiente', (
    tester,
  ) async {
    final gate = Completer<void>();
    final service = _FakeLoginService(
      authentication: const SignInResult(
        token: 'unused',
        username: 'unused',
        roles: <String>['ROLE_ESTUD'],
      ),
      recoverPasswordGate: gate,
    );
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(loginService: service)),
    );
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'student@test');
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pump();

    final cancel = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Cancelar'),
    );
    expect(cancel.onPressed, isNull);
    expect(service.recoverPasswordCalls, 1);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(DialogButton), findsOneWidget);
  });

  testWidgets('C05: logout limpia preferencias y toda la pila', (tester) async {
    SharedPreferences.setMockInitialValues({
      'token': 'opaque-token',
      'rut': 12345678,
      'username': 'fixture-user',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => Scaffold(body: DrawerPage())),
            ),
            child: const Text('OPEN PROTECTED'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OPEN PROTECTED'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    final context = tester.element(find.byType(LoginPage));
    expect(Navigator.of(context).canPop(), isFalse);
    expect(await JwtService().getToken(), isEmpty);
    expect(await JwtService().getRut(), isNull);
    expect(await JwtService().getUsername(), isEmpty);
  });
}
