import 'package:flutter/material.dart';
import 'package:task_app/services/user_service.dart';
import 'package:task_app/models/user_model.dart';
import 'package:task_app/widgets/user_item_widget.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn Người dùng"),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: UserService().getAllUsers(), // Lấy danh sách người dùng
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có người dùng nào."));
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserItemWidget(
                user: user,
                onTap: () {
                  Navigator.pop(context, user); // Trả về email người dùng được chọn
                },
              );
            },
          );
        },
      ),
    );
  }
}