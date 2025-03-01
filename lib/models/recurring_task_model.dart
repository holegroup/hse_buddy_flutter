class RecurringTask {
  final String id;
  final String inspectorName;
  final String email;
  final String product;
  final String partNumber;
  final String dueDate;
  final String note;
  final String status;
  final bool critical;
  final dynamic maintenanceFreq;

  RecurringTask({
    required this.id,
    required this.inspectorName,
    required this.email,
    required this.product,
    required this.partNumber,
    required this.dueDate,
    required this.note,
    required this.status,
    required this.critical,
    required this.maintenanceFreq,
  });

  factory RecurringTask.fromJson(Map<String, dynamic> json) {
    return RecurringTask(
      id: json['_id'],
      inspectorName: json['inspector_name'],
      email: json['email'],
      product: json['product'],
      partNumber: json['part_number'],
      dueDate: json['due_date'],
      note: json['note'],
      status: json['status'],
      critical: json['critical'],
      maintenanceFreq: json['maintenance_freq'],
    );
  }
}
