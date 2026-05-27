import 'package:modern_learner_production/features/profile/service/profile_service.dart';

class ProfileIdentity {
  const ProfileIdentity({required this.displayName, required this.email});

  final String displayName;
  final String email;

  String get initial => ProfileService().getCurrentUserName().toString();

  String get username => '@${displayName.toLowerCase().replaceAll(' ', '')}';

  String get initialLetter =>
      ProfileService().getCurrentUserName().toString().substring(0, 1);
}
