import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/models/user_model.dart';
import 'package:task_app/screens/user_selection_screen.dart';
import 'package:task_app/services/task_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:task_app/services/user_service.dart';

class TaskFormScreen extends StatefulWidget {
  final String userId;
  final TaskModel? task;


  const TaskFormScreen({Key? key, required this.userId, this.task})
      : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();
  String _status = "To do";
  int _priority = 1;
  DateTime? _dueDate; // Biến để lưu ngày đến hạn
  TimeOfDay? _dueTime; // Biến để lưu thời gian đến hạn
  String? _assignedTo; // Biến để lưu người được giao
  List<String> _attachments = []; // Danh sách tài liệu đính kèm
  final TaskService taskService = TaskService();
  List<UserModel> _assignees = []; // Danh sách người dùng được gán



  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate; // Gán ngày đến hạn từ task
      _dueTime = _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : null; // Lấy giờ từ ngày đến hạn
      _assignedToController.text = widget.task!.assignedTo ?? "";
      _attachments = widget.task!.attachments ?? []; // Gán danh sách tệp đính kèm từ task

      // Làm sạch danh sách _assignees
    _assignees = [];

      // Tải danh sách người được giao từ Firestore
    if (widget.task!.assignedTo != null) {
      _assignees = [
        UserModel(
          id: widget.task!.assignedTo!,
          username: widget.task!.assignedTo!, // Tạm thời dùng email làm tên
          email: widget.task!.assignedTo!,
          avatar:  null, // Nếu có avatar, bạn cần tải từ Firestore
          createdAt: DateTime.now(), // Thêm giá trị cho createdAt
          lastActive: DateTime.now(), // Thêm giá trị cho lastActive
        )
      ];
    } else {
    // Nếu là thêm mới, làm sạch danh sách _assignees
        _assignees = [];
      }
     
    }
  }
  // Hàm để chọn tài liệu đính kèm
  void _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.whereType<String>());
      });
    }
  }
// Hàm chọn ngày và giờ đến hạn
  void _pickDueDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _dueDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          _dueTime = selectedTime;
        });
      }
    }
  }
  // Hàm để lưu công việc
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.userId,
         assignedTo: _assignees.isNotEmpty ? _assignees.first.email : null, // Lưu email người được giao
        attachments: _attachments, // Lưu danh sách tệp đính kèm
        
        completed: false, 
      );

      if (widget.task == null) {
        // Kiểm tra xem công việc đã tồn tại chưa trước khi thêm mới
      TaskService().getTasksByUser(widget.userId).first.then((tasks) {
        final isDuplicate = tasks.any((t) => t.title == task.title);
        if (!isDuplicate) {
          TaskService().createTask(task); // Thêm mới công việc
        } else {
          debugPrint("Công việc đã tồn tại, không thêm trùng lặp.");
        }
      });
      } else {
        TaskService().updateTask(task);
      }

      Navigator.pop(context);
    }
  }

  // Phương thức xóa ghi chú
  Future<void> _deleteTask() async {
    if (!mounted || widget.task == null || widget.task!.id == null) {
      debugPrint("Lỗi: Task hoặc ID bị null");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        debugPrint("Đang xóa note ID: ${widget.task!.id}");
        await taskService.deleteTask(widget.task!.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ghi chú đã được xóa thành công")),
        );

        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        debugPrint("Lỗi khi xóa: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi khi xóa ghi chú")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Thêm Công việc" : "Sửa Công việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'Lưu',
            onPressed: _saveTask,
          ),
          if (widget.task != null)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_outlined,
                color: Colors.red,
              ),
              tooltip: 'Xóa',
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: "Tiêu đề *",
                    border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tiêu đề'
                    : null,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: "Mô tả *",
                    border: OutlineInputBorder(),
                      ),
                  validator:
                      (value) =>
                  (value == null || value.isEmpty)
                      ? 'Vui lòng nhập mô tả'
                      : null,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items: ["To do", "In progress", "Done", "Cancelled"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: "Trạng thái *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _priority,
                items: [1, 2, 3]
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text("Ưu tiên $priority"),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: "Độ ưu tiên *",
                  border: OutlineInputBorder(),
                ),
              ),

               const SizedBox(height: 16),
              // Ngày đến hạn
              GestureDetector(
                onTap: _pickDueDateTime, // Gọi hàm chọn ngày
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Ngày đến hạn',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today), // Đặt biểu tượng lịch bên trái
                    ),
                    controller: TextEditingController(
                      text: _dueDate != null
                          ? DateFormat('dd/MM/yyyy, hh:mm a').format(_dueDate!)
                          : DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.now())
                    ),
                    validator: (value) {
                      if (_dueDate == null) {
                        return 'Vui lòng chọn ngày đến hạn';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Divider(),
              SizedBox(height: 16),
              // Tải lên tệp đính kèm
              ListTile(
                title: Text("Tệp đính kèm (${_attachments.length})"),
                trailing: Icon(Icons.attach_file),
                onTap: _pickAttachments,
              ),
              if (_attachments.isNotEmpty)
                Column(
                  children: _attachments
                      .map((file) => ListTile(
                            title: Text(file.split('/').last),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _attachments.remove(file);
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              Divider(),
              SizedBox(height: 16),
                Text(
                    'Chọn Người được giao: ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  Row(
                  children: [
                    _assignees.isNotEmpty
                        ? Row(
                            children: _assignees.map((user) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Tooltip(
                                      message: user.email, // Hiển thị email khi nhấn giữ
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        backgroundImage: user.avatar != null
                                            ? FileImage(File(user.avatar!))
                                            : null,
                                        child: user.avatar == null
                                            ? Text(user.username.substring(0, 1).toUpperCase()) // Chữ cái đầu tiên của tên
                                            : null,
                                      ),
                                    ),
                                    if (widget.userId != null)
                                      FutureBuilder<UserModel?>(
                                        future: UserService().getUserById(widget.userId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return SizedBox.shrink();
                                          }
                                          final currentUser = snapshot.data;
                                          if (currentUser != null ) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _assignees.remove(user); // Xóa người dùng khỏi danh sách
                                                });
                                              },
                                              child: CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.red,
                                                child: Icon(
                                                  Icons.close,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }
                                          return SizedBox.shrink();
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(),
                    GestureDetector(
                      onTap: () async {
                        if (widget.userId == null) return;

                        // Kiểm tra quyền Admin
                        final currentUser = await UserService().getUserById(widget.userId);
                        if (currentUser == null) return;

                        if (currentUser.isAdmin) {
                          // Admin có thể chọn bất kỳ người dùng nào
                          final selectedUser = await Navigator.push<UserModel>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserSelectionScreen(),
                            ),
                          );

                          if (selectedUser != null) {
                            setState(() {
                              _assignees.add(selectedUser); // Thêm người dùng được chọn
                            });
                          }
                        } else {
                          // Người dùng thường chỉ có thể tự gán công việc cho chính họ
                          final selfUser = await UserService().getUserById(widget.userId);
                          if (selfUser != null) {
                            setState(() {
                              _assignees = [selfUser]; // Chỉ gán cho chính họ
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Bạn chỉ có thể gán công việc cho chính mình.")),
                            );
                          }
                        }
                      },
                      // Nút thêm người dùng
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DottedBorder(
                          borderType: BorderType.Circle,
                          radius: const Radius.circular(6),
                          color: Colors.blueGrey,
                          dashPattern: const [6, 3, 6, 3],
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(45)),
                            child: Container(
                              height: 45,
                              width: 45,
                              color: Colors.blueGrey.withOpacity(0.2),
                              child: const Center(
                                  child: Icon(
                                Icons.person_add_alt_1,
                                color: Colors.blueGrey,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}