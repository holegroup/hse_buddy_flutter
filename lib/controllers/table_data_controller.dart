import 'dart:convert';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/models/table_data_model.dart';
import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class TableDataController extends GetxController {
  String baseUrl = Constants.baseUrl;
  final RxBool isloadingDetails = false.obs;
  final RxList<Task> tasks = <Task>[].obs;

  Future<void> getData({String? startDate, String? endDate}) async {
    isloadingDetails.value = true;
    print('Fetching table data...');

    String url = '$baseUrl/api/tasks/get-all-tasks';
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }

    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        tasks.value = data.map((task) => Task.fromJson(task)).toList();
      } else if (response.statusCode == 404) {
        tasks.value = [];
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

  // Future<bool> _requestPermision(Permission permission) async {
  //   AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  //   if (build.version.sdkInt >= 30) {
  //     var re = await Permission.manageExternalStorage.request();
  //     if (re.isGranted) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     if (await permission.isGranted) {
  //       return true;
  //     } else {
  //       var result = await permission.request();
  //       if (result.isGranted) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //   }
  // }

  // Future<void> downloadCsv({String? startDate, String? endDate}) async {
  //   // isloadingDetails.value = true;
  //   print('Downloading CSV...');

  //   String url = '$baseUrl/api/tasks/download-csv';
  //   if (startDate != null && endDate != null) {
  //     url += '?startDate=$startDate&endDate=$endDate';
  //   }

  //   try {
  //     // Check if storage permission is granted, and if not, request it
  //     _requestPermision(Permission.storage);
  //     var status = await Permission.storage.request();
  //     if (status.isGranted) {
  //       final response = await http.get(Uri.parse(url));
  //       print(response.statusCode);

  //       if (response.statusCode == 200) {
  //         final bytes = response.bodyBytes;

  //         // Prompt user to select a directory using the file picker
  //         String? directoryPath = await FilePicker.platform.getDirectoryPath();

  //         // If no directory is selected, exit early
  //         if (directoryPath == null) {
  //           Get.snackbar("Error", "No directory selected");
  //           return;
  //         }

  //         final filePath = '$directoryPath/tasks.csv';
  //         final file = File(filePath);

  //         // Write the bytes to the selected directory
  //         await file.writeAsBytes(bytes);

  //         print('File saved to: $filePath');
  //         Get.snackbar("Success", "CSV downloaded successfully!");
  //       } else {
  //         Get.snackbar("Error", "Failed to download CSV");
  //       }
  //     } else {
  //       // If permission is denied, request it and check again
  //       // Get.snackbar(
  //       //     "Permission Denied", "Please allow storage access permission");
  //       print(status);
  //       Permission.storage.request();
  //       // Optionally, show a dialog or message to explain why you need the permission
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     Get.snackbar("Error", "Something went wrong while downloading the CSV");
  //   } finally {
  //     // isloadingDetails.value = false;
  //   }
  // }

  Future<void> downloadCsv({String? startDate, String? endDate}) async {
    String url = '$baseUrl/api/tasks/download-csv';
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Something went wrong', '');
    }
  }
}
