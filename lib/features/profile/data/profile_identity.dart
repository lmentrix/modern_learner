class ProfileIdentity {
  const ProfileIdentity({required this.displayName, required this.email});

  final String displayName;
  final String email;

  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  String get username => '@${displayName.toLowerCase().replaceAll(' ', '')}';
}
