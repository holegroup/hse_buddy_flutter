import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewListingController extends GetxController {
  String baseUrl = Constants.baseUrl;
  RxBool isLoadingGlobal = false.obs;

  Future<List<dynamic>> getItems() async {
    final String url = "$baseUrl/api/sites/fetch-all-temp-items";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse and return the data
        final data = jsonDecode(response.body);
        print(data);
        return data['data'];
      } else {
        // Handle error
        print("Failed to load items. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle exception
      print("Error occurred: $e");
      return [];
    }
  }

  Future<List<dynamic>> getParts() async {
    final String url = "$baseUrl/api/sites/fetch-all-temp-parts";
    try {
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse and return the data
        final data = jsonDecode(response.body);
        print(data);
        return data['data'];
      } else {
        // Handle error
        print("Failed to load items. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle exception
      print("Error occurred: $e");
      return [];
    } 
  }

  Future<void> itemStatus({
    required String itemId,
    required String status,
  }) async {
    print('Item id - ${itemId}');
    final String url = "$baseUrl/api/sites/temp-item-status-change";
    try {
      isLoadingGlobal.value = true;
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'tempItemId': itemId,
          'status': status,
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Get.snackbar("Success", responseData['message']);
        getItems();
      }
    } catch (e) {
      Get.snackbar("Something went wrong", e.toString());
    }finally {
      isLoadingGlobal.value = false;
    }
  }

  Future<void> partStatus({
    required String partId,
    required String status,
  }) async {
    print('Item id - ${partId}');
    final String url = "$baseUrl/api/sites/temp-part-status-change";
    try {
      isLoadingGlobal.value = true;
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'tempPartId': partId,
          'status': status,
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Get.snackbar("Success", responseData['message']);
        getParts();
      }
    } catch (e) {
      Get.snackbar("Something went wrong", e.toString());
    }finally {
      isLoadingGlobal.value = false;
    }
  }
}
