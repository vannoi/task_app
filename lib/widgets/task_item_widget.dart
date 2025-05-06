import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/task_form_screen.dart';
import 'package:task_app/services/task_service.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskItemWidget({Key? key, required this.task, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Trạng thái: ${task.status}"),
            Text("Độ ưu tiên: ${task.priority}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle, color: task.completed ? Colors.green : Colors.grey),
              onPressed: () async {
                try {
                  // Tạo một bản sao của task với trạng thái hoàn thành
                  final updatedTask = TaskModel(
                    id: task.id,
                    title: task.title,
                    description: task.description,
                    status: task.status,
                    priority: task.priority,
                    dueDate: task.dueDate,
                    createdAt: task.createdAt,
                    updatedAt: DateTime.now(),
                    createdBy: task.createdBy,
                    completed: !task.completed, // Đảo ngược trạng thái hoàn thành
                  );

                  // Cập nhật task trong Firestore
                  await TaskService().updateTask(updatedTask);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cập nhật trạng thái hoàn thành thành công!")),
                  );
                } catch (e) {
                  // Hiển thị thông báo lỗi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cập nhật trạng thái thất bại: $e")),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskFormScreen(userId: task.createdBy, task: task),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Xác nhận xóa"),
                    content: Text("Bạn có chắc chắn muốn xóa công việc này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Xóa"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    // Xóa công việc khỏi Firestore
                    await TaskService().deleteTask(task.id);

                    // Hiển thị thông báo thành công trước khi đóng hộp thoại
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Xóa công việc thành công!"),
                          backgroundColor: Colors.green,
                      ),
                    );
                    
                  } catch (e) {
                    // Hiển thị thông báo lỗi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Xóa công việc thất bại: $e"),
                          backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}