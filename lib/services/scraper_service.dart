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
      // TODO: VERIFY URL
      const String url = 'https://academia.srmist.edu.in/viewAttendance';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        if (kDebugMode) print("Scraping Attendance: SUCCESS (200)");
        
        final document = parse(response.data);
        // Try multiple selectors just in case
        var rows = document.querySelectorAll('table#attendanceTable tr').skip(1);
        if (rows.isEmpty) {
          rows = document.querySelectorAll('table tr').where((element) => element.text.contains('%')).skip(0);
        }
        if (rows.isEmpty) {
          rows = document.querySelectorAll('tr').skip(1);
        }
        
        if (kDebugMode) print("Found ${rows.length} candidate rows in attendance");
        
        List<AttendanceModel> attendanceList = [];
        
        for (var row in rows) {
          final cols = row.querySelectorAll('td');
          if (cols.length >= 5) {
            attendanceList.add(AttendanceModel(
              subjectCode: cols[0].text.trim(), // TODO: VERIFY COLUMN INDEX
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
      // TODO: VERIFY URL
      const String url = 'https://academia.srmist.edu.in/viewMarks';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final document = parse(response.data);
        
        // TODO: VERIFY TABLE SELECTOR
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
      // TODO: VERIFY URL
      const String url = 'https://academia.srmist.edu.in/viewTimetable';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final document = parse(response.data);
        
        // TODO: VERIFY TABLE SELECTOR
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

  /// Fetches detailed attendance for a specific subject.
  /// This usually requires clicking a link or a specific POST request with subject details.
  Future<void> getDetailedAttendance(String subjectCode) async {
     // TODO: Implement after user verifies the list view works.
  }
}
