import 'package:equatable/equatable.dart';

enum ProfileRole { normal, vip }

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.role = ProfileRole.normal,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final ProfileRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isVip => role == ProfileRole.vip;

  @override
  List<Object?> get props => [id, email, name, avatarUrl, role, createdAt, updatedAt];
}
