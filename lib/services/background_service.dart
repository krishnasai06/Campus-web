import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'scraper_service.dart';
import 'storage_service.dart';
import '../models/models.dart';

class BackgroundService {
  static const String taskName = "sync_attendance_task";

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    // Initialize Workmanager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> scheduleTask() async {
    await Workmanager().registerPeriodicTask(
      "1",
      taskName,
      frequency: const Duration(hours: 3), // SRM portal usually updates every few hours
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'srm_alerts',
      'Attendance Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundService.taskName) {
      final ScraperService scraper = ScraperService();
      final StorageService storage = StorageService();

      try {
        final newAttendance = await scraper.getAttendance();
        if (newAttendance.isNotEmpty) {
          final oldAttStr = await storage.getCache(storage.keyCacheAttendance);
          
          if (oldAttStr != null) {
            final List<dynamic> oldData = jsonDecode(oldAttStr);
            final oldList = oldData.map((e) => AttendanceModel.fromJson(e)).toList();

            // Compare percentages
            for (int i = 0; i < newAttendance.length; i++) {
              if (i < oldList.length) {
                if (newAttendance[i].percentage != oldList[i].percentage) {
                  await BackgroundService.showNotification(
                    "Attendance Updated",
                    "New status for ${newAttendance[i].subjectName}: ${newAttendance[i].percentage}%"
                  );
                  break;
                }
              }
            }
          }

          // Update cache
          await storage.saveCache(storage.keyCacheAttendance, jsonEncode(newAttendance.map((e) => e.toJson()).toList()));
        }
      } catch (e) {
        // Silently fail in background
      }
    }
    return Future.value(true);
  });
}
