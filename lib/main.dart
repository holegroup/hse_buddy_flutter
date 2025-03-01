import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/config/sse_service.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:hole_hse_inspection/views/home.dart';
import 'package:hole_hse_inspection/views/supervisor/supervisor_dashboard.dart';
import 'package:hole_hse_inspection/views/login.dart';
import 'package:path_provider/path_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  // Open the Hive box for drafts
  await Hive.openBox('draftBox');

  // Check if user data exists in Hive
  var userBox = await Hive.openBox('userBox');
  var userData = userBox.get('userData');

  // Determine initial route based on stored data
  String initialRoute;
  if (userData != null && userData['user']['role'] == "supervisor") {
    initialRoute = '/supervisor-dashboard';
  } else if (userData != null && userData['user']['role'] == "inspector") {
    initialRoute = '/';
  } else {
    initialRoute = '/login';
  }

  SseService sseService = SseService();
  if (Platform.isAndroid) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }
  sseService.listenToEvents(); // Start listening when app starts

  // Initialize Background SSE Listener
  // await initBackgroundService();
  
  // Initialize the Background Service Controller
  // Get.put(BackgroundServiceController());
  
  runApp(MyApp(initialRoute: initialRoute));
}
 
class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hole HSE Inspection',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: buildTheme(),
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/supervisor-dashboard', page: () => SupervisorDashboard()),
        GetPage(name: '/camera', page: () => CameraView()),
        GetPage(name: '/login', page: () => Login()),
      ],
    );
  }
}
