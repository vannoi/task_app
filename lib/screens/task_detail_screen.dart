import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/services/task_service.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết Công việc"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tiêu đề: ${task.title}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Mô tả: ${task.description}"),
              SizedBox(height: 8),
              Text("Trạng thái: ${task.status}"),
              SizedBox(height: 8),
              Text("Độ ưu tiên: ${_getPriorityText(task.priority)}"),
              SizedBox(height: 8),
              Text("Hạn hoàn thành: ${task.dueDate != null ? _formatDate(task.dueDate!) : "Chưa đặt"}"),
              SizedBox(height: 8),
              Text("Thời gian tạo: ${_formatDate(task.createdAt)}"),
              SizedBox(height: 8),
              Text("Thời gian cập nhật: ${_formatDate(task.updatedAt)}"),
              SizedBox(height: 8),
              Text("Người được giao: ${task.assignedTo ?? "Chưa gán"}"),
              SizedBox(height: 8),
              Text("Phân loại: ${task.category ?? "Không có"}"),
              SizedBox(height: 8),
              Text("Hoàn thành: ${task.completed ? "Đã hoàn thành" : "Chưa hoàn thành"}"),
              SizedBox(height: 16),
              if (task.attachments != null && task.attachments!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tệp đính kèm:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...task.attachments!.map((attachment) => ListTile(
                          leading: Icon(Icons.attach_file),
                          title: Text(attachment.split('/').last),
                          onTap: () {
                            // Xử lý mở tệp đính kèm
                          },
                        )),
                  ],
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Hiển thị danh sách trạng thái để người dùng chọn
                  final newStatus = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Cập nhật trạng thái"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ["To do", "In progress", "Done", "Cancelled"]
                            .map((status) => ListTile(
                                  title: Text(status),
                                  onTap: () {
                                    Navigator.pop(context, status);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  );

                  // Nếu người dùng chọn trạng thái mới
                  if (newStatus != null && newStatus != task.status) {
                    try {
                      // Tạo một bản sao của task với trạng thái mới
                      final updatedTask = TaskModel(
                        id: task.id,
                        title: task.title,
                        description: task.description,
                        status: newStatus,
                        priority: task.priority,
                        dueDate: task.dueDate,
                        createdAt: task.createdAt,
                        updatedAt: DateTime.now(),
                        createdBy: task.createdBy,
                        assignedTo: task.assignedTo,
                        category: task.category,
                        attachments: task.attachments,
                        completed: newStatus == "Done",
                      );

                      // Cập nhật task trong Firestore
                      await TaskService().updateTask(updatedTask);

                      // Hiển thị thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cập nhật trạng thái thành công!")),
                      );

                      // Cập nhật giao diện
                      Navigator.pop(context);
                    } catch (e) {
                      // Hiển thị thông báo lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cập nhật trạng thái thất bại: $e")),
                      );
                    }
                  }
                },
                child: Text("Cập nhật trạng thái"),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return "Thấp";
      case 2:
        return "Trung bình";
      case 3:
        return "Cao";
      default:
        return "Không xác định";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}