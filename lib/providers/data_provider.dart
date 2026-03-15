import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/models.dart';
import '../services/scraper_service.dart';
import '../services/storage_service.dart';


class DataProvider extends ChangeNotifier {
  final ScraperService _scraperService = ScraperService();
  final StorageService _storageService = StorageService();

  List<AttendanceModel> _attendanceList = [];
  List<MarksModel> _marksList = [];
  List<TimetableModel> _timetableList = [];
  
  bool _isLoading = false;
  String? _error;

  List<AttendanceModel> get attendanceList => _attendanceList;
  List<MarksModel> get marksList => _marksList;
  List<TimetableModel> get timetableList => _timetableList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initCache() async {
    try {
      final String? attStr = await _storageService.getCache(_storageService.keyCacheAttendance);
      if (attStr != null) {
        final List<dynamic> decoded = jsonDecode(attStr);
        _attendanceList = decoded.map((e) => AttendanceModel.fromJson(e)).toList();
      }

      final String? marksStr = await _storageService.getCache(_storageService.keyCacheMarks);
      if (marksStr != null) {
        final List<dynamic> decoded = jsonDecode(marksStr);
        _marksList = decoded.map((e) => MarksModel.fromJson(e)).toList();
      }

      final String? timeStr = await _storageService.getCache(_storageService.keyCacheTimetable);
      if (timeStr != null) {
        final List<dynamic> decoded = jsonDecode(timeStr);
        _timetableList = decoded.map((e) => TimetableModel.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Cache Load Error: $e");
    }
  }

  Future<void> fetchAttendance() async {
    await _fetchData(() async {
      _attendanceList = await _scraperService.getAttendance();
      await _storageService.saveCache(_storageService.keyCacheAttendance, jsonEncode(_attendanceList.map((e) => e.toJson()).toList()));
    });
  }

  Future<void> fetchMarks() async {
    await _fetchData(() async {
      _marksList = await _scraperService.getMarks();
      await _storageService.saveCache(_storageService.keyCacheMarks, jsonEncode(_marksList.map((e) => e.toJson()).toList()));
    });
  }

  Future<void> fetchTimetable() async {
    await _fetchData(() async {
      _timetableList = await _scraperService.getTimetable();
      await _storageService.saveCache(_storageService.keyCacheTimetable, jsonEncode(_timetableList.map((e) => e.toJson()).toList()));
    });
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Refresh all in parallel or sequence
      await Future.wait([
        fetchAttendance(),
        fetchMarks(),
        fetchTimetable(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchData(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
