import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  User? _user;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  User? get user => _user;

  Future<bool> tryRestoreSession() async {
    String? saved;
    try {
      await _authService.deleteToken();
      saved = await _authService.readToken().timeout(Duration(seconds: 3));
    } catch (e) {
      print("Token read failed or timed out: $e");
      saved = null;
    }

    if (saved != null && saved.isNotEmpty) {
      _token = saved;
      try {
        final api = ApiService(token: _token);
        _user = await api.getCurrentUser().timeout(Duration(seconds: 5));
        notifyListeners();
        return true;
      } catch (e) {
        print("Token validation failed: $e");
        await _authService.deleteToken();
        _token = null;
        _user = null;
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  Future<void> login(String email, String password) async {
    final api = ApiService();
    final token = await api.login(email, password);
    _token = token;
    await _authService.saveToken(token);
    // fetch user
    final apiWithToken = ApiService(token: _token);
    _user = await apiWithToken.getCurrentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        final api = ApiService(token: _token);
        await api.logout();
      } catch (_) {
        // ignore logout errors - still clear local token
      }
    }
    _token = null;
    _user = null;
    await _authService.deleteToken();
    notifyListeners();
  }
}
