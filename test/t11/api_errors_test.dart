import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sra_346_movil/src/errors/appException.dart';
import 'package:sra_346_movil/src/services/apiService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';

void main() {
  group('errores HTTP sanitizados', () {
    test(
      '401 y 403 conservan categorías distintas sin incluir el cuerpo',
      () async {
        const sensitiveMarker = 'body-sensitive-marker';

        final unauthorized = ApiService(
          client: MockClient((_) async => http.Response(sensitiveMarker, 401)),
          tokenProvider: () async => '',
        );
        final forbidden = ApiService(
          client: MockClient((_) async => http.Response(sensitiveMarker, 403)),
          tokenProvider: () async => 'synthetic-token',
        );

        final error401 = await _captureError(unauthorized.get('api/fixture'));
        final error403 = await _captureError(forbidden.get('api/fixture'));

        expect(error401, isA<UnauthorisedException>());
        expect(error403, isA<ForbiddenException>());
        expect(error401.toString(), isNot(contains(sensitiveMarker)));
        expect(error403.toString(), isNot(contains(sensitiveMarker)));
      },
    );

    test('timeout se clasifica sin filtrar la URI', () async {
      const sensitiveMarker = 'query-sensitive-marker';
      final api = ApiService(
        requestTimeout: const Duration(milliseconds: 1),
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response('{}', 200);
        }),
        tokenProvider: () async => '',
      );

      final error = await _captureError(
        api.get('api/fixture', queryParameters: {'secret': sensitiveMarker}),
      );

      expect(error, isA<RequestTimeoutException>());
      expect(error.toString(), isNot(contains(sensitiveMarker)));
    });

    test('error de cliente descarta mensaje y URI sensibles', () async {
      const sensitiveMarker = 'network-sensitive-marker';
      final api = ApiService(
        client: MockClient((request) async {
          throw http.ClientException(sensitiveMarker, request.url);
        }),
        tokenProvider: () async => '',
      );

      final error = await _captureError(
        api.get('api/fixture', queryParameters: {'secret': sensitiveMarker}),
      );

      expect(error, isA<NetworkException>());
      expect(error.toString(), isNot(contains(sensitiveMarker)));
    });

    test('SocketException se clasifica como error de red', () async {
      final api = ApiService(
        client: MockClient((_) async {
          throw const SocketException('synthetic socket failure');
        }),
        tokenProvider: () async => '',
      );

      expect(
        await _captureError(api.get('api/fixture')),
        isA<NetworkException>(),
      );
    });

    test('5xx conserva status pero no cuerpo', () async {
      const sensitiveMarker = 'server-sensitive-marker';
      final api = ApiService(
        client: MockClient((_) async => http.Response(sensitiveMarker, 503)),
        tokenProvider: () async => '',
      );

      final error = await _captureError(api.get('api/fixture'));

      expect(
        error,
        isA<ServerException>().having(
          (value) => value.statusCode,
          'statusCode',
          503,
        ),
      );
      expect(error.toString(), isNot(contains(sensitiveMarker)));
    });
  });

  group('contratos de sesión', () {
    test('login conserva caracteres exactos, no usa JSON ni Bearer', () async {
      const email = ' alumno+qa&ios@example.test ';
      const password = ' p+a&s#?% ü ';
      final service = LoginService(
        apiService: ApiService(
          baseUrl: 'https://sra.example',
          tokenProvider: () async => 'stale-token',
          client: MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.url.path, '/api/login');
            expect(request.url.queryParameters['username'], email);
            expect(request.url.queryParameters['password'], password);
            expect(request.body, isEmpty);
            expect(request.headers.containsKey('authorization'), isFalse);
            return http.Response(
              jsonEncode({
                'token': 'synthetic-session',
                'user': {
                  'username': email,
                  'authorities': [
                    {'authority': 'ROLE_ESTUD'},
                  ],
                },
                'mensaje': 'Has iniciado sesión con éxito',
              }),
              200,
            );
          }),
        ),
      );

      final result = await service.signIn(email, password);

      expect(result.token, 'synthetic-session');
      expect(result.username, email);
      expect(result.roles, ['ROLE_ESTUD']);
    });

    test('RUT usa el token recién autenticado y no persiste', () async {
      const email = 'student+ios@example.test';
      const token = 'synthetic-new-session';
      final service = LoginService(
        apiService: ApiService(
          baseUrl: 'https://sra.example',
          tokenProvider: () async => 'stale-token',
          client: MockClient((request) async {
            expect(request.url.path, '/api/rut');
            expect(request.url.queryParameters, {'email': email});
            expect(request.headers['authorization'], 'Bearer $token');
            return http.Response(
              '{"digitos":12345678,"dv":"9","mensaje":"Proceso exitoso"}',
              200,
            );
          }),
        ),
      );

      expect(await service.fetchRut(email, token: token), 12345678);
    });

    test('200 desconocido no se acepta como login ni recuperación', () async {
      final service = LoginService(
        apiService: ApiService(
          client: MockClient((_) async => http.Response('{}', 200)),
          tokenProvider: () async => '',
        ),
      );

      expect(
        service.signIn('synthetic@example.test', 'synthetic-password'),
        throwsA(isA<InvalidResponseException>()),
      );
      expect(
        service.recoverPassword('synthetic@example.test'),
        throwsA(isA<InvalidResponseException>()),
      );
    });

    test('cuerpo 200 vacío no confirma el login', () async {
      final service = LoginService(
        apiService: ApiService(
          client: MockClient((_) async => http.Response('', 200)),
          tokenProvider: () async => '',
        ),
      );

      expect(
        service.signIn('synthetic@example.test', 'synthetic-password'),
        throwsA(isA<InvalidResponseException>()),
      );
    });

    test(
      'cambio de clave conserva valores y confirma ambos contratos',
      () async {
        const recoveryToken = ' token+&?#% ';
        const password = ' new+&?#% password ';
        var requestNumber = 0;
        final service = LoginService(
          apiService: ApiService(
            baseUrl: 'https://sra.example',
            tokenProvider: () async => 'stale-token',
            client: MockClient((request) async {
              requestNumber++;
              expect(request.headers.containsKey('authorization'), isFalse);
              if (requestNumber == 1) {
                expect(request.url.path, '/api/validar_token');
                expect(request.url.queryParameters['token'], recoveryToken);
                return http.Response('{"validezToken":true}', 200);
              }
              expect(request.url.path, '/api/recuperar');
              expect(request.url.queryParameters['token'], recoveryToken);
              expect(request.url.queryParameters['nuevaClave'], password);
              return http.Response(
                '{"mensaje":"Clave cambiada con exito"}',
                200,
              );
            }),
          ),
        );

        await service.changePassword(recoveryToken, password);
        expect(requestNumber, 2);
      },
    );

    test('los fallos no imprimen marcadores sensibles', () async {
      const sensitiveMarker = 'do-not-log-synthetic-marker';
      final printed = <String>[];
      final service = LoginService(
        apiService: ApiService(
          client: MockClient((_) async => http.Response(sensitiveMarker, 401)),
          tokenProvider: () async => '',
        ),
      );

      await runZoned(
        () async {
          await _captureError(
            service.signIn('$sensitiveMarker@example.test', sensitiveMarker),
          );
        },
        zoneSpecification: ZoneSpecification(
          print: (_, __, ___, value) => printed.add(value),
        ),
      );

      expect(printed.join('\n'), isNot(contains(sensitiveMarker)));
    });
  });
}

Future<Object> _captureError(Future<dynamic> operation) async {
  try {
    await operation;
  } catch (error) {
    return error;
  }
  throw StateError('La operación sintética debía fallar');
}
