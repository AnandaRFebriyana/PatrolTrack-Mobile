import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static Future<User?> login(String email, String password) async {
    final url = Uri.parse('${Constant.BASE_URL}/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return User.fromJson(result['data']);
    } else {
      final errorResult = jsonDecode(response.body);
      throw '${errorResult['error'] ?? 'Unknown error occurred'}';
    }
  }

  static Future<void> logout(SharedPreferences prefs) async {
    final url = Uri.parse('${Constant.BASE_URL}/logout');
    final token = prefs.getString('token');
    if (token != null) {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
    }
  }
}