// ©2019-2020 Actonica LLC - All Rights Reserved

class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() {
    return '$message';
  }
}

class UserIntentValidationException extends AppException {
  UserIntentValidationException(String message) : super(message);

  @override
  String toString() {
    return 'UserIntentValidationException: $message';
  }
}

class HttpClientException extends AppException {
  HttpClientException(String message) : super(message);

  @override
  String toString() {
    return 'HttpClientException: $message';
  }
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message);

  @override
  String toString() {
    return 'UnauthorizedException: $message';
  }
}

class NoInternetException extends AppException {
  NoInternetException(String message) : super(message);

  @override
  String toString() {
    return this.message;
  }
}

class ServerApiException extends AppException {
  ServerApiException(String message) : super(message);

  @override
  String toString() {
    return 'ServerApiException: $message';
  }
}

class SettingsProviderException extends AppException {
  SettingsProviderException(String message) : super(message);

  @override
  String toString() {
    return 'SettingsProviderException: $message';
  }
}
