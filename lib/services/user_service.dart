import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // Thêm user mới
  Future<void> createUser(UserModel user) async {
    return await userCollection.doc(user.id).set(user.toMap());
  }

  // Lấy thông tin user theo ID
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await userCollection.doc(id).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy thông tin người dùng: $e");
    }
    return null;
  }

  // Cập nhật thông tin user
  Future<void> updateUser(UserModel user) async {
    await userCollection.doc(user.id).update(user.toMap());
  }

  // Xóa user
  Future<void> deleteUser(String id) async {
    await userCollection.doc(id).delete();
  }
  // Cập nhật thời gian hoạt động gần nhất
  Future<void> updateUserLastActive(String userId) async {
    return await userCollection.doc(userId).update({
      'lastActive': DateTime.now().toIso8601String(),
    });
  }
  // Kiểm tra xem người dùng đã tồn tại chưa
  Future<bool> checkUserExists(String userId) async {
    final doc = await userCollection.doc(userId).get();
    return doc.exists;
  }
  // Lấy danh sách tất cả người dùng
  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await userCollection.get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}