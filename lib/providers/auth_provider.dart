import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  final Dio _dio = Dio();

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        'https://dummyjson.com/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        _token = response.data['accessToken'];
        _user = response.data;
        _isLoggedIn = true;
      }
    } on DioException {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _token = null;
    _user = null;
    notifyListeners();
  }
}