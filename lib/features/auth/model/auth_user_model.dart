import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory AuthUserModel.fromSupabase(User user) => AuthUserModel(
    id: user.id,
    email: user.email ?? '',
    displayName: user.userMetadata?['display_name'] as String?,
  );

  final String id;
  final String email;
  final String? displayName;
}
