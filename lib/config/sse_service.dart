import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;

final String baseUrl = Constants.baseUrl;

class SseService {
  final String serverUrl = "${baseUrl}/api/sse/message";
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SseService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sse_channel',
      'SSE Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, 'New Notification', message, details);
  }

  void listenToEvents() async {
    var request = http.Request('GET', Uri.parse(serverUrl));
    var streamedResponse = await request.send();

    streamedResponse.stream.transform(utf8.decoder).listen((event) {
      if (event.startsWith("data:")) {
        String jsonString = event.substring(5).trim();
        Map<String, dynamic> data = jsonDecode(jsonString);
        print("New Notification: ${data["message"]}");
        _showNotification(data["message"]); 
      }
    });
  }
}
