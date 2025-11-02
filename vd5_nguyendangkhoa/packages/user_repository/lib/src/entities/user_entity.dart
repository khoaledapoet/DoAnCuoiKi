class MyUserEntity {
  String userId;
  String email;
  String role;
  String name;
  bool hasActiveCart;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
    required this.role,
  });

  Map<String, Object?> toDocument() {
    return {
      'userID': userId,
      'email': email,
      'name': name,
      'role': role,
      'hasActiveCart': hasActiveCart,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'] ?? doc['userID'] ?? '', // Thử cả 2 field name
      email: doc['email'] ?? '',
      name: doc['name'] ?? '',
      role: doc['role'] ?? 'user', // Giá trị mặc định là 'user'
      hasActiveCart: doc['hasActiveCart'] ?? false,
    );
  }
}
