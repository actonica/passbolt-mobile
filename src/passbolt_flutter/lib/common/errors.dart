// ©2019-2020 Actonica LLC - All Rights Reserved

class AppError extends Error {
  final String message;

  AppError(this.message);

  @override
  String toString() {
    return 'AppError $message';
  }
}
