import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final String baseUrl = Constants.baseUrl;

  Future<void> login() async {
    isLoading.value = true;
    final String url = "${baseUrl}/api/users/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      print(response.body);
      final data = jsonDecode(response.body);
      

      if (response.statusCode == 200) {
        if (data['user']["role"] == "inspector" ||
            data['user']["role"] == "supervisor") {
          var userBox = await Hive.openBox('userBox');
          userBox.put('userData',
              data); // Store the complete response data for future access

          // Navigate based on role
          if (data['user']["role"] == "inspector") {
            Get.snackbar("Login Success", "${data['message']}");
            Get.offAllNamed('/');
          } else if (data['user']["role"] == "supervisor") {
            Get.offAllNamed('/supervisor-dashboard');
          }
        } else {
          Get.snackbar("Login Error", "You are not an authorised member");
        }
      } else {
        Get.snackbar("Login Failed", "${data['message']}");
      }
    } catch (e) {
      Get.snackbar("An error occurred", "$e");
      // print("An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    var userBox = await Hive.openBox('userBox');
    await userBox.clear();
    Get.offAllNamed('/login'); 
  }

  Future<String?> getToken() async {
    try {
      var userBox = await Hive.openBox('userBox');
      final userData = userBox.get('userData');
      if (userData != null && userData['token'] != null) {
        return userData['token'];
      }
      return null;
    } catch (e) {
      Get.snackbar("Error", "Failed to retrieve token: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      var userBox = await Hive.openBox('userBox');
      final userData = userBox.get('userData');
      // print('user data: ${userData}');
      if (userData != null) {
        // Return the data in a map
        return {
          'name': userData['user']['name'],
          // 'image': userData['profileImage'],
          'email': userData['user']['email'],
          'role': userData['user']['role'],
          'id': userData['user']['_id'],
        };
      }
      return null;
    } catch (e) {
      Get.snackbar("Error", "Failed to retrieve user data: $e");
      return null;
    }
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
