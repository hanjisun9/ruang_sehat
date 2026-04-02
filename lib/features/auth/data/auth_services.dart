import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static final String baseUrl = dotenv.env['BASE_URL']!;
  static final String authBaseUrl = '$baseUrl/auth';

  static Future<http.Response> register(
    String name,
    String username,
    String password,
  ) async {
    final url = Uri.parse('$authBaseUrl/register');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
        'appSource': 'kesehatan',
      }),
    );
  }

  static Future<http.Response> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$authBaseUrl/login');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'appSource': 'kesehatan',
      }),
    );
  }
}