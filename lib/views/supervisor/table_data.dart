import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/table_data_controller.dart';
import 'package:hole_hse_inspection/models/table_data_model.dart';
import 'package:intl/intl.dart';

class TableData extends StatefulWidget {
  const TableData({super.key});

  @override
  State<TableData> createState() => _TableDataState();
}

class _TableDataState extends State<TableData> {
  final TableDataController tableDataController =
      Get.put(TableDataController());

  DateTime? startDate;
  DateTime? endDate;
  Color startDateColor = Colors.black87;
  Color endDateColor = Colors.black87;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          startDateColor = Colors.indigo;
        } else {
          endDate = picked;
          endDateColor = Colors.indigo;
        }
      });
      _filterData(); // Call API immediately after date selection
    }
  }

  void _filterData() {
    if (startDate != null && endDate != null) {
      String formattedStartDate = DateFormat("MM-dd-yyyy").format(startDate!);
      String formattedEndDate = DateFormat("MM-dd-yyyy").format(endDate!);
      tableDataController.getData(
          startDate: formattedStartDate, endDate: formattedEndDate);
    } else if (startDate != null) {
      String formattedStartDate = DateFormat("MM-dd-yyyy").format(startDate!);
      tableDataController.getData(startDate: formattedStartDate);
    } else if (endDate != null) {
      String formattedEndDate = DateFormat("MM-dd-yyyy").format(endDate!);
      tableDataController.getData(endDate: formattedEndDate);
    }
  }

  @override
  void initState() {
    super.initState();
    tableDataController.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${startDate != null ? DateFormat("MM-dd-yyyy").format(startDate!) : "Select start date"} - \n'
          '${endDate != null ? DateFormat("MM-dd-yyyy").format(endDate!) : "Select end date"}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: startDateColor,
            ),
            onPressed: () => _selectDate(context, true),
            tooltip: "Select Start Date",
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: endDateColor,
            ),
            onPressed: () => _selectDate(context, false),
            tooltip: "Select End Date",
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              String formattedStartDate =
                  DateFormat("MM-dd-yyyy").format(startDate!);
              String formattedEndDate =
                  DateFormat("MM-dd-yyyy").format(endDate!);

              tableDataController.downloadCsv(
                  startDate: formattedStartDate, endDate: formattedEndDate);
            },
            tooltip: "Download CSV",
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Obx(() {
          if (tableDataController.isloadingDetails.value) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ));
          }
          if (tableDataController.tasks.isEmpty) {
            return const Center(child: Text("No data available"));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Inspector")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Product")),
                DataColumn(label: Text("Part Number")),
                DataColumn(label: Text("Due Date")),
                // DataColumn(label: Text("Note")),
                DataColumn(label: Text("Status")),
                // DataColumn(label: Text("User ID")),
                // DataColumn(label: Text("Supervisor ID")),
                // DataColumn(label: Text("Inspection Forms")),
                DataColumn(label: Text("Critical")),
                DataColumn(label: Text("Maintenance Frequency")),
                DataColumn(label: Text("Recurring")),
              ],
              rows: tableDataController.tasks.map((Task task) {
                return DataRow(cells: [
                  DataCell(Text(task.inspectorName)),
                  DataCell(Text(task.email)),
                  DataCell(Text(task.product)),
                  DataCell(Text(task.partNumber)),
                  DataCell(Text(task.dueDate.toString())),
                  // DataCell(Text(task.note)),
                  DataCell(Text(task.status)),
                  // DataCell(Text(task.userId)),
                  // DataCell(Text(task.supervisorId)),
                  // DataCell(Text(task.inspectionForms.toString())),
                  DataCell(Text(task.critical.toString())),
                  DataCell(Text(task.maintenanceFreq?.toString() ?? "N/A")),
                  DataCell(Text(task.recurring.toString())),
                ]);
              }).toList(),
            ),
          );
        }),
      ),
    );
  }
}
