import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_app/services/user_service.dart';
import '../models/task_model.dart';
import 'package:rxdart/rxdart.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  // Thêm task mới
  Future<void> createTask(TaskModel task) async {
    return await taskCollection.doc(task.id).set(task.toMap());
  }
   // Lấy danh sách công việc theo quyền
    Stream<List<TaskModel>> getTasksByUser(String userId) async* {
      final currentUser = await UserService().getUserById(userId);
      if (currentUser == null) {
        debugPrint("Không tìm thấy người dùng với ID: $userId");
        return;
      }

      if (currentUser.isAdmin) {
        // Admin xem tất cả công việc
        debugPrint("Người dùng là Admin, hiển thị tất cả công việc.");
        yield* taskCollection.snapshots().map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
      } else {
        // Người dùng thường chỉ xem công việc được gán cho họ hoặc do họ tạo
        debugPrint("Người dùng thường, chỉ hiển thị công việc được gán cho họ hoặc do họ tạo.");
        // Truy vấn công việc do họ tạo
        final createdByStream = taskCollection
            .where('createdBy', isEqualTo: userId)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
                .toList());

        // Truy vấn công việc được gán cho họ
        final assignedToStream = taskCollection
            .where('assignedTo', isGreaterThan: userId)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
                .toList());

        // Kết hợp hai luồng dữ liệu
        yield* Rx.combineLatest2<List<TaskModel>, List<TaskModel>, List<TaskModel>>(
          createdByStream,
          assignedToStream,
          (createdByTasks, assignedToTasks) {
            // Loại bỏ các công việc trùng lặp dựa trên ID
            final allTasks = <String, TaskModel>{};
            for (var task in createdByTasks) {
              allTasks[task.id] = task;
            }
            for (var task in assignedToTasks) {
              allTasks[task.id] = task;
            }
            return allTasks.values.toList();
          },
        );
      }
    }

  // Lấy task theo ID
  Future<TaskModel?> getTaskById(String id) async {
    final doc = await taskCollection.doc(id).get();
    if (doc.exists) {
      return TaskModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Cập nhật task
  Future<void> updateTask(TaskModel task) async {
    await taskCollection.doc(task.id).update(task.toMap());
  }

  // Xóa task
  Future<void> deleteTask(String id) async {
    try {
      await taskCollection.doc(id).delete();
    } catch (e) {
      throw Exception("Không thể xóa công việc: $e");
    }
  }
}