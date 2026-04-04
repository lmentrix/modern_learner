import 'package:json_annotation/json_annotation.dart';
import 'package:modern_learner_production/features/profile/domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    super.role = ProfileRole.normal,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
    id: map['id'] as String,
    email: map['email'] as String,
    name: map['name'] as String? ?? '',
    avatarUrl: map['avatar_url'] as String?,
    role: _parseRole(map['role'] as String?),
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : null,
  );

  static ProfileRole _parseRole(String? role) {
    switch (role) {
      case 'vip':
        return ProfileRole.vip;
      case 'normal':
      default:
        return ProfileRole.normal;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar_url': avatarUrl,
    'role': role == ProfileRole.vip ? 'vip' : 'normal',
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  Map<String, dynamic> toUpdateMap() => {
    'name': name,
    // Note: updated_at is handled by the handle_updated_at() trigger
  };

  @override
  String toString() =>
      'ProfileModel(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, role: $role)';
}
