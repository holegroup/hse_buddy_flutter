import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/draft_controller.dart';
import 'package:hole_hse_inspection/controllers/survey_controller.dart';

// ignore: must_be_immutable
class DraftReport extends StatefulWidget {
  final String? name;
  final String? location;
  final double? lat;
  final double? long;
  final String? equipmentName;
  final String? partNumber;
  final String? serialNumber;
  final String? description;
  final List<String>? images;
  final int draftIndex;
  final String? taskId;
  final int? maintananceFreq;

  DraftReport({
    super.key,
    required this.draftIndex,
    required this.name,
    required this.location,
    required this.lat,
    required this.long,
    required this.images,
    required this.equipmentName,
    required this.partNumber,
    required this.serialNumber,
    required this.description,
    required this.taskId,
    required this.maintananceFreq,
  });

  @override
  State<DraftReport> createState() => _DraftReportState();
}

class _DraftReportState extends State<DraftReport> {
  late TextEditingController descriptionController;
  late TextEditingController partNumberController;
  late TextEditingController locationController;
  late TextEditingController serialNumberController;

  final DraftController draftController = Get.put(DraftController());
  final SurveyController surveyController = Get.put(SurveyController());

  late int selectedNumber; // Default value

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the existing values from the widget
    descriptionController = TextEditingController(text: widget.description);
    locationController = TextEditingController(text: widget.location);
    partNumberController = TextEditingController(text: widget.partNumber);
    serialNumberController = TextEditingController(text: widget.serialNumber);

    // Set selectedNumber to the initial maintenance frequency
    selectedNumber = widget.maintananceFreq ?? 0; // Default to 0 if null
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    descriptionController.dispose();
    locationController.dispose();
    partNumberController.dispose();
    serialNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modify Report"),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.taskId.toString()),
              const Text("Inspector Name"),
              Text(
                widget.name.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(
                  Icons.location_on,
                  size: 35,
                ),
                Column(
                  children: [
                    Text('Lat: ${widget.lat}'),
                    Text('Long: ${widget.long}'),
                  ],
                ),
                const SizedBox(width: 10),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(widget.images![index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Equipment name",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(widget.equipmentName.toString()),
              const SizedBox(height: 10),
              TextFormField(
                controller: partNumberController,
                decoration: InputDecoration(
                  labelText: "Part Number",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              Row(
                children: [
                  const Text("Maintenence Freq."),
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: CupertinoPicker(
                        backgroundColor: Colors.transparent,
                        itemExtent: 40, // Height of each item
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedNumber, // Use selectedNumber
                        ),
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedNumber = index;
                          });
                        },
                        children: List<Widget>.generate(
                          1000, // Numbers from 0 to 1000
                          (int index) {
                            return Center(
                              child: Text(
                                index.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    onPressed: () {
                      draftController.deleteDraftByIndex(widget.draftIndex);
                    },
                    child: const Text("Delete Draft"),
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
                          equipNameLook: widget.equipmentName.toString(),
                          dateManufacture: DateTime.now().toString(),
                          partNum: partNumberController.text,
                          serialNum: serialNumberController.text,
                          maintenanceFreq: selectedNumber.toString(),
                          equipDesc: descriptionController.text,
                          location: locationController.text,
                          lat: widget.lat?.toString() ?? '',
                          long: widget.long?.toString() ?? '',
                          files: widget.images
                                  ?.map((path) => XFile(path))
                                  .toList() ??
                              [],
                          taskId: widget.taskId.toString(),
                          draftIndex: widget.draftIndex,
                        );
                      },
                      child: surveyController.isLoading.value == true
                          ? SizedBox(
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text("Upload Draft"),
                    );
                  })
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
