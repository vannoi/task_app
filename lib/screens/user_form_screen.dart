import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_app/models/user_model.dart';
import 'package:task_app/services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel user;

  const UserFormScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  File? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedAvatar = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModel(
        id: widget.user.id,
        username: _usernameController.text,
        email: widget.user.email, // Không thay đổi
        avatar: _selectedAvatar?.path ?? widget.user.avatar, // Cập nhật avatar nếu có
        createdAt: widget.user.createdAt, // Không thay đổi
        lastActive: widget.user.lastActive, // Không thay đổi
        isAdmin: widget.user.isAdmin, // Không thay đổi
      );

      final userService = UserService();
      await userService.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thông tin người dùng thành công!")),
      );

      Navigator.pop(context, updatedUser); // Trả về thông tin người dùng đã cập nhật
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật thông tin"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child:Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _selectedAvatar != null
                            ? FileImage(_selectedAvatar!)
                            : (widget.user.avatar != null
                            ? FileImage(File(widget.user.avatar!))
                            : null),
                        child: _selectedAvatar == null && widget.user.avatar == null
                            ? Icon(Icons.person, size: 40, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                  // child: CircleAvatar(
                  //   radius: 60,
                  //   backgroundColor: Colors.blue.shade100,
                  //   backgroundImage: _selectedAvatar != null
                  //       ? FileImage(_selectedAvatar!)
                  //       : (widget.user.avatar != null
                  //           ? FileImage(File(widget.user.avatar!))
                  //           : null),
                  //   child: _selectedAvatar == null && widget.user.avatar == null
                  //       ? Icon(Icons.person, size: 40, color: Colors.grey)
                  //       : null,
                  // ),

                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Họ và tên không được để trống";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text("Cập nhật"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}