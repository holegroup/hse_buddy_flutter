import 'package:flutter/material.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'package:url_launcher/url_launcher.dart';

class SurveyForm extends StatefulWidget {
  final String taskId;

  const SurveyForm({super.key, required this.taskId});

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  late Future<List<dynamic>> _formData;

  @override
  void initState() {
    super.initState();
    _formData = fetchFormData(widget.taskId);
  }

  Future<List<dynamic>> fetchFormData(String taskId) async {
    final String baseUrl =
        Constants.baseUrl; // Replace with your actual base URL
    final url =
        Uri.parse('$baseUrl/api/forms/get-inspection-by-task?taskId=$taskId');
    final response = await http.get(url);

    print(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data']; // Returning the "data" array
    } else {
      throw Exception('Failed to load form data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<dynamic>>(
          future: _formData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              if (data.isEmpty) {
                return const Center(
                    child: Text('No inspection forms available'));
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['equip_name_look'] ?? 'Unknown Equipment',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Part Number: ${item['part_num'] ?? 'N/A'}"),
                          Text("Serial Number: ${item['serial_num'] ?? 'N/A'}"),
                          Text("Description: ${item['equip_desc'] ?? 'N/A'}"),
                          Text("Location: ${item['location'] ?? 'N/A'}"),
                          const SizedBox(height: 8),
                          if (item['picture'] != null &&
                              item['picture'].isNotEmpty)
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: item['picture'].length,
                                itemBuilder: (context, pictureIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item['picture'][pictureIndex],
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 8),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image,
                                              size: 150);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Manufacture Date: ${DateTime.parse(item['date_manufacture']).toLocal()}",
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_pin, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                  "Lat: ${item['lat']}, Long: ${item['long']}"),
                            ],
                          ),
                          GestureDetector(
                              onTap: () {
                                launchUrl(Uri.parse(
                                    "https://www.google.com/maps/search/?api=1&query=${item['lat']},${item['long']}"));
                              },
                              child: Chip(
                                  label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("See location on Maps"),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.navigation_outlined,
                                    size: 15,
                                  ),
                                ],
                              ))),
                          Row(
                            children: [
                              const Icon(Icons.timelapse, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                  "Maintenance Frequency: ${item['maintenance_freq']} days"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
