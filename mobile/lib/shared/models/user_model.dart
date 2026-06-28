import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String country;
  final String englishVariant;
  final String cefrLevel;
  final double? ieltsEstimate;
  final int? toeflEstimate;
  final int streakDays;
  final int totalXp;
  final int dailyGoalMinutes;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPremium;
  final String role;
  final List<String> achievements;
  final Map<String, double> skillScores;
  final String? parentId;
  final List<String> childrenIds;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    required this.country,
    required this.englishVariant,
    required this.cefrLevel,
    this.ieltsEstimate,
    this.toeflEstimate,
    required this.streakDays,
    required this.totalXp,
    required this.dailyGoalMinutes,
    required this.createdAt,
    this.lastLoginAt,
    required this.isEmailVerified,
    required this.isPremium,
    required this.role,
    required this.achievements,
    required this.skillScores,
    this.parentId,
    required this.childrenIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      country: json['country'] as String? ?? 'GB',
      englishVariant: json['english_variant'] as String? ?? 'British English',
      cefrLevel: json['cefr_level'] as String? ?? 'A1',
      ieltsEstimate: (json['ielts_estimate'] as num?)?.toDouble(),
      toeflEstimate: json['toefl_estimate'] as int?,
      streakDays: json['streak_days'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 15,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      role: json['role'] as String? ?? 'student',
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      skillScores: Map<String, double>.from(
        (json['skill_scores'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      parentId: json['parent_id'] as String?,
      childrenIds: List<String>.from(json['children_ids'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'country': country,
      'english_variant': englishVariant,
      'cefr_level': cefrLevel,
      'ielts_estimate': ieltsEstimate,
      'toefl_estimate': toeflEstimate,
      'streak_days': streakDays,
      'total_xp': totalXp,
      'daily_goal_minutes': dailyGoalMinutes,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'is_premium': isPremium,
      'role': role,
      'achievements': achievements,
      'skill_scores': skillScores,
      'parent_id': parentId,
      'children_ids': childrenIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? englishVariant,
    String? cefrLevel,
    double? ieltsEstimate,
    int? toeflEstimate,
    int? streakDays,
    int? totalXp,
    int? dailyGoalMinutes,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPremium,
    String? role,
    List<String>? achievements,
    Map<String, double>? skillScores,
    String? parentId,
    List<String>? childrenIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      englishVariant: englishVariant ?? this.englishVariant,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      ieltsEstimate: ieltsEstimate ?? this.ieltsEstimate,
      toeflEstimate: toeflEstimate ?? this.toeflEstimate,
      streakDays: streakDays ?? this.streakDays,
      totalXp: totalXp ?? this.totalXp,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      role: role ?? this.role,
      achievements: achievements ?? this.achievements,
      skillScores: skillScores ?? this.skillScores,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isParent => role == 'parent';
  bool get isStudent => role == 'student';
  String get firstName => fullName.split(' ').first;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        avatarUrl,
        bio,
        country,
        englishVariant,
        cefrLevel,
        ieltsEstimate,
        toeflEstimate,
        streakDays,
        totalXp,
        dailyGoalMinutes,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        isPremium,
        role,
        achievements,
        skillScores,
        parentId,
        childrenIds,
      ];
}
