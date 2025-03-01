class Task {
  final String id;
  final String inspectorName;
  final String email;
  final String product;
  final String partNumber;
  final DateTime dueDate;
  final String note;
  final String status;
  final String userId;
  final String supervisorId;
  final List<dynamic> inspectionForms; // Could be a more specific type if known
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v; // __v field
  final bool critical;
  final int? maintenanceFreq; // Nullable
  final bool recurring;


  Task({
    required this.id,
    required this.inspectorName,
    required this.email,
    required this.product,
    required this.partNumber,
    required this.dueDate,
    required this.note,
    required this.status,
    required this.userId,
    required this.supervisorId,
    required this.inspectionForms,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.critical,
    this.maintenanceFreq,
    required this.recurring,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      inspectorName: json['inspector_name'],
      email: json['email'],
      product: json['product'],
      partNumber: json['part_number'],
      dueDate: DateTime.parse(json['due_date']),
      note: json['note'],
      status: json['status'],
      userId: json['userId'],
      supervisorId: json['supervisorId'],
      inspectionForms: json['inspectionForms'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      critical: json['critical'],
      maintenanceFreq: json['maintenance_freq'],
      recurring: json['recurring'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'inspector_name': inspectorName,
      'email': email,
      'product': product,
      'part_number': partNumber,
      'due_date': dueDate.toIso8601String(),
      'note': note,
      'status': status,
      'userId': userId,
      'supervisorId': supervisorId,
      'inspectionForms': inspectionForms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'critical': critical,
      'maintenance_freq': maintenanceFreq,
      'recurring': recurring,
    };
  }
}


class TaskList {
  final int count;
  final List<Task> data;

  TaskList({required this.count, required this.data});

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      count: json['count'],
      data: List<Task>.from(json['data'].map((x) => Task.fromJson(x))),
    );
  }

 Map<String, dynamic> toJson() {
    return {
      'count': count,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}