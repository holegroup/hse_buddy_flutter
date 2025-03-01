import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';
import 'package:hole_hse_inspection/views/supervisor/survey_form.dart';
import 'package:hole_hse_inspection/widgets/paginate.dart';

class AllTasksTa extends StatelessWidget {
  AllTasksTa({super.key});
  final TaskController taskController = Get.put(TaskController());

  Future<void> _refreshData() async {
    await taskController.getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 219, 223),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        surfaceTintColor: Color.fromARGB(255, 213, 219, 223),
        backgroundColor: Color.fromARGB(255, 213, 219, 223),
        title: Text("All Tasks"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //filter buttons
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: taskController.buttons.length,
                  itemBuilder: (context, index) {
                    final buttonLabel = taskController.buttons[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 8, bottom: 8, right: 4),
                      child: Obx(() {
                        final isSelected =
                            taskController.selectedStatus.value == buttonLabel;

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            backgroundColor: isSelected
                                ? Colors.white
                                : ColorPalette.primaryColor,
                            foregroundColor:
                                isSelected ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          onPressed: () {
                            taskController.selectedStatus.value = buttonLabel;
                          },
                          child: Text(buttonLabel),
                        );
                      }),
                    );
                  },
                ),
              ),
              Obx(() {
                if (taskController.getTaskIsLoading.value) {
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.8,
                    child: const Center(
                      child: Text('Loading...'),
                    ),
                  );
                }

                if (taskController.filteredTasks.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.8,
                    child: const Center(
                      child: Text("No tasks available."),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: taskController.filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = taskController.filteredTasks[index];
                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: ColorPalette.light2,
                                  child: Icon(Icons.person),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['inspector_name'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(task['email']),
                                ],
                              )
                            ],
                          ),
                          ListTile(
                            title: Text(
                              task['product'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Part number: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('${task['part_number']}'),
                                  ],
                                ),
                                Text('Note: ${task['note']}'),
                                Text(
                                    "Due Date: ${DateTime.parse(task['due_date']).toLocal()}"),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    "${task['status']}",
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              taskController.getTrailingIcon(task['status']),
                              color: taskController
                                  .getTrailingIconColor(task['status']),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Delete task?"),
                                          content: const Text(
                                              "Are you sure you want to delete this Task? This action can not be modified later."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                try {
                                                  taskController.deleteTask(
                                                      taskId: task['_id']);
                                                } finally {
                                                  Get.back();
                                                  taskController.getTask();
                                                }
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(
                                    "Delete Task",
                                    style: TextStyle(color: ColorPalette.dark2),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1, // Width of the vertical divider
                                color: Colors.grey, // Color of the divider
                                height: 35, // Height of the divider
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(SurveyForm(
                                      taskId: task['_id'],
                                    ));
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text(
                                    "View Survey",
                                    style: TextStyle(
                                        color: ColorPalette.primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
              SizedBox(
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Paginate(),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: Paginate(),
    );
  }
}
