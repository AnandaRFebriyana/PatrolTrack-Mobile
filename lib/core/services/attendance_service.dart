import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class AttendanceService {
  static Future<List<Attendance>> getAllAttendances(String token) async {
    final url = Uri.parse('${Constant.BASE_URL}/history-presence');
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      List<Attendance> attendances = List<Attendance>.from(
        result['data'].map(
          (attendances) => Attendance.fromJson(attendances),
        ),
      );
      return attendances;
    } else {
      throw Exception('Failed to load attendances');
    }
  }

  static Future<Attendance> getToday() async {
    String? token = await Constant.getToken();
    final url = Uri.parse('${Constant.BASE_URL}/today-presence');
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Attendance.fromJson(result['data']);
    } else {
      throw 'Failed to load attendance data. Status code: ${response.statusCode}';
    }
  }

  static Future<String> postCheckIn(
      {required int id,
      required TimeOfDay checkIn,
      required double longitude,
      required double latitude,
      required String locationAddress,
      File? photo}) async {
    try {
      String? token = await Constant.getToken();

      final url = Uri.parse('${Constant.BASE_URL}/check-in/$id');
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = '$token';
      request.headers['Accept'] = 'application/json';

      request.fields['check_in_time'] = _formatTimeOfDay(checkIn);
      request.fields['longitude'] = longitude.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['location_address'] = locationAddress;

      if (photo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      }

      print('Request Fields: ${request.fields}');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return responseBody.body;
      } else {
        throw 'Failed to make a presence. Status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to make a presence: $e');
    }
  }

  static Future<void> postCheckOut({required int id, required TimeOfDay checkOut}) async {
    String? token = await Constant.getToken();

    final url = Uri.parse('${Constant.BASE_URL}/check-out/$id');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = '$token';
    request.headers['Accept'] = 'application/json';

    request.fields['check_out_time'] = _formatTimeOfDay(checkOut);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Succsessfully check out.');
    } else {
      throw 'Failed to make a presence. Status code: ${response.statusCode}';
    }
  }

  static String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}