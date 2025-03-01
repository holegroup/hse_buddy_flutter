import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:http/http.dart' as http;

class TaskController extends GetxController {
  final LoginController loginController = Get.put(LoginController());
  final String baseUrl = Constants.baseUrl;
  final RxBool getTaskIsLoading = false.obs;
  final RxList tasks = [].obs; // Observable list to store tasks
  final RxString selectedStatus = "All".obs; // Observable for selected filter
  final RxInt pageNumber = 1.obs;
  final RxInt maxPage = 1.obs;
  final RxInt totalResults = 1.obs;

  // final bool isSupervisor;
  // TaskController({});

  // @override
  // void onInit() {
  //   super.onInit();
  //   // Automatically fetch tasks when the controller is initialized
  //   if (isSupervisor) {
  //     getTaskSupervisor();
  //   } else {
  //     getTask();
  //   }
  // }

  // Filtered list of tasks based on the selected filter
  List get filteredTasks {
    if (selectedStatus.value == "All") return tasks;
    return tasks
        .where((task) => task['status'] == selectedStatus.value)
        .toList();
  }

  Future<void> getTask() async {
    getTaskIsLoading.value = true;

    try {
      // Retrieve token
      String? token = await loginController.getToken();
      var user = await loginController.getUserData();

      // Ensure token is valid
      if (token == null || token.isEmpty) {
        throw Exception("Token is null or empty. Authentication failed.");
      }

      String url = "$baseUrl/api/tasks/get-task?pages=${pageNumber}";
      if (user!['role'] == 'supervisor') {
        url = "$baseUrl/api/tasks/get-task-supervisor?pages=${pageNumber}";
      }

      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
      });

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        tasks.value =
            responseData['data']; // Update tasks list with fetched data

        // print(url);
        // print(token);

        //update pagination
        maxPage.value = responseData['pagination']['totalPages'];
        totalResults.value = responseData['pagination']['totalTasks'];
      } else {
        Get.snackbar(
            "API Error", "Failed to retrieve tasks: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("An error occurred", "$e");
    } finally {
      getTaskIsLoading.value = false;
    }
  }

  // Future<void> getTaskSupervisor() async {
  //
  //   getTaskIsLoading.value = true;

  //   try {
  //     // Retrieve token
  //     String? token = await loginController.getToken();

  //     // Ensure token is valid
  //     if (token == null || token.isEmpty) {
  //       throw Exception("Token is null or empty. Authentication failed.");
  //     }

  //     final String url =
  //         "$baseUrl/api/tasks/get-task-supervisor?pages=${pageNumber}";

  //     // Make the HTTP GET request
  //     final response = await http.get(Uri.parse(url), headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": 'Bearer $token',
  //     });

  //     // Handle response
  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       tasks.value =
  //           responseData['data']; // Update tasks list with fetched data
  //
  //       //
  //
  //     } else {
  //       Get.snackbar(
  //           "API Error", "Failed to retrieve tasks: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     Get.snackbar("An error occurred", "$e");
  //   } finally {
  //     getTaskIsLoading.value = false;
  //
  //   }
  // }

  Future<void> markAsDone({
    required String taskId,
  }) async {
    final String url = "$baseUrl/api/tasks/change-status";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json", // Specify JSON content
        },
        body: jsonEncode({
          "taskId": taskId,
          "status": "Completed",
        }),
      );
      if (response.statusCode == 200) {
        try {
          getTask();
        } finally {
          Get.snackbar("", "Your task has been maked as Done");
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);

  // List get tasksFilteredByDate {
  //   if (selectedDateRange.value == null) return tasks;

  //   final start = selectedDateRange.value!.start;
  //   final end = selectedDateRange.value!.end;

  //   return tasks.where((task) {
  //     final dueDate = DateTime.parse(task['due_date']);
  //     return dueDate.isAfter(start.subtract(Duration(days: 1))) &&
  //         dueDate.isBefore(end.add(Duration(days: 1)));
  //   }).toList();
  // }

  // Map<String, double> getFilteredTaskStats() {
  //   Map<String, double> stats = {};
  //   for (var task in tasksFilteredByDate) {
  //     final status = task['status'];
  //     stats[status] = (stats[status] ?? 0) + 1;
  //   }
  //   return stats;
  // }

  Future<void> deleteTask({
    required String taskId,
  }) async {
    final String url = "$baseUrl/api/tasks/delete-task?taskId=${taskId}";
    try {
      final response = await http.delete(
        Uri.parse(url),
      );

      Get.snackbar('Task Deleted', response.body);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  final buttons = ["All", "Pending", "Due Soon", "Overdue", "Completed"];

  IconData getTrailingIcon(String status) {
    switch (status) {
      case "Pending":
        return Icons.pending_actions;
      case "Due Soon":
        return Icons.timelapse_sharp;
      case "Overdue":
        return Icons.error;
      case "Completed":
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color getTrailingIconColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.blue;
      case "Due Soon":
        return Colors.orange.shade800;
      case "Overdue":
        return Colors.red;
      case "Completed":
        return Colors.green;
      default:
        return Colors.grey; // Default color for unknown statuses
    }
  }

  // Map<String, Color> getTaskStatusColors() {
  //   return {
  //     "Pending": Colors.blue,
  //     "Due Soon": Colors.orange.shade800,
  //     "Overdue": Colors.red,
  //     "Completed": Colors.green,
  //   };
  // }
}
