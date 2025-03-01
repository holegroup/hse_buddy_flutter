import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

class TaskPieChart extends StatefulWidget {
  @override
  _TaskPieChartState createState() => _TaskPieChartState();
}

class _TaskPieChartState extends State<TaskPieChart> {
  Map<String, double> dataMap = {};
  bool isLoading = false;
  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  DateTime? startDate;
  DateTime? endDate;

  bool isVisible = false;

  Future<void> fetchChartData({String? startDate, String? endDate}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final LoginController loginController = Get.put(LoginController());
      String? token = await loginController.getToken();

      var userData = await loginController.getUserData();
      if (userData!['id'] == null) {
        loginController.logout();
      }

      if (token == null) {
        throw Exception("Token is null");
      }

      String baseUrl = Constants.baseUrl;

      String url =
          '$baseUrl/api/tasks/get-task-status-supervisor?supervisorId=${userData['id']}&';
      if (startDate != null || endDate != null) {
        if (startDate != null) url += 'startDate=$startDate&';
        if (endDate != null) url += 'endDate=$endDate';
      }

      print(url);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
      );

      // print(response.body);
      // print(token);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final Map<String, dynamic>? data = responseData['data'];

        if (data == null || data.isEmpty) {
          // Handle null or empty data
          setState(() {
            dataMap = {"No Data": 0}; // Default data for empty response
            isLoading = false;
          });
        } else {
          // Convert the API data to a format suitable for the pie chart
          setState(() {
            dataMap = data.map((key, value) => MapEntry(key, value.toDouble()));
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        dataMap = {"No Data": 0}; // Default data for error case
        isLoading = false;
      });
    }
  }

  void _selectDate(BuildContext context, bool isStartDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: Colors.white70,
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.95,
              height: 150,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime value) {
                  setState(() {
                    if (isStartDate) {
                      startDate = value;
                    } else {
                      endDate = value;
                    }
                  });
                },
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchChartData(
                    startDate: startDate != null
                        ? "${startDate!.toLocal()}".split(' ')[0]
                        : null,
                    endDate: endDate != null
                        ? "${endDate!.toLocal()}".split(' ')[0]
                        : null,
                  );
                },
                child: Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            Text(
              "At a glance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _selectDate(context, true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(1),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Text(
                    startDate == null
                        ? "Select Start Date"
                        : "${startDate!.toLocal()}".split(' ')[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context, false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(1),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Text(
                    endDate == null
                        ? "Select End Date"
                        : "${endDate!.toLocal()}".split(' ')[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    startDate = null;
                    endDate = null;
                    fetchChartData();
                  });
                },
                icon: Icon(Icons.repeat),
              ),
            ],
          ),
        ),
        SizedBox(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : dataMap.isEmpty
                  ? Center(
                      child: Text('No data available'),
                    )
                  : PieChart(
                      dataMap: dataMap,
                      animationDuration: Duration(milliseconds: 800),
                      chartType: ChartType.ring,
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      colorList: colorList,
                      legendOptions: LegendOptions(
                        showLegends: true,
                        legendPosition: LegendPosition.right,
                      ),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValuesInPercentage: false,
                        showChartValues: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 0,
                      ),
                    ),
        ),
      ],
    );
  }
}
