import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/draft_controller.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:get/get.dart';

class SurveyController extends GetxController {
  final RxBool isLoading = false.obs;
  final String baseUrl = Constants.baseUrl;

  Future<void> submitReport({
    required String equipNameLook,
    required String dateManufacture,
    required String partNum,
    required String serialNum,
    required String maintenanceFreq,
    required String equipDesc,
    required String location,
    required String lat,
    required String long,
    required List<XFile> files,
    required String taskId,
    int? draftIndex,
  }) async {
    print('submit api called');
    final String url = "$baseUrl/api/forms/submit-inspection-form";

    try {
      isLoading.value = true;

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add form fields
      request.fields.addAll({
        "equip_name_look": equipNameLook,
        "date_manufacture": dateManufacture,
        "part_num": partNum,
        "serial_num": serialNum,
        "maintenance_freq": maintenanceFreq,
        "equip_desc": equipDesc,
        "location": location,
        "lat": lat,
        "long": long,
        "taskId": taskId,
      });

      // Convert XFiles to MultipartFiles and add them to the request
      for (var file in files) {
        var fileStream = await http.MultipartFile.fromPath(
          'files', // The field name expected by the API
          file.path,
        );
        request.files.add(fileStream);
      }

      // Send the request
      var streamedResponse = await request.send();

      print(streamedResponse);

      // Parse the response
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        print("Response Data: ${response.body}");
        Get.snackbar("Success", "Data Uploaded Succcessfully");
        Get.offAllNamed('/');
        print(draftIndex);

        // Call the other controller's method
        if (draftIndex != null) {
          final DraftController draftController = Get.find<DraftController>();
          draftController.deleteDraftByIndex(draftIndex);
          print("Draft deleted successfully");
        }
      } else {
        var errorResponse = await http.Response.fromStream(streamedResponse);
        print("Error: ${streamedResponse.statusCode}, ${errorResponse.body}");
        Get.snackbar("Error", errorResponse.body); // Show detailed error
      }
    } catch (e) {
      print("An error occurred: $e");
    } finally {
      isLoading.value = false;
      print('API work ended');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
