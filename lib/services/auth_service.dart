import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/app_exception.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final Dio _dio = Dio();
  final CookieJar _cookieJar = CookieJar();
  final StorageService _storage = StorageService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthService._internal() {
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.options.followRedirects = false; // Important for 302 detection
    _dio.options.validateStatus = (status) => status! < 500;
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    };
  }

  Dio get dio => _dio;

  /// Performs login using NetID and Password.
  /// 
  /// SECURITY: Password is used only for the local POST request and is never logged or stored.
  Future<bool> login(String netID, String password) async {
    try {
      // TODO: VERIFY URL
      const String loginUrl = 'https://academia.srmist.edu.in/j_security_check';
      
      final Response response = await _dio.post(
        loginUrl,
        data: {
          // TODO: VERIFY FIELD NAMES
          'j_username': netID,
          'j_password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      // Status 302 usually indicates success (redirecting to dashboard)
      if (response.statusCode == 302) {
        final cookies = await _cookieJar.loadForRequest(Uri.parse('https://academia.srmist.edu.in'));
        if (cookies.isNotEmpty) {
          final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
          await _storage.saveSessionCookie(cookieString);
          await _storage.saveNetID(netID);
          await _storage.saveCredentials(netID, password); // For biometrics
          return true;
        }
      } else if (response.statusCode == 200) {
        // Status 200 on login page often means a CAPTCHA or "Invalid Credentials"
        if (response.data.toString().contains('captcha') || response.data.toString().contains('CAPTCHA')) {
          throw CaptchaException();
        }
        throw AuthException("Incorrect NetID or Password. Please try again.");
      }
      
      throw AuthException("Unexpected response from server (${response.statusCode})");
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _cookieJar.deleteAll();
    await _storage.clearSession();
  }

  Future<void> hardLogout() async {
    await _cookieJar.deleteAll();
    await _storage.wipeCredentials();
  }

  Future<bool> isLoggedIn() async {
    final cookie = await _storage.getSessionCookie();
    return cookie != null && cookie.isNotEmpty;
  }

  // --- Biometric Auth logic ---

  /// Checks if biometric login is available and credentials exist natively.
  Future<bool> canUseBiometrics() async {
    final password = await _storage.getPassword();
    if (password == null || password.isEmpty) return false;
    
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Prompts biometric and performs login with stored credentials if success.
  Future<bool> authenticateWithBiometrics() async {
    final netID = await _storage.getNetID();
    final password = await _storage.getPassword();
    if (netID == null || password == null) return false;

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to log into SRM Client',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        return await login(netID, password);
      }
    } catch (e) {
      throw AuthException('Biometric authentication failed: $e');
    }
    return false;
  }
}
