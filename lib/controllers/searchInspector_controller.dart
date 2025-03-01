import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:http/http.dart' as http;

class UserSearchWidgetController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final String baseUrl = Constants.baseUrl;

  RxBool isVisible = false.obs;
  var filteredSites = <Object>[].obs;

  int previousTextLength = 0;
  final RxString selectedInspectorEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      search();
    });
  }

  Future<void> search() async {
    final String url =
        "${baseUrl}/api/users/search-users?query=${searchController.text}";

    print(
        "search api called----------------------------------------------------------------");

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the list of parts from the data
        final users = data['data'] as List;

        // Update filteredSites with part_name and part_number
        filteredSites.value = users.map((user) {
          final name = user['name'] ?? 'Unknown Name';
          final email = user['email'] ?? 'Unknown email';
          return {name, email};
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
    // Update the text in the search controller
    searchController.text = (filteredSites[index] as Set).first.toString();

    selectedInspectorEmail.value =
        (filteredSites[index] as Set).last.toString();
    // Clear suggestions
    clearSuggestions();

    isVisible.value = false;
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
