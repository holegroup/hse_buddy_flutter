// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hole_hse_inspection/config/env.dart';
// import 'package:http/http.dart' as http;
// import 'package:workmanager/workmanager.dart';

// final String baseUrl = Constants.baseUrl;

// /// **Background Task Name**
// const String backgroundTaskKey = "background_sse_listener";

// /// **Initialize Background Service**
// Future<void> initBackgroundService() async {
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false, // Set to true for debugging
//   );
//   await Workmanager().registerOneOffTask(
//     backgroundTaskKey,
//     backgroundTaskKey,
//     initialDelay: Duration(seconds: 5), // Delay to ensure service starts properly
//   );
// }

// /// **Background Task Handler**
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     print("✅ Background SSE Listener Started");

//     // Initialize Notifications
//     final FlutterLocalNotificationsPlugin notificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/launcher_icon');
//     const InitializationSettings settings =
//         InitializationSettings(android: androidSettings);
//     await notificationsPlugin.initialize(settings);

//     // Start SSE Listening
//     await _listenToSse(notificationsPlugin);

//     return Future.value(true);
//   });
// }

// /// **Listen to SSE Events in Background**
// Future<void> _listenToSse(FlutterLocalNotificationsPlugin notificationsPlugin) async {
//   final String serverUrl = "$baseUrl/api/sse/message";
//   var request = http.Request('GET', Uri.parse(serverUrl));

//   try {
//     var streamedResponse = await request.send();
//     streamedResponse.stream.transform(utf8.decoder).listen((event) async {
//       if (event.startsWith("data:")) {
//         String jsonString = event.substring(5).trim();
//         Map<String, dynamic> data = jsonDecode(jsonString);

//         print("🔔 Background Notification: ${data["message"]}");
//         await _showNotification(notificationsPlugin, data["message"]);
//       }
//     });
//   } catch (e) {
//     print("❌ Error in SSE Background Service: $e");
//   }
// }

// /// **Show Notification in Background**
// Future<void> _showNotification(
//     FlutterLocalNotificationsPlugin notificationsPlugin, String message) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'sse_channel',
//     'SSE Notifications',
//     importance: Importance.high,
//     priority: Priority.high,
//     icon: '@mipmap/launcher_icon',
//   );

//   const NotificationDetails details = NotificationDetails(android: androidDetails);

//   await notificationsPlugin.show(0, 'New Notification', message, details);
// }
