import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/recurring_task_controller.dart';

class RecurringTasks extends StatefulWidget {
  const RecurringTasks({super.key});

  @override
  State<RecurringTasks> createState() => _RecurringTasksState();
}

class _RecurringTasksState extends State<RecurringTasks> {
  RecurringTaskController recurringTaskController =
      Get.put(RecurringTaskController());

  @override
  void initState() {
    super.initState();
    // recurringTaskController.getRecurringTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recurring Tasks"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          recurringTaskController.getRecurringTask();
        },
        child: SafeArea(
          child: Obx(() {
            if (recurringTaskController.isloadingDetails.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (recurringTaskController.recurringTasks.isEmpty) {
              return Center(child: Text("No Recurring Tasks Found"));
            }

            return ListView.builder(
              itemCount: recurringTaskController.recurringTasks.length,
              itemBuilder: (context, index) {
                final task = recurringTaskController.recurringTasks[index];
                return Stack(
                  children: [
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.product,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Part Number: ${task.partNumber}"),
                            Text("Inspector: ${task.inspectorName}"),
                            Text("Status: ${task.status}"),
                            SizedBox(height: 8),
                            Text(
                              "Note: ${task.note}",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            Text(
                                "Maintenance Frequency: ${task.maintenanceFreq}"),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Due Date: ${task.dueDate.split('T')[0]}"),
                                  TextButton(
                                      onPressed: () {
                                        recurringTaskController
                                            .deleteTask(task.id);
                                      },
                                      child: Text("Delete Task")),
                                ])
                          ],
                        ),
                      ),
                    ),
                    task.critical
                        ? Positioned(
                            right: 0,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(0),
                                ),
                              ),
                              child: Text(
                                "Critical Task",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
