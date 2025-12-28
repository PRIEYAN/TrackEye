import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/auth_storage.dart';
import '../models/auth_models.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserRole? get userRole => _user?.role;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data is Map && data.containsKey('data') ? data['data'] : data;
        
        final token = responseData['token'] ?? responseData['access_token'] ?? data['token'];
        if (token != null) {
          await AuthStorage.saveToken(token);
        }

        final userData = responseData['user'] ?? responseData;
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['detail'] ?? errorData['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final data = responseData is Map && responseData.containsKey('data') ? responseData['data'] : responseData;
        
        final token = data['token'] ?? data['access_token'] ?? responseData['token'];
        if (token != null) {
          await AuthStorage.saveToken(token);
        }

        final userData = data['user'] ?? data;
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['detail'] ?? errorData['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data is Map && data.containsKey('data') ? data['data'] : data;
        _user = User.fromJson(responseData);
        _isAuthenticated = true;
      } else {
        await AuthStorage.clear();
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      await AuthStorage.clear();
      _isAuthenticated = false;
      _user = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthStorage.clear();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}

