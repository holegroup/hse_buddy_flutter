import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/recurring_task_controller.dart';
import 'package:hole_hse_inspection/views/supervisor/create_task.dart';
import 'package:hole_hse_inspection/views/supervisor/recurringTasks.dart';
import '../../controllers/login_controller.dart';
import 'ta_home.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final LoginController controller = Get.put(LoginController());
  final TaskController taskController = Get.put(TaskController());
  RecurringTaskController recurringTaskController =
      Get.put(RecurringTaskController());

  int _currentIndex = 0;

  final List<Widget> _tabs = [
    TaHome(),
    RecurringTasks(),
    CreateTask(),
  ];

  @override
  void initState() {
    super.initState();
    taskController.getTask();
    recurringTaskController.getRecurringTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: ColorPalette.primaryColor,
        unselectedItemColor: ColorPalette.light2,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'See Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create_new_folder_rounded),
            label: 'Create Task',
          ),
        ],
      ),
    );
  }
}
