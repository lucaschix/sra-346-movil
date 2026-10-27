class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'AppException($code${statusCode == null ? '' : ', HTTP $statusCode'}): $message';
}

class FetchDataException extends AppException {
  const FetchDataException([
    String message = 'No fue posible comunicarse con el servicio',
  ]) : super(code: 'communication_error', message: message);
}

class NetworkException extends AppException {
  const NetworkException()
    : super(
        code: 'network_error',
        message: 'No fue posible conectarse al servicio',
      );
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
    : super(
        code: 'request_timeout',
        message: 'El servicio demoró demasiado en responder',
      );
}

class BadRequestException extends AppException {
  const BadRequestException()
    : super(
        code: 'bad_request',
        message: 'La solicitud fue rechazada',
        statusCode: 400,
      );
}

class UnauthorisedException extends AppException {
  const UnauthorisedException()
    : super(
        code: 'unauthorised',
        message: 'La autenticación fue rechazada',
        statusCode: 401,
      );
}

class ForbiddenException extends AppException {
  const ForbiddenException()
    : super(
        code: 'forbidden',
        message: 'El servicio rechazó el acceso',
        statusCode: 403,
      );
}

class ServerException extends AppException {
  const ServerException(int statusCode)
    : super(
        code: 'server_error',
        message: 'El servicio no pudo completar la solicitud',
        statusCode: statusCode,
      );
}

class HttpStatusException extends AppException {
  const HttpStatusException(int statusCode)
    : super(
        code: 'unexpected_http_status',
        message: 'El servicio devolvió un estado no esperado',
        statusCode: statusCode,
      );
}

class InvalidResponseException extends AppException {
  const InvalidResponseException()
    : super(
        code: 'invalid_response',
        message: 'La respuesta del servicio no tiene el formato esperado',
      );
}

class UnsupportedRoleException extends AppException {
  const UnsupportedRoleException()
    : super(
        code: 'unsupported_mobile_role',
        message: 'El rol autenticado no tiene un flujo móvil definido',
      );
}

class InvalidInputException extends AppException {
  const InvalidInputException([
    String message = 'Los datos ingresados no son válidos',
  ]) : super(code: 'invalid_input', message: message);
}
