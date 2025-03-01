import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:hole_hse_inspection/widgets/drawer_button.dart';
import 'package:hole_hse_inspection/widgets/footer.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Get instance of LoginController
  final LoginController loginController = Get.put(LoginController());

  Future<Map<String, dynamic>> getUserData() async {
    // Ensure this function never returns null
    final userData = await loginController.getUserData();
    print(userData);
    return userData ?? {}; // Return an empty map if null
  }

  TextEditingController currentPass = new TextEditingController();

  TextEditingController newPass = new TextEditingController();

  TextEditingController reNewPass = new TextEditingController();

  String alertText = 'Do the instructions';

  Future<void> changePass(
      String userId, String currentPassword, String newPassword) async {
    try {
      String baseUrl = Constants.baseUrl;
      String url = '${baseUrl}/api/users/edit-user';

      // Create the request body
      Map<String, String> body = {
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };

      // Perform the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${loginController.getToken()}', // Assuming you have a method to get the token
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successfully changed password
        Get.snackbar(
          "Success",
          "Password updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Handle errors returned by the API
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to update password.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Handle exceptions (e.g., network issues)
      Get.snackbar(
        "Error",
        "An error occurred. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder<Map<String, dynamic>>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while data is being fetched
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle errors if any
              return Center(child: Text("Error loading user data."));
            } else if (!snapshot.hasData) {
              // Handle case when no data is returned
              return Center(child: Text("No user data found."));
            } else {
              // Data has been successfully loaded
              final data = snapshot.data!;
              return Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            "https://i.pinimg.com/1200x/86/1b/54/861b54e03d4bcc4e2276a1ddf134c687.jpg",
                          ),
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(data['name'] ?? "N/A",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(data['role'] ?? "N/A",
                                style: TextStyle(fontSize: 16)),
                            Text(data['email'] ?? "N/A",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomDrawerButton(
                      centerText: true,
                      backgroundColor: Colors.red.shade600,
                      label: "Log-out",
                      icon: Icons.logout,
                      onPressed: () {
                        loginController.logout();
                      },
                    ),
                    CustomDrawerButton(
                      centerText: true,
                      label: "Update Password",
                      icon: Icons.password,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String alertText = '';
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: Text("Update Password"),
                                  content: SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width - 100,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: currentPass,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              labelText: "Current Password"),
                                        ),
                                        SizedBox(height: 8),
                                        TextField(
                                          controller: newPass,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              labelText: "New Password"),
                                        ),
                                        SizedBox(height: 8),
                                        TextField(
                                          controller: reNewPass,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              labelText:
                                                  "Confirm New Password"),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          alertText,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Validate if the new password and confirm password fields match
                                        if (newPass.text.isEmpty ||
                                            reNewPass.text.isEmpty ||
                                            currentPass.text.isEmpty) {
                                          setState(() {
                                            alertText =
                                                "All fields are required";
                                          });
                                          return;
                                        }
                                        if (newPass.text != reNewPass.text) {
                                          setState(() {
                                            alertText =
                                                "New password and confirm password do not match";
                                          });
                                          return;
                                        }
                                        if (newPass.text.length < 6) {
                                          setState(() {
                                            alertText =
                                                "Password must be at least 6 characters long";
                                          });
                                          return;
                                        }

                                        // Call the changePass function if validation passes
                                        changePass(data['id'], currentPass.text,
                                            newPass.text);
                                        Navigator.of(context)
                                            .pop(); // Close the dialog after submission
                                      },
                                      child: Text("Update"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
          height: 120,
          width: MediaQuery.sizeOf(context).width - 20,
          child: AppFooter()),
    );
  }
}
