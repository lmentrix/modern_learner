import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromIdentity(UserIdentity identity) {
    final data = identity.identityData ?? {};
    return UserModel(
      id: identity.userId,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      createdAt: identity.createdAt != null
          ? DateTime.tryParse(identity.createdAt!)
          : null,
      updatedAt: identity.updatedAt != null
          ? DateTime.tryParse(identity.updatedAt!)
          : null,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
