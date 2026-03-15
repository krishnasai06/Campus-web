import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/models.dart';
import '../utils/app_exception.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isCheckingAuth = true; // New state for splash/init check
  String? _error;
  bool _isLoggedIn = false;
  bool _canUseBiometrics = false;
  bool _needsCaptcha = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get canUseBiometrics => _canUseBiometrics;
  bool get needsCaptcha => _needsCaptcha;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      final netID = await _storageService.getNetID();
      if (netID != null) {
        _user = UserModel(netID: netID);
      }
    } else {
       _canUseBiometrics = await _authService.canUseBiometrics();
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<bool> loginWithBiometrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.authenticateWithBiometrics();
      if (success) {
        _isLoggedIn = true;
        final netID = await _storageService.getNetID();
        _user = UserModel(netID: netID ?? 'User');
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String netID, String password) async {
    _isLoading = true;
    _error = null;
    _needsCaptcha = false;
    notifyListeners();

    try {
      final success = await _authService.login(netID, password);
      if (success) {
        _isLoggedIn = true;
        _user = UserModel(netID: netID);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Login failed.";
      }
    } on CaptchaException {
      _needsCaptcha = true;
      _error = "Verification Required. Please solve the CAPTCHA.";
    } catch (e) {
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void setLoggedInManually(String netID) {
    _isLoggedIn = true;
    _user = UserModel(netID: netID);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _user = null;
    _canUseBiometrics = await _authService.canUseBiometrics();
    notifyListeners();
  }

  /// Use when user wants to remove saved password as well
  Future<void> hardLogout() async {
    await _authService.hardLogout();
    _isLoggedIn = false;
    _user = null;
    _canUseBiometrics = false;
    notifyListeners();
  }
}
