import 'package:equatable/equatable.dart';

enum UserRole { normal, vip }

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.role = UserRole.normal,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final UserRole? role;

  bool get isVip => role == UserRole.vip;

  @override
  List<Object?> get props => [id, email, name, avatarUrl, role];
}
