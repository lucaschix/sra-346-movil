import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sra_346_movil/src/errors/appException.dart';
import 'jwtService.dart';

class ApiService {
  ApiService({
    http.Client? client,
    String? baseUrl,
    Future<String> Function()? tokenProvider,
  }) : _client = client ?? http.Client(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'SRA_API_BASE_URL',
             defaultValue: 'http://192.168.1.82:8080',
           ),
       _tokenProvider = tokenProvider ?? JwtService().getToken;

  final http.Client _client;
  final String baseUrl;
  final Future<String> Function() _tokenProvider;

  Future<Map<String, String>> headers() async {
    final token = await _tokenProvider();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String params) async {
    return _returnResponse(
      await _client.get(
        Uri.parse('$baseUrl/$params'),
        headers: await headers(),
      ),
    );
  }

  Future<dynamic> post(
    String params, {
    dynamic data = const <String, dynamic>{},
  }) async {
    return _returnResponse(
      await _client.post(
        Uri.parse('$baseUrl/$params'),
        body: jsonEncode(data),
        headers: await headers(),
      ),
    );
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body);
        } on FormatException {
          return response.body;
        }
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      default:
        throw FetchDataException(
          'Error de comunicación: HTTP ${response.statusCode}',
        );
    }
  }
}
