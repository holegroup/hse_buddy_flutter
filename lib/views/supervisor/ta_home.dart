import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';
import 'package:hole_hse_inspection/views/profile.dart';
import 'package:hole_hse_inspection/views/supervisor/all_tasks_ta.dart';
import 'package:hole_hse_inspection/views/supervisor/new_listing.dart';
import 'package:hole_hse_inspection/views/supervisor/table_data.dart';
import 'package:hole_hse_inspection/views/view_sites.dart';
import 'package:hole_hse_inspection/widgets/drawer_button.dart';
import 'package:hole_hse_inspection/widgets/gand_chart.dart';
import '../../config/color.palate.dart';

class TaHome extends StatefulWidget {
  TaHome({super.key});

  @override
  State<TaHome> createState() => _TaHomeState();
}

class _TaHomeState extends State<TaHome> {
  final TaskController taskController = Get.put(TaskController());

  Future<void> _refreshData() async {
    print("Refreshing data...");
    await taskController.getTask();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Discover",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constrains) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/icon.png',
                    filterQuality: FilterQuality.low,
                    width: constrains.maxWidth * 0.4,
                  ),
                  SizedBox(height: 80),
                  CustomDrawerButton(
                    icon: Icons.settings,
                    label: "Profile Settings",
                    onPressed: () {
                      Get.to(() => Profile());
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.data_usage,
                    label: "View site data",
                    onPressed: () {
                      Get.to(() => ViewSites());
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.streetview,
                    label: "New Listings",
                    onPressed: () {
                      Get.to(() => NewListing());
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.data_array_outlined,
                    label: "Table Data",
                    onPressed: () {
                      Get.to(() => TableData());
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskPieChart(),
                    SizedBox(height: 50),
                    Obx(() {
                      if (taskController.getTaskIsLoading.value) {
                        return const Center(
                          child: Text("Loading..."),
                        );
                      }

                      if (taskController.tasks.isEmpty) {
                        return const Center(
                          child: Text("No tasks available."),
                        ); // No tasks message
                      }

                      // Limit tasks to show maximum of 3 initially
                      final tasksToShow = taskController.tasks.length > 3
                          ? taskController.tasks.sublist(0, 3)
                          : taskController.tasks;

                      return Column(
                        children: [
                          // Flexible height ListView
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap:
                                true, // Automatically takes required height
                            itemCount: tasksToShow.length,
                            itemBuilder: (context, index) {
                              final task = tasksToShow[index];
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    task['product'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Note: ${task['note']}'),
                                      Text(
                                          "Due Date: ${DateTime.parse(task['due_date']).toLocal()}"),
                                      Text("Status: ${task['status']}"),
                                    ],
                                  ),
                                  trailing: Icon(
                                    taskController
                                        .getTrailingIcon(task['status']),
                                    color: taskController
                                        .getTrailingIconColor(task['status']),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Show "Show More" button if there are more than 3 tasks
                          if (taskController.tasks.length > 0)
                            TextButton(
                              onPressed: () {
                                Get.to(() => AllTasksTa());
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Show More",
                                    style: TextStyle(
                                        color: ColorPalette.primaryColor),
                                  ),
                                  Icon(Icons.arrow_right_rounded),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    return "${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}";
  }
}
