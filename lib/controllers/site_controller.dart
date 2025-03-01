import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SiteController extends GetxController {
  final String baseUrl = Constants.baseUrl;

  var sites = [].obs;
  final RxBool isloadingSite = false.obs;

  var selectedSiteData = {}.obs;
  final RxBool isLoadingSiteDetail = false.obs;
  final RxBool isLoadingGlobal = false.obs;
  final RxMap<String, bool> loadingStates = <String, bool>{}.obs;

  final LoginController loginController = Get.put(LoginController());
  var token;

  @override
  void onInit() {
    super.onInit();
    fetchToken();
  }

  void fetchToken() async {
    token = await loginController.getToken();
    print('User token: $token');
  }

  Future<void> fetchAllSites() async {
    isloadingSite.value = true;
    final String url = "$baseUrl/api/sites/fetch-all-sites";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
        if (responseData['data'] != null) {
          sites.value = responseData['data'];
        } else {
          print("No data field in the response.");
        }
      } else {
        print("Failed to fetch sites. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred while fetching sites: $e");
    } finally {
      isloadingSite.value = false;
    }
  }

  Future<void> fetchSiteById(String siteId) async {
    loadingStates[siteId] = true;
    final String url = "$baseUrl/api/sites/fetch-products/$siteId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          selectedSiteData.value = responseData;
          // print(responseData);
        } else {
          print("No data field in the response for site ID: $siteId");
        }
      } else {
        print("Failed to fetch site data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred while fetching site data: $e");
    } finally {
      loadingStates[siteId] = false;
    }
  }

  Future<void> addNewSite() async {
    Get.bottomSheet(
        enableDrag: true,
        BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Send Request to add a Site"),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'Site Name'),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Address'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'State'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'Country'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'Zip-code'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button 1 press
                              Get.back();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button 2 press
                              Get.back();
                            },
                            child: Text('Done'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Future<void> addNewProduct() async {
    Get.bottomSheet(
        enableDrag: true,
        BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Send Request to add a new Product"),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'Product Name'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button 1 press
                              Get.back();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button 2 press
                              Get.back();
                            },
                            child: Text('Done'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Future<void> addNewPart({
    required String productId,
    required String itemId,
  }) async {
    TextEditingController partNameController = TextEditingController();
    TextEditingController partNumberController = TextEditingController();
    Get.bottomSheet(
        enableDrag: true,
        BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text("Send Request to add Part"),
                  SizedBox(height: 16),
                  TextField(
                    controller: partNameController,
                    decoration: InputDecoration(labelText: 'Part Name'),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: partNumberController,
                    decoration: InputDecoration(labelText: 'Part Number'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button 1 press
                            Get.back();
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate inputs
                            String partName = partNameController.text.trim();
                            String partNumber =
                                partNumberController.text.trim();

                            if (partName.isEmpty || partNumber.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Part Name and Part Number cannot be empty',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            try {
                              isLoadingGlobal.value = true;
                              print(isLoadingGlobal.value);
                              // HTTP PUT request
                              final response = await http.post(
                                Uri.parse(
                                    '${baseUrl}/api/sites/add-parts-items'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer ${token}',
                                },
                                body: jsonEncode({
                                  'productId': productId,
                                  'itemId': itemId,
                                  'part_name': partName,
                                  'part_number': partNumber,
                                }),
                              );

                              if (response.statusCode == 200) {
                                // Success
                                Get.snackbar(
                                  'Success',
                                  'Part added successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                // Handle error
                                Get.snackbar(
                                  'Error',
                                  'Failed to add part. Status code: ${response.statusCode}',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            } catch (e) {
                              // Handle exception
                              Get.snackbar(
                                'Error',
                                'An error occurred: $e',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } finally {
                              // Close the bottom sheet
                              Get.back();
                              print("API task ended");
                              isLoadingGlobal.value = false;
                              print(isLoadingGlobal.value);
                            }
                          },
                          child: Text('Done'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        ));
  }

  Future<void> addNewItem({
    required String SiteId,
    required String productId,
  }) async {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController serialNumberController = TextEditingController();

    // Add observable for loading state
    RxBool isLoading = false.obs;
    RxString message = "".obs;

    Get.bottomSheet(
      enableDrag: true,
      BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
          return Obx(() => Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Send Request to add Item"),
                    SizedBox(height: 16),
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(labelText: 'Item Name'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: serialNumberController,
                      decoration: InputDecoration(labelText: 'Serial Number'),
                    ),
                    SizedBox(height: 16),
                    Text(message.value),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading.value
                                ? null
                                : () async {
                                    String itemName =
                                        itemNameController.text.trim();
                                    String serialNumber =
                                        serialNumberController.text.trim();

                                    if (itemName.isEmpty ||
                                        serialNumber.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Part Name and Part Number cannot be empty',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    isLoading.value = true;

                                    try {
                                      print("API started");
                                      final response = await http.post(
                                        Uri.parse(
                                            '${baseUrl}/api/sites/add-items-site'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer ${token}',
                                        },
                                        body: jsonEncode({
                                          'siteId': SiteId,
                                          'serial_number': serialNumber,
                                          'name': itemName,
                                          'productId': productId,
                                        }),
                                      );
                                      final data = jsonDecode(response.body);

                                      message.value = data['message'];
                                    } catch (e) {
                                      message.value = e.toString();
                                    } finally {
                                      isLoading.value = false;
                                      print("API task ended");
                                      itemNameController.clear();
                                      serialNumberController.clear();
                                    }
                                  },
                            child: isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Done'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
