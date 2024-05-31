import 'package:shared_preferences/shared_preferences.dart';

class Constant {
  // static const String BASE_URL = 'http://10.0.2.2:8000/api';
  static const String BASE_URL = 'http://patroltrack.my.id/api';

  // poltek
  static const double targetLatitude = -8.1599633;
  static const double targetLongitude = 113.7224483;
  static const double allowedDistance = 100.0;

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}  