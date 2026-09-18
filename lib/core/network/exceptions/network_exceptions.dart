import 'package:dio/dio.dart';

/// Network / API related failures.
sealed class NetworkException implements Exception {
  const NetworkException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NoInternetException extends NetworkException {
  const NoInternetException([
    super.message = 'No internet connection. Please try again.',
  ]);
}

class TimeoutException extends NetworkException {
  const TimeoutException([
    super.message = 'Request timed out. Please try again.',
  ]);
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException([
    super.message = 'Session expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

class ForbiddenException extends NetworkException {
  const ForbiddenException([
    super.message = 'You do not have permission to perform this action.',
  ]) : super(statusCode: 403);
}

class NotFoundException extends NetworkException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]) : super(statusCode: 404);
}

class ServerException extends NetworkException {
  const ServerException([
    super.message =
        'Something went wrong on our end. Please try again later.',
  ]) : super(statusCode: 500);
}

class BadRequestException extends NetworkException {
  const BadRequestException([
    super.message = 'Invalid request.',
  ]) : super(statusCode: 400);
}

class UnknownNetworkException extends NetworkException {
  const UnknownNetworkException([
    super.message = 'An unexpected error occurred.',
  ]);
}

/// Maps a [DioException] to a typed [NetworkException].
NetworkException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NoInternetException();
    case DioExceptionType.badResponse:
      return _fromStatusCode(
        error.response?.statusCode,
        _messageFromResponse(error.response),
      );
    case DioExceptionType.cancel:
      return const UnknownNetworkException('Request was cancelled.');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return UnknownNetworkException(
        error.message ?? 'An unexpected error occurred.',
      );
  }
}

NetworkException _fromStatusCode(int? statusCode, String? message) {
  switch (statusCode) {
    case 400:
      return BadRequestException(message ?? 'Invalid request.');
    case 401:
      return UnauthorizedException(
        message ?? 'Session expired. Please sign in again.',
      );
    case 403:
      return ForbiddenException(
        message ?? 'You do not have permission to perform this action.',
      );
    case 404:
      return NotFoundException(
        message ?? 'The requested resource was not found.',
      );
    case 500:
    case 502:
    case 503:
      return ServerException(
        message ??
            'Something went wrong on our end. Please try again later.',
      );
    default:
      return UnknownNetworkException(
        message ?? 'An unexpected error occurred.',
      );
  }
}

String? _messageFromResponse(Response<dynamic>? response) {
  final data = response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'] ?? data['detail'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}
