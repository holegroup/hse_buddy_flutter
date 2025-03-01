import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hole_hse_inspection/controllers/camera_controller.dart';
import 'package:hole_hse_inspection/controllers/draft_controller.dart';
import 'package:hole_hse_inspection/controllers/survey_controller.dart';
import 'package:intl/intl.dart';

class NewReport extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? taskId;
  final String equipmentName;
  final String partNumber;

  NewReport(
      {super.key,
      this.taskId,
      this.latitude,
      this.longitude,
      required this.equipmentName,
      required this.partNumber});

  @override
  State<NewReport> createState() => _NewReportState();
}

class _NewReportState extends State<NewReport> {
  int imgIndex = 0;
  // final TextEditingController equipmentNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  // final TextEditingController partNumberController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int selectedNumber = 10; // Default selected number
// Initialize date with current date and time
  final String date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  final DraftController draftController = Get.put(DraftController());
  final SurveyController surveyController = Get.put(SurveyController());

  void saveDraft() async {
    print("saveDraft() called");
    final draftBox = await Hive.openBox('draftBox');
    var userBox = await Hive.openBox('userBox');
    var userData = userBox.get('userData');

    final draft = {
      'inspectorName': userData['user']['name'],
      'location': locationController.text,
      'date': date,
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'equipmentName': widget.equipmentName,
      'partNumber': widget.partNumber,
      'serialNumber': serialNumberController.text,
      'description': descriptionController.text,
      'maintananceFreq': selectedNumber,
      'images': Get.find<CameraControllerX>()
          .capturedImages
          .map((file) => file.path)
          .toList(),
      'taskId': widget.taskId.toString(),
    };

    try {
      await draftBox.add(draft);
      print("Task ID:---------------------------------------- ${widget.taskId.toString()}");
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(20),
      );
    } finally {
      draftController.loadDrafts();
      Get.snackbar(
        'Draft Saved',
        'Your draft has been saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(20),
      );
      Get.offAllNamed('/');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraControllerX>(
      builder: (controller) {
        return Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.taskId.toString()),
                    const SizedBox(height: 20),
                    const Text(
                      "Inspector Name",
                    ),
                    const Text(
                      "Subhankar Ghosh",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                    Text(
                      "Survey Date",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                    ),
                    const SizedBox(height: 20),
                    // Display multiple captured images
                    if (controller.capturedImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, bottom: 5, right: 5),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  child: Image.file(
                                    File(controller
                                        .capturedImages[imgIndex].path),
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.4,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lat: ${widget.latitude}'),
                                  Text('Long: ${widget.longitude}'),
                                  GestureDetector(
                                    onTap: () {
                                      // Show confirmation dialog before deleting
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Delete Image"),
                                            content: const Text(
                                                "Are you sure you want to delete this image?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Delete the image and close dialog
                                                  controller
                                                      .deleteImage(imgIndex);
                                                  if (imgIndex > 0) {
                                                    setState(() {
                                                      imgIndex = imgIndex - 1;
                                                    });
                                                  }
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Delete",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Row(children: [
                                      const Text("Delete image",
                                          style: TextStyle(color: Colors.red)),
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )
                                    ]),
                                  ),
                                  const SizedBox(height: 50),
                                  SizedBox(
                                    height: 100,
                                    width: MediaQuery.sizeOf(context).width *
                                            0.54 -
                                        16,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          controller.capturedImages.length,
                                      itemBuilder: (context, index) {
                                        final imageFile =
                                            controller.capturedImages[index];
                                        return InkWell(
                                          onTap: () {
                                            // Navigate to ReportPage with all captured images and location
                                            setState(() {
                                              imgIndex = index;
                                            });
                                            print(index);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 5, right: 5),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5)),
                                              child: Image.file(
                                                File(imageFile.path),
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    Text("Equipment Name"),
                    Text(
                      widget.equipmentName,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Part Number"),
                    Text(
                      widget.partNumber,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: "Survey Location",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: serialNumberController,
                      decoration: InputDecoration(
                        labelText: "Serial Number",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 4,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: "Equipment Description",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row(
                    //   children: [
                    //     Text("Maintenence Freq."),
                    //     Expanded(
                    //       child: SizedBox(
                    //         height: 80,
                    //         child: CupertinoPicker(
                    //           backgroundColor: Colors.transparent,
                    //           itemExtent: 40, // Height of each item

                    //           scrollController: FixedExtentScrollController(
                    //               initialItem: selectedNumber),
                    //           onSelectedItemChanged: (int index) {
                    //             setState(() {
                    //               selectedNumber = index;
                    //             });
                    //           },
                    //           children: List<Widget>.generate(
                    //             1000, // Numbers from 0 to 100
                    //             (int index) {
                    //               return Center(
                    //                 child: Text(
                    //                   index.toString(),
                    //                   style: TextStyle(fontSize: 18),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: saveDraft,
                          child: const Text("Save as Draft"),
                        ),
                        Obx(() {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              surveyController.submitReport(
                                equipNameLook: widget.equipmentName,
                                dateManufacture:
                                    date, 
                                partNum: widget.partNumber,
                                serialNum: serialNumberController.text,
                                maintenanceFreq: selectedNumber.toString(),
                                equipDesc: descriptionController.text,
                                location: locationController.text,
                                lat: widget.latitude?.toString() ?? '',
                                long: widget.longitude?.toString() ?? '',
                                files: controller.capturedImages,
                                taskId: widget.taskId.toString(),
                              );
                            },
                            child: surveyController.isLoading == false
                                ? Text("Submit")
                                : SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
