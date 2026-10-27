import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sra_346_movil/src/errors/appException.dart';

import 'jwtService.dart';

class ApiService {
  ApiService({
    http.Client? client,
    String? baseUrl,
    Future<String> Function()? tokenProvider,
    this.requestTimeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'SRA_API_BASE_URL',
             defaultValue: 'http://192.168.1.15:8080',
           ),
       _tokenProvider = tokenProvider ?? JwtService().getToken;

  final http.Client _client;
  final String baseUrl;
  final Future<String> Function() _tokenProvider;
  final Duration requestTimeout;

  Future<Map<String, String>> headers({
    bool includeAuthorization = true,
    String? authorizationToken,
    bool hasJsonBody = false,
  }) async {
    final result = <String, String>{'Accept': 'application/json'};
    if (hasJsonBody) result['Content-Type'] = 'application/json';
    if (includeAuthorization) {
      final token = authorizationToken ?? await _tokenProvider();
      if (token.isNotEmpty) result['Authorization'] = 'Bearer $token';
    }
    return result;
  }

  Future<dynamic> get(
    String path, {
    Map<String, Object?>? queryParameters,
    bool includeAuthorization = true,
    String? authorizationToken,
  }) async {
    return _perform(
      () async => _client.get(
        _buildUri(path, queryParameters),
        headers: await headers(
          includeAuthorization: includeAuthorization,
          authorizationToken: authorizationToken,
        ),
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, Object?>? queryParameters,
    bool includeAuthorization = true,
    String? authorizationToken,
  }) async {
    return _perform(
      () async => _client.post(
        _buildUri(path, queryParameters),
        body: data == null ? null : jsonEncode(data),
        headers: await headers(
          includeAuthorization: includeAuthorization,
          authorizationToken: authorizationToken,
          hasJsonBody: data != null,
        ),
      ),
    );
  }

  Uri _buildUri(String path, Map<String, Object?>? queryParameters) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse(normalizedBase).resolve(normalizedPath);
    if (queryParameters == null || queryParameters.isEmpty) return uri;

    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        for (final entry in queryParameters.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      },
    );
  }

  Future<dynamic> _perform(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(requestTimeout);
      return _returnResponse(response);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const FetchDataException();
    }
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        if (response.body.isEmpty) return '';
        try {
          return jsonDecode(response.body);
        } on FormatException {
          return response.body;
        }
      case 400:
        throw const BadRequestException();
      case 401:
        throw const UnauthorisedException();
      case 403:
        throw const ForbiddenException();
      default:
        if (response.statusCode >= 500) {
          throw ServerException(response.statusCode);
        }
        throw HttpStatusException(response.statusCode);
    }
  }
}
