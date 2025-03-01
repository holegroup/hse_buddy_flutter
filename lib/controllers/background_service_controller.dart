// import 'package:get/get.dart';
// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// class BackgroundServiceController extends GetxController {
//   final FlutterBackgroundService _service = FlutterBackgroundService();

//   @override
//   void onInit() {
//     super.onInit();
//     initializeBackgroundService();
//   }

//   Future<void> initializeBackgroundService() async {
//     // Configure the background service
//     await _service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onServiceStart, // Use the top-level function here
//         isForegroundMode: true,
//         autoStart: true,
//       ),
//       iosConfiguration: IosConfiguration(
//         autoStart: true,
//         onForeground: onServiceStart,
//       ),
//     );

//     // Optionally start the service immediately
//     _service.startService();
//   }
// }


// void onServiceStart(ServiceInstance service) {
//   print("Background service connected");

//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   Timer.periodic(Duration(seconds: 5), (timer) {
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'channel_id',
//       'Background Notifications',
//       channelDescription: 'Notifications from the background service',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: false,
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     flutterLocalNotificationsPlugin.show(
//       0,
//       'Hole HSE Inspection',
//       'Notification from Background Service',
//       notificationDetails,
//     );
//   });
// }