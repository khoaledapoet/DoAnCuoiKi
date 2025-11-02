// ----- SAO CHÉP VÀ THAY THẾ TOÀN BỘ TỆP my_user.dart -----

import '../entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String role;
  String name;
  bool hasActiveCart;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
    required this.role,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    hasActiveCart: false,
    role: '',
  );

  // ----- PHẦN ĐÃ SỬA LỖI Ở ĐÂY -----
  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,       // <-- Sửa từ '' thành userId
      email: email,       // <-- Sửa từ '' thành email
      role: role,         // <-- Sửa từ '' thành role
      name: name,         // <-- Sửa từ '' thành name
      hasActiveCart: hasActiveCart,
    );
  }
  // ----- KẾT THÚC PHẦN SỬA -----

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      hasActiveCart: entity.hasActiveCart,
      role: entity.role,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $hasActiveCart, $role';
  }
}