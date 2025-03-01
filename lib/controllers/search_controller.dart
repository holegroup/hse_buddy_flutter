import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:http/http.dart' as http;

class SearchWidgetController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final String baseUrl = Constants.baseUrl;
  var filteredSites = <Object>[].obs;

  int previousTextLength = 0;

  // Add variables to store the selected part details
  var selectedPartName = ''.obs;
  var selectedPartNumber = ''.obs;
  RxBool isVisible = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to changes in the search text field
    searchController.addListener(() {
      search();
    });
  }

  Future<void> search() async {
    print('called search api');

    final String url =
        "${baseUrl}/api/products/search-products?query=${searchController.text}";

    print("search api called");

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the list of parts from the data
        final parts = data['data'] as List;

        // Update filteredSites with part_name and part_number
        filteredSites.value = parts.map((part) {
          final partName = part['part_name'] ?? 'Unknown Name';
          final partNumber = part['part_number'] ?? 'Unknown Number';
          return {partName, partNumber};
        }).toList();
      } else {
        clearSuggestions();
        filteredSites.add({'No Match', ''});
      }
    } catch (e) {
      Get.snackbar("An error occurred", "$e");
    } finally {
      isLoading.value = false;
      print(filteredSites);
    }
  }

  selectSite(int index) {
    print(filteredSites[index]);
    // Get selected part details
    selectedPartName.value = (filteredSites[index] as Set).first.toString();
    selectedPartNumber.value = (filteredSites[index] as Set).last.toString();

    // Update the text in the search controller
    searchController.text = selectedPartName.value;

    isVisible.value = false;

    // Clear suggestions
    clearSuggestions();
  }

  selectSiteAndOpenCamera(int index) {
    print(filteredSites[index]);
    Get.to(() => CameraView(
          equipmentName: (filteredSites[index] as Set).first.toString(),
          partNumber: (filteredSites[index] as Set).last,
        ));
  }

  clearSuggestions() {
    filteredSites.value = [];
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
