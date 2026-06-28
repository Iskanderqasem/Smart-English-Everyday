import 'package:equatable/equatable.dart';

class ProgressModel extends Equatable {
  final String userId;
  final String cefrLevel;
  final double? ieltsEstimate;
  final int? toeflEstimate;
  final int streakDays;
  final int totalXp;
  final int totalMinutes;
  final int wordsLearned;
  final int lessonsCompleted;
  final double overallAccuracy;
  final Map<String, SkillProgress> skills;
  final List<WeeklyProgress> weeklyData;
  final List<StreakDay> streakCalendar;
  final List<Achievement> achievements;
  final DateTime updatedAt;

  const ProgressModel({
    required this.userId,
    required this.cefrLevel,
    this.ieltsEstimate,
    this.toeflEstimate,
    required this.streakDays,
    required this.totalXp,
    required this.totalMinutes,
    required this.wordsLearned,
    required this.lessonsCompleted,
    required this.overallAccuracy,
    required this.skills,
    required this.weeklyData,
    required this.streakCalendar,
    required this.achievements,
    required this.updatedAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      userId: json['user_id'] as String,
      cefrLevel: json['cefr_level'] as String? ?? 'A1',
      ieltsEstimate: (json['ielts_estimate'] as num?)?.toDouble(),
      toeflEstimate: json['toefl_estimate'] as int?,
      streakDays: json['streak_days'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      wordsLearned: json['words_learned'] as int? ?? 0,
      lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      overallAccuracy: (json['overall_accuracy'] as num?)?.toDouble() ?? 0.0,
      skills: (json['skills'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, SkillProgress.fromJson(v as Map<String, dynamic>)),
      ),
      weeklyData: (json['weekly_data'] as List? ?? [])
          .map((e) => WeeklyProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      streakCalendar: (json['streak_calendar'] as List? ?? [])
          .map((e) => StreakDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List? ?? [])
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'cefr_level': cefrLevel,
        'ielts_estimate': ieltsEstimate,
        'toefl_estimate': toeflEstimate,
        'streak_days': streakDays,
        'total_xp': totalXp,
        'total_minutes': totalMinutes,
        'words_learned': wordsLearned,
        'lessons_completed': lessonsCompleted,
        'overall_accuracy': overallAccuracy,
        'skills': skills.map((k, v) => MapEntry(k, v.toJson())),
        'weekly_data': weeklyData.map((e) => e.toJson()).toList(),
        'streak_calendar': streakCalendar.map((e) => e.toJson()).toList(),
        'achievements': achievements.map((e) => e.toJson()).toList(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [userId, cefrLevel, streakDays, totalXp, updatedAt];
}

class SkillProgress extends Equatable {
  final String skill;
  final double score;
  final int sessionsCompleted;
  final double accuracy;
  final List<double> recentScores;

  const SkillProgress({
    required this.skill,
    required this.score,
    required this.sessionsCompleted,
    required this.accuracy,
    required this.recentScores,
  });

  factory SkillProgress.fromJson(Map<String, dynamic> json) => SkillProgress(
        skill: json['skill'] as String,
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        sessionsCompleted: json['sessions_completed'] as int? ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        recentScores: (json['recent_scores'] as List? ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'score': score,
        'sessions_completed': sessionsCompleted,
        'accuracy': accuracy,
        'recent_scores': recentScores,
      };

  @override
  List<Object?> get props => [skill, score, sessionsCompleted];
}

class WeeklyProgress extends Equatable {
  final DateTime date;
  final int minutesStudied;
  final int xpEarned;
  final double accuracy;
  final int lessonsCompleted;

  const WeeklyProgress({
    required this.date,
    required this.minutesStudied,
    required this.xpEarned,
    required this.accuracy,
    required this.lessonsCompleted,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) => WeeklyProgress(
        date: DateTime.parse(json['date'] as String),
        minutesStudied: json['minutes_studied'] as int? ?? 0,
        xpEarned: json['xp_earned'] as int? ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'minutes_studied': minutesStudied,
        'xp_earned': xpEarned,
        'accuracy': accuracy,
        'lessons_completed': lessonsCompleted,
      };

  @override
  List<Object?> get props => [date, minutesStudied, xpEarned];
}

class StreakDay extends Equatable {
  final DateTime date;
  final bool isActive;
  final int minutesStudied;

  const StreakDay({
    required this.date,
    required this.isActive,
    required this.minutesStudied,
  });

  factory StreakDay.fromJson(Map<String, dynamic> json) => StreakDay(
        date: DateTime.parse(json['date'] as String),
        isActive: json['is_active'] as bool? ?? false,
        minutesStudied: json['minutes_studied'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'is_active': isActive,
        'minutes_studied': minutesStudied,
      };

  @override
  List<Object?> get props => [date, isActive, minutesStudied];
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime earnedAt;
  final bool isRare;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.earnedAt,
    required this.isRare,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconName: json['icon_name'] as String,
        earnedAt: DateTime.parse(json['earned_at'] as String),
        isRare: json['is_rare'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon_name': iconName,
        'earned_at': earnedAt.toIso8601String(),
        'is_rare': isRare,
      };

  @override
  List<Object?> get props => [id, title, earnedAt];
}
