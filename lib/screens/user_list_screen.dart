import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_app/screens/task_list_screen.dart';
import 'package:task_app/screens/user_form_screen.dart';
import 'package:task_app/services/user_service.dart';
import 'package:task_app/models/user_model.dart';
import 'package:task_app/services/auth_service.dart';
import 'package:task_app/screens/login.dart';


  class UserListScreen extends StatefulWidget {
    
    const UserListScreen({Key? key}) : super(key: key);
    

    @override
    _UserListScreenState createState() => _UserListScreenState();
  }
  

  class _UserListScreenState extends State<UserListScreen> {
    int _selectedIndex = 1; // Mặc định là trang "Tài khoản"
     UserModel? _user; // Biến lưu thông tin người dùng
  
   @override
  void initState() {
    super.initState();
    _fetchCurrentUser(); // Lấy dữ liệu người dùng khi màn hình được khởi tạo
  }

  Future<void> _fetchCurrentUser() async {
    final authMethods = AuthMethods();
    final currentUser = await authMethods.getCurrentUser();

    if (currentUser != null) {
      final userService = UserService();
      final userData = await userService.getUserById(currentUser.uid);

      if (userData != null) {
        setState(() {
          _user = userData; // Gán dữ liệu người dùng vào biến _user
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể lấy thông tin người dùng hiện tại.")),
      );
    }
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      // Nếu nhấn vào "Task", chuyển sang trang task_list_screen
      final authMethods = AuthMethods();
      final user = await authMethods.getCurrentUser(); // Đảm bảo hàm này trả về user hiện tại

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TaskListScreen(userId: user.uid),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể lấy thông tin người dùng hiện tại.")),
        );
      }
    } else if (index == 1) {
      // Nếu nhấn vào "Tài khoản", không làm gì vì đang ở trang này
      return;
    } 
  }
    void _logout() async {
      final authMethods = AuthMethods();
      await authMethods.signOut(context); // Đăng xuất người dùng
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()), // Chuyển về màn hình đăng nhập
        (route) => false,
      );
    }

    @override
    Widget build(BuildContext context) {
      if (_user == null) {
        return Scaffold(

          appBar: AppBar(
            title: Text('Chi tiết người dùng'),
          ),
          body: Center(
            child: CircularProgressIndicator(), // Hiển thị vòng xoay khi đang tải dữ liệu
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Chi tiết người dùng'),
          actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            final updatedUser = await Navigator.push<UserModel>(
              context,
              MaterialPageRoute(
                builder: (context) => UserFormScreen(user: _user!),
              ),
            );

            if (updatedUser != null) {
              setState(() {
                _user = updatedUser; // Cập nhật thông tin người dùng sau khi chỉnh sửa
              });
            }
          },
        ),
      ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị ảnh đại diện hoặc chữ cái đầu tiên của tên
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: _user!.avatar != null
                      ? FileImage(File(_user!.avatar!))
                      : null,
                  child: _user!.avatar == null
                      ? Text(
                          _user!.username.substring(0, 1).toUpperCase(),
                          style: TextStyle(fontSize: 40),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 24),
              // Hiển thị thông tin chi tiết người dùng
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Họ và tên', _user!.username),
                      Divider(),
                      _buildDetailRow('Email', _user!.email),
                      Divider(),
                      _buildDetailRow(
                        'Ngày tạo tài khoản',
                        DateFormat('dd/MM/yyyy').format(_user!.createdAt),
                      ),
                      Divider(),
                      _buildDetailRow(
                        'Hoạt động gần nhất',
                        DateFormat('dd/MM/yyyy').format(_user!.lastActive),
                      ),
                      Divider(),
                      _buildDetailRow(
                        'Quyền',
                        _user!.isAdmin ? 'Admin' : 'Người dùng thường',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _logout(),
                  icon: Icon(Icons.logout),
                  label: Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
              ),
            ],
          ),
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

    Future<List<UserModel>> _fetchUsers() async {
      final userService = UserService();
      final querySnapshot = await userService.userCollection.get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    }
    Widget _buildDetailRow(String label, String value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

  }