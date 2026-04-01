import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    this.accessToken,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabaseUser(
    User user, {
    String? accessToken,
    String? refreshToken,
  }) =>
      UserModel(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] as String? ?? '',
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  @JsonKey(name: 'access_token')
  final String? accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
