import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:patrol_track_mobile/core/services/report_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class ReportController {
  
  static Future<bool> checkTodayReport(BuildContext context) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        bool reportedToday = await ReportService.todayReported(token);
        return reportedToday;
      } else {
        throw Exception('Please login first.');
      }
    } catch (e) {
      print('Error while checking today\'s report: $e');
      return false;
    }
  }

  static Future<List<Report>> getReportHistory(BuildContext context) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        List<Report> reports = await ReportService.getAllReports(token);
        return reports;
      } else {
        throw Exception('Please login first.');
      }
    } catch (e) {
      print('Error while fetching reports: $e');
      return [];
    }
  }
}
