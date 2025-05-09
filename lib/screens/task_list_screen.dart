import 'package:flutter/material.dart';
import 'package:task_app/screens/task_form_screen.dart';
import 'package:task_app/screens/task_detail_screen.dart';
import 'package:task_app/screens/user_list_screen.dart';
import 'package:task_app/services/auth_service.dart';
import 'package:task_app/widgets/task_item_widget.dart';
import 'package:task_app/services/task_service.dart';
import 'package:task_app/models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  final String userId;

  const TaskListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _searchQuery = ""; // Biến lưu từ khóa tìm kiếm
  String _filterStatus = "Tất cả"; // Biến lưu trạng thái lọc

  int _selectedIndex = 0; // Mặc định là trang "Task"

  void _onItemTapped(int index) {
    if (index == 0) {
      // Nếu nhấn vào "Task", không làm gì vì đang ở trang này
      return;
    } else if (index == 1) {
      // Nếu nhấn vào "Tài khoản", chuyển sang trang user_list_screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách Công việc"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: TaskSearchDelegate(widget.userId),
              );
              if (result != null) {
                setState(() {
                  _searchQuery = result;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "Tất cả", child: Text("Tất cả")),
              PopupMenuItem(value: "To do", child: Text("To do")),
              PopupMenuItem(value: "In progress", child: Text("In progress")),
              PopupMenuItem(value: "Done", child: Text("Done")),
              PopupMenuItem(value: "Cancelled", child: Text("Cancelled")),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService().getTasksByUser(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có công việc nào."));
          }
          
          final tasks = snapshot.data!;
          debugPrint("Danh sách công việc: ${tasks.map((e) => e.title).toList()}");
          final uniqueTasks = tasks.toSet().toList()
              .where((task) =>
                  (_filterStatus == "Tất cả" || task.status == _filterStatus) &&
                  task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          return ListView.builder(
            itemCount: uniqueTasks.length,
            itemBuilder: (context, index) {
              final task = uniqueTasks [index];
              return TaskItemWidget(
                task: task,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(userId: widget.userId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(

            icon: Icon(Icons.flash_on),
            label: 'Task',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài khoản',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),


    );
  }
}

class TaskSearchDelegate extends SearchDelegate<String> {
  final String userId;

  TaskSearchDelegate(this.userId);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: TaskService().getTasksByUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Không có công việc nào."));
        }
        final tasks = snapshot.data!;
         debugPrint("Danh sách công việc: ${tasks.map((e) => e.title).toList()}");

      // Loại bỏ công việc trùng lặp
        final uniqueTasks = tasks.toSet().toList()
            .where((task) =>
                task.title.toLowerCase().contains(query.toLowerCase()) ||
                task.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return ListView.builder(
          itemCount: uniqueTasks.length,
          itemBuilder: (context, index) {
            final task = uniqueTasks[index];
            return TaskItemWidget(
              task: task,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: task),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(

    );
  }
}