import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sra_346_movil/src/errors/appException.dart';

import 'jwtService.dart';

class ApiService {
  String baseUrl = "http://192.168.1.82:8080";

  headers() async {
    final token = await JwtService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    };
  }

  get(params) async {
    final _headers = await headers();
    final response =
        await http.get('${this.baseUrl}/$params', headers: _headers);
    return _returnResponse(response);
  }

  post(params, {data = "{}"}) async {
    final _headers = await headers();
    final response = await http.post('${this.baseUrl}/$params',
        body: jsonEncode(data), headers: _headers);
    return _returnResponse(response);
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson;
        try {
          responseJson = json.decode(response.body.toString());
        } catch (e) {
          responseJson = response.body.toString();
        }
        print("Response API Service");
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
