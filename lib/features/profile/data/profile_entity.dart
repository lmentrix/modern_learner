import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  final String displayName;
  final String email;
  final String? avatarUrl;

  ProfileEntity copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [displayName, email, avatarUrl];
}
