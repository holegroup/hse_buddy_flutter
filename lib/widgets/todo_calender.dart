import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoCalendar extends StatefulWidget {
  TodoCalendar({super.key});

  @override
  State<TodoCalendar> createState() => _TodoCalendarState();
}

class _TodoCalendarState extends State<TodoCalendar> {
  LoginController loginController = Get.put(LoginController());

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Map to store the status for each date
  final Map<DateTime, String> _dateStatusMap = {};

  // Colors corresponding to statuses
  final Map<String, Color> _statusColors = {
    "Overdue": Colors.red,
    "Pending": Colors.blue,
    "Due Soon": Colors.orange,
  };

  bool _isLoading = true; // Loading state for the API call

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  String baseUrl = Constants.baseUrl;
  var token;

  void fetchToken() async {
    token = await loginController.getToken();
    print('User token: $token');
    if (token != null) {
      _fetchData(); // Fetch data from the API after the token is loaded
    } else {
      setState(() {
        _isLoading = false; // Stop loading if the token cannot be fetched
      });
    }
  }

  Future<void> _fetchData() async {
    String apiUrl = "${baseUrl}/api/tasks/get-task-date-status";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print(token);
      print(response.body);
      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> parsedJson = json.decode(response.body);
        List<String> data = List<String>.from(parsedJson["data"]);

        // Populate the _dateStatusMap
        for (String entry in data) {
          List<String> parts = entry.split(": ");
          DateTime date = DateTime.parse(parts[0].replaceAll(".", "-"));
          String status = parts[1];

          DateTime normalizedDate = DateTime(date.year, date.month, date.day);
          _dateStatusMap[normalizedDate] = status;
        }

        setState(() {
          _isLoading = false; // Data loaded
        });
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.twoWeeks,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.indigo,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
            child: Text(
              day.day.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Text(
              day.day.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          DateTime normalizedDay = DateTime(day.year, day.month, day.day);

          if (_dateStatusMap.containsKey(normalizedDay)) {
            String status = _dateStatusMap[normalizedDay]!;
            Color highlightColor = _statusColors[status] ?? Colors.grey;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day.day.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Center(
                    child: Text(
                      status,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }
          return null;
        },
      ),
    );
  }
}
