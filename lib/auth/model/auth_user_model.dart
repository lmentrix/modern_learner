import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
  });

  factory AuthUserModel.fromUser(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;

  AuthUserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
