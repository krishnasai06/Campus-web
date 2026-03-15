import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;
import '../models/models.dart';
import '../utils/app_exception.dart';
import 'auth_service.dart';

class ScraperService {
  final Dio _dio = AuthService().dio;

  /// Fetches and parses Attendance data.
  Future<List<AttendanceModel>> getAttendance() async {
    try {
      const String url = 'https://academia.srmist.edu.in/viewAttendance';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        if (kDebugMode) print("Scraping Attendance: SUCCESS (200)");
        
        final document = parse(response.data);
        var rows = document.querySelectorAll('table#attendanceTable tr').skip(1);
        if (rows.isEmpty) {
          rows = document.querySelectorAll('table tr').where((element) => element.text.contains('%')).skip(0);
        }
        if (rows.isEmpty) {
          rows = document.querySelectorAll('tr').skip(1);
        }
        
        List<AttendanceModel> attendanceList = [];
        for (var row in rows) {
          final cols = row.querySelectorAll('td');
          if (cols.length >= 5) {
            attendanceList.add(AttendanceModel(
              subjectCode: cols[0].text.trim(),
              subjectName: cols[1].text.trim(),
              attended: int.tryParse(cols[2].text.trim()) ?? 0,
              total: int.tryParse(cols[3].text.trim()) ?? 0,
              percentage: double.tryParse(cols[4].text.replaceFirst('%', '').trim()) ?? 0.0,
            ));
          }
        }
        return attendanceList;
      }
      throw ScrapingException("Failed to load attendance data.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScrapingException("Error parsing attendance: ${e.toString()}");
    }
  }

  /// Fetches and parses Marks data.
  Future<List<MarksModel>> getMarks() async {
    try {
      const String url = 'https://academia.srmist.edu.in/viewMarks';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final document = parse(response.data);
        final rows = document.querySelectorAll('table tr').skip(1);
        
        List<MarksModel> marksList = [];
        for (var row in rows) {
          final cols = row.querySelectorAll('td');
          if (cols.length >= 6) {
            marksList.add(MarksModel(
              subjectCode: cols[0].text.trim(),
              subjectName: cols[1].text.trim(),
              internal: cols[2].text.trim(),
              external: cols[3].text.trim(),
              total: cols[4].text.trim(),
              grade: cols[5].text.trim(),
            ));
          }
        }
        return marksList;
      }
      throw ScrapingException("Failed to load marks data.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScrapingException("Error parsing marks: ${e.toString()}");
    }
  }

  /// Fetches and parses Timetable data.
  Future<List<TimetableModel>> getTimetable() async {
    try {
      const String url = 'https://academia.srmist.edu.in/viewTimetable';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final document = parse(response.data);
        final rows = document.querySelectorAll('table tr').skip(1);
        
        List<TimetableModel> timetableList = [];
        for (var row in rows) {
          final cols = row.querySelectorAll('td');
          if (cols.length >= 4) {
             timetableList.add(TimetableModel(
              day: cols[0].text.trim(),
              slot: cols[1].text.trim(),
              time: cols[2].text.trim(),
              subject: cols[3].text.trim(),
              room: cols.length > 4 ? cols[4].text.trim() : null,
              faculty: cols.length > 5 ? cols[5].text.trim() : null,
            ));
          }
        }
        return timetableList;
      }
      throw ScrapingException("Failed to load timetable data.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScrapingException("Error parsing timetable: ${e.toString()}");
    }
  }
}
