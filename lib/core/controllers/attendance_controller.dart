import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/services/attendance_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';
import 'package:quickalert/quickalert.dart';

class AttendanceController {
  
  static Future<List<Attendance>> getAttendanceHistory(
      BuildContext context) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        List<Attendance> attendances =
            await AttendanceService.getAllAttendances(token);
        return attendances;
      } else {
        throw Exception('Please login first.');
      }
    } catch (error) {
      throw Exception(
          'Failed to fetch attendance history: ${error.toString()}');
    }
  }

  static Future<Attendance> getToday(BuildContext context) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        Attendance attendances = await AttendanceService.getToday(token);
        return attendances;
      } else {
        throw Exception('Please login first.');
      }
    } catch (error) {
      print('Failed to fetch attendance today: ${error.toString()}');
      throw 'Failed to fetch attendance today: ${error.toString()}';
    }
  }

  static Future<void> saveCheckIn(BuildContext context, {required int id,
      required TimeOfDay checkIn, required double longitude,
      required double latitude, required String locationAddress, File? photo}) async {
    try {
      await AttendanceService.postCheckIn(
        id: id,
        checkIn: checkIn,
        longitude: longitude,
        latitude: latitude,
        locationAddress: locationAddress,
        photo: photo,
      );
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Success!',
        text: 'Attendance saved successfully',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Get.toNamed('/menu-nav');
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $error');
    }
  }
}