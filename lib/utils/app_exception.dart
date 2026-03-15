class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() => "${prefix ?? ''}$message";
}

class AuthException extends AppException {
  AuthException(String message) : super(message, "Authentication Error: ");
}

class ScrapingException extends AppException {
  ScrapingException(String message) : super(message, "Data Error: ");
}

class SessionExpiredException extends AuthException {
  SessionExpiredException() : super("Session has expired. Please login again.");
}

class NetworkException extends AppException {
  NetworkException() : super("No internet connection or server unreachable.");
}

class CaptchaException extends AuthException {
  CaptchaException() : super("CAPTCHA detected. Please log in once via the official website, then try again here.");
}
