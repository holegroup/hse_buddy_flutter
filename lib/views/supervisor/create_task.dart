import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:hole_hse_inspection/controllers/searchInspector_controller.dart';
import 'package:hole_hse_inspection/controllers/search_controller.dart';
import 'package:hole_hse_inspection/widgets/search.dart';
import 'package:hole_hse_inspection/widgets/searchInspector.dart';
import 'package:http/http.dart' as http;

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {

  final LoginController loginController = Get.find<LoginController>();

  final SearchWidgetController searchBarController =
      Get.put(SearchWidgetController());

  final UserSearchWidgetController userSearchBarController =
      Get.put(UserSearchWidgetController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _freqController = TextEditingController();


  final String baseUrl = Constants.baseUrl;
  bool isLoading = false;

  final List<bool> _isCriticalPart = <bool>[true, false];

  Future<void> showToken() async {
    String? token = await loginController.getToken();
    print(token);
  }

  Future<void> submitTask() async {
    setState(() {
      isLoading = true; 
    });

    final String apiUrl = "${baseUrl}/api/tasks/create-task";

    final String inspectorName = userSearchBarController.searchController.text;
    final String inspectorEmail = userSearchBarController
        .selectedInspectorEmail.value; 
    final String product = searchBarController.searchController.text;
    final String date = _dateController.text;
    final String note = _noteController.text;

    
    final String selectedPartNumber =
        searchBarController.selectedPartNumber.value;

    try {
      String? token = await loginController.getToken();

      final Map<String, dynamic> requestData = {
        'inspector_name': inspectorName,
        'email': inspectorEmail,
        'product': product,
        'part_number': selectedPartNumber,
        'due_date': date,
        'note': note,
        'critical': _isCriticalPart[1],
        'maintenance_freq': _freqController.text.isNotEmpty && int.parse(_freqController.text) > 0 ? int.parse(_freqController.text) : null,
        'recurring': _freqController.text.isNotEmpty && int.parse(_freqController.text) > 0 ? true : false,
      };

      // print(apiUrl);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token here
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task Created: ${responseData['message']}')),
        );

        _dateController.clear();
        _noteController.clear();
        userSearchBarController.searchController.clear();
        searchBarController.searchController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create task: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    onTap: () {
                      userSearchBarController.isVisible.value = true;
                    },
                    controller: userSearchBarController.searchController,
                    decoration: InputDecoration(
                      labelText: 'Inspector Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    return Text(
                        "Inspector email: ${userSearchBarController.selectedInspectorEmail.value}");
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    onTap: () {
                      searchBarController.isVisible.value = true;
                    },
                    controller: searchBarController.searchController,
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    return Text(
                        "Part Number: ${searchBarController.selectedPartNumber.value}");
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          DateTime selectedDate =
                              DateTime.now(); // Default to current date
                          return Container(
                            height: 250,
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Expanded(
                                  child: CupertinoDatePicker(
                                    initialDateTime: DateTime.now(),
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (DateTime date) {
                                      selectedDate = date;
                                    },
                                  ),
                                ),
                                SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _dateController.text =
                                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('Done'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      } else {
                        // Parse the selected date from the text field
                        DateTime selectedDate = DateTime.parse(value);
                        DateTime today = DateTime.now();
                        if (selectedDate.isBefore(
                            DateTime(today.year, today.month, today.day))) {
                          return 'Date cannot be before today';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < _isCriticalPart.length; i++) {
                          _isCriticalPart[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    selectedBorderColor: _isCriticalPart[0] == false
                        ? Colors.red[700]
                        : Colors.green[700],
                    selectedColor: Colors.white,
                    fillColor: _isCriticalPart[0] == false
                        ? Colors.red[200]
                        : Colors.green[200],
                    color: _isCriticalPart[0] == false
                        ? Colors.red[400]
                        : Colors.green[400],
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 80.0,
                    ),
                    isSelected: _isCriticalPart,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text("Normal Part"),
                            SizedBox(width: 8),
                            Icon(
                              size: 18,
                              Icons.settings,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text("Critical Part"),
                            SizedBox(width: 8),
                            Icon(
                              size: 18,
                              Icons.warning_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        "Select\nFrequency",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(),
                          controller: _freqController,
                          decoration: InputDecoration(
                            labelText: 'Frequency in Days',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            suffixIcon: Icon(Icons.data_exploration_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                submitTask();
                                _dateController.clear();
                                _noteController.clear();
                              }
                            },
                      child: isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Submit'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.8),
                ],
              ),
            ),
          ),
          Obx(() {
            if (searchBarController.isVisible.value == false) {
              return SizedBox();
            } else {
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBox(),
                  ),
                ),
              );
            }
          }),
          Obx(() {
            if (userSearchBarController.isVisible.value == false) {
              return SizedBox();
            } else {
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: UserSearchBox(),
                  ),
                ),
              );
            }
          }),
        ]),
      ),
    );
  }
}
