import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/services/auth_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {

  static Future<void> login(BuildContext context, TextEditingController email, TextEditingController password) async {
    try {
      User? user = await AuthService.login(email.text, password.text);
      if (user != null && user.token != null) {
        await Constant.saveToken(user.token!);

        Get.toNamed('/menu-nav', arguments: user);
      }
    } catch (error) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Gagal!',
        text: error.toString(),
      );
    }
  }

  static Future<void> logout(BuildContext context, SharedPreferences prefs) async {
    try {
      await AuthService.logout(prefs);
      Get.offAllNamed('/login');
    } catch (error) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Gagal Logout!',
        text: error.toString(),
      );
    }
  }
}