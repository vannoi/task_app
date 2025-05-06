class UserModel {
  final String id; // Định danh duy nhất của người dùng
  final String username; // Tên đăng nhập
  final String email; // Email người dùng
  final String? avatar; // URL avatar (có thể null)
  final DateTime createdAt; // Thời gian tạo tài khoản
  final DateTime lastActive; // Thời gian hoạt động gần nhất
  final bool isAdmin; // Xác định quyền Admin (true: Admin, false: Người dùng thường)

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    this.isAdmin = false, // Mặc định là người dùng thường
  });

  // Chuyển đổi từ Map (Firestore) sang UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      isAdmin: map['isAdmin'] ?? false, // Mặc định là false nếu không có trường này
    );
  }

  // Chuyển đổi từ UserModel sang Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isAdmin': isAdmin, // Thêm trường isAdmin
    };
  }
}