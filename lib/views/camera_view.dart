import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/location_controller.dart';
import 'package:hole_hse_inspection/views/new_report.dart';
import '../controllers/camera_controller.dart';

class CameraView extends StatelessWidget {
  CameraView({
    super.key,
    this.equipmentName = 'Unknown Equipment',
    this.partNumber = 'Unknown Part',
    this.taskId,
    this.note = '',
  });

  final String? equipmentName;
  final String? partNumber;
  final String? taskId;
  final String? note;
  final LocationController locationController = Get.put(LocationController());

  Future<void> _showInstruction(
    BuildContext context,
  ) async {
    print("Instruction btn tapped");
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.5),
          title: Text("Instructions"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  this.note.toString(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraControllerX>(
      init: CameraControllerX()..initializeCamera(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: Column(
                children: [
                  if (controller.errorMessage != null)
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            controller.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: controller.initializeCamera,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  else if (controller.controller == null ||
                      !controller.controller!.value.isInitialized)
                    const Text("Initializing camera..."),
                  if (controller.controller != null &&
                      controller.controller!.value.isInitialized)
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: CameraPreview(controller.controller!),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "  Latitude : ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '${locationController.latitude}  ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "  Longitude: ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '${locationController.longitude}  ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.8,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white.withOpacity(
                                      0.5), // Color of the active part of the track
                                  inactiveTrackColor: Colors.grey
                                      .shade800, // Color of the inactive part of the track
                                  trackHeight: 4.0, // Thickness of the track
                                  thumbColor: Colors.white.withOpacity(
                                      0.5), // Color of the thumb (circle)
                                  overlayColor: Colors.white.withOpacity(
                                      0.2), // Color when thumb is pressed
                                  valueIndicatorColor: Colors
                                      .black, // Background color of value indicator
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6), // Size of thumb
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16.0), // Size of overlay
                                  valueIndicatorTextStyle: const TextStyle(
                                    color: Colors
                                        .white, // Text color of value indicator
                                  ),
                                ),
                                child: Slider(
                                  value: controller.currentZoomLevel,
                                  min: 1.0,
                                  max: controller.maxZoomLevel,
                                  onChanged: (zoom) {
                                    controller.setZoomLevel(zoom);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              _showInstruction(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Instruction",
                                  style: TextStyle(
                                      color: Colors.white,
                                      shadows: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 2,
                                            offset: Offset(-1, 1))
                                      ]),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            color: Color(0xFF222222),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: IconButton(
                          onPressed:
                              controller.switchCamera, // Switch camera button
                          icon: const Icon(
                            Icons.flip,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            color: Color(0xFF222222),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: IconButton(
                          onPressed: controller.captureImage,
                          icon: const Icon(
                            Icons.camera,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (controller.capturedImages.isEmpty)
                    Text(
                      "Capture images to see the preview",
                      style: TextStyle(color: Colors.grey),
                    ),
                  if (controller.capturedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.capturedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.capturedImages.length) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(NewReport(
                                  equipmentName: this.equipmentName.toString(),
                                  partNumber: this.partNumber.toString(),
                                  latitude:
                                      locationController.latitude.toDouble(),
                                  longitude:
                                      locationController.longitude.toDouble(),
                                  taskId: this.taskId,
                                ));
                              },
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Add to report",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_right_outlined,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final imageFile = controller.capturedImages[index];
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.black,
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(
                                        File(imageFile.path),
                                        fit: BoxFit.contain,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            controller.deleteImage(index);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: Image.file(
                                File(imageFile.path),
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
