import 'dart:io';
import 'package:flutter/material.dart';
import 'package:task_app/models/user_model.dart';

class UserItemWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserItemWidget({Key? key, required this.user, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatar != null
            ? FileImage(File(user.avatar!))
            : null,
        child: user.avatar == null
            ? Text(user.username.substring(0, 1).toUpperCase())
            : null,
      ),
      title: Text(user.username),
      subtitle: Text(user.email),
      onTap: onTap,
    );
  }
}