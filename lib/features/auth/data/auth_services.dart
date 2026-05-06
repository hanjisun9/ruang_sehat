import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruang_sehat/features/auth/data/user_model.dart';

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

  static Future<http.Response> logout() async {
    final url = Uri.parse('$authBaseUrl/logout');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return await http.post(
      url,
      headers: {
        'Content-Type':'application/json',
        'Authorization': 'Bearer $token',
      }
    );
  }

  static Future<UserModel> getProfile() async {
    final url = Uri.parse('$baseUrl/auth/profile');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      url,
      headers: {
        'Content-Type' : 'application/json',
        'Authorization' : 'Bearer $token'
      }
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      return UserModel.fromJson(data);
    } else{
      throw Exception('Gagal mengambil profil');
    }
  }

  static Future<http.Response> updateProfile({
  String? name,
  String? username,
  String? password,
}) async {
  final url = Uri.parse('$authBaseUrl/profile');

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final Map<String, dynamic> body = {};
  if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
  if (username != null && username.trim().isNotEmpty) body['username'] = username.trim();
  if (password != null && password.isNotEmpty) body['password'] = password;

  return await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );
}
}