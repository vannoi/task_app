class TaskModel {
  final String id; // Định danh duy nhất
  final String title; // Tiêu đề công việc
  final String description; // Mô tả chi tiết
  final String status; // Trạng thái công việc
  final int priority; // Độ ưu tiên
  final DateTime? dueDate; // Hạn hoàn thành
  final DateTime createdAt; // Thời gian tạo
  final DateTime updatedAt; // Thời gian cập nhật gần nhất
  final String? assignedTo; // ID người được giao
  final String createdBy; // ID người tạo
  final String? category; // Phân loại công việc
  final List<String>? attachments; // Danh sách link tài liệu đính kèm
  final bool completed; // Trạng thái hoàn thành

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachments,
    required this.completed,
  });

  // Chuyển đổi từ Map (Firestore) sang TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      assignedTo: map['assignedTo'],
      createdBy: map['createdBy'],
      category: map['category'],
      attachments: map['attachments'] != null ? List<String>.from(map['attachments']) : null,
      completed: map['completed'],
    );
  }

  // Chuyển đổi từ TaskModel sang Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'category': category,
      'attachments': attachments,
      'completed': completed,
    };
  }
}