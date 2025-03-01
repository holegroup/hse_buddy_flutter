import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:hole_hse_inspection/widgets/paginate.dart';

class AllTasks extends StatelessWidget {
  AllTasks({super.key});
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
                                ? Colors.grey[300]
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
                    return Stack(
                      children: [
                        Card(
                          elevation: 6,
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
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
                                    // Text('Iscritical: ${task['critical']}'),
                                    Text(
                                        "Due Date: ${DateTime.parse(task['due_date']).toLocal()}"),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${task['status']}",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  taskController
                                      .getTrailingIcon(task['status']),
                                  color: taskController
                                      .getTrailingIconColor(task['status']),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        task['status'] == 'Completed'
                                            ? null
                                            : showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Mark as Done"),
                                                    content: const Text(
                                                        "Are you sure you want to mark this as done? This action can not be modified later."),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Cancel"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          taskController
                                                              .markAsDone(
                                                                  taskId: task[
                                                                      '_id']);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "Mark as Done",
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
                                        "Mark as Done",
                                        style: TextStyle(
                                            color: task['status'] == 'Completed'
                                                ? Colors.grey
                                                : ColorPalette.dark2),
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
                                        Get.to(() => CameraView(
                                              equipmentName: task['product'],
                                              partNumber: task['part_number'],
                                              taskId: task['_id'],
                                              note: task['note'],
                                            ));
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
                                      child: const Text(
                                        "Survey",
                                        style: TextStyle(
                                            color: ColorPalette.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        task['critical'] == true
                            ? Positioned(
                                right: 0,
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Critical Task",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        Icons.warning_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
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
    );
  }
}
