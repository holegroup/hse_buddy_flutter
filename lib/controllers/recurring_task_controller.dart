import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/models/recurring_task_model.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class RecurringTaskController extends GetxController {
  final String baseUrl = Constants.baseUrl;
  final RxBool isloadingDetails = false.obs;

  final RxList<RecurringTask> recurringTasks = <RecurringTask>[].obs;

  Future<void> getRecurringTask() async {
    isloadingDetails.value = true;
    final String url = "$baseUrl/api/tasks/get-all-recurring-task";
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        recurringTasks.value =
            data.map((task) => RecurringTask.fromJson(task)).toList();
      } else {
        Get.snackbar("Error", "Failed to fetch data");
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isloadingDetails.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final String url =
        "$baseUrl/api/tasks/change-recurring-status?taskId=$taskId&status=false";

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        recurringTasks.removeWhere((task) => task.id == taskId);
        Get.snackbar("Success", "Task deleted successfully");
      } else {
        Get.snackbar("Error", "Failed to delete task");
      }

      print(response.statusCode);
      print(response.body);
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }
}
