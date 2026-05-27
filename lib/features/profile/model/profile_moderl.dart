class ProfileModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role;
  final String? topic;
  final String? targetLanguage;
  final String? proficiencyLevel;
  final String? nativeLanguage;

  ProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    this.topic,
    this.targetLanguage,
    this.proficiencyLevel,
    this.nativeLanguage,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      role: json['role'] as String? ?? 'normal',
      topic: json['topic'] as String?,
      targetLanguage: json['target_language'] as String?,
      proficiencyLevel: json['proficiency_level'] as String?,
      nativeLanguage: json['native_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'role': role,
      'topic': topic,
      'target_language': targetLanguage,
      'proficiency_level': proficiencyLevel,
      'native_language': nativeLanguage,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    String? topic,
    String? targetLanguage,
    String? proficiencyLevel,
    String? nativeLanguage,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      topic: topic ?? this.topic,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
    );
  }
}
