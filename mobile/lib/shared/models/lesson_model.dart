import 'package:equatable/equatable.dart';

enum LessonType { reading, writing, speaking, listening, grammar, vocabulary, mixed }

enum LessonStatus { locked, available, inProgress, completed }

class LessonModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String level;
  final int levelNumber;
  final LessonType type;
  final LessonStatus status;
  final int durationMinutes;
  final int xpReward;
  final double completionPercentage;
  final String? thumbnailUrl;
  final List<LessonSection> sections;
  final List<LessonExercise> exercises;
  final LessonTest? test;
  final DateTime? completedAt;
  final int orderIndex;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.levelNumber,
    required this.type,
    required this.status,
    required this.durationMinutes,
    required this.xpReward,
    required this.completionPercentage,
    this.thumbnailUrl,
    required this.sections,
    required this.exercises,
    this.test,
    this.completedAt,
    required this.orderIndex,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      levelNumber: json['level_number'] as int,
      type: LessonType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonType.mixed,
      ),
      status: LessonStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LessonStatus.locked,
      ),
      durationMinutes: json['duration_minutes'] as int? ?? 10,
      xpReward: json['xp_reward'] as int? ?? 50,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      sections: (json['sections'] as List? ?? [])
          .map((e) => LessonSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => LessonExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      test: json['test'] != null
          ? LessonTest.fromJson(json['test'] as Map<String, dynamic>)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'level': level,
        'level_number': levelNumber,
        'type': type.name,
        'status': status.name,
        'duration_minutes': durationMinutes,
        'xp_reward': xpReward,
        'completion_percentage': completionPercentage,
        'thumbnail_url': thumbnailUrl,
        'sections': sections.map((e) => e.toJson()).toList(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'test': test?.toJson(),
        'completed_at': completedAt?.toIso8601String(),
        'order_index': orderIndex,
      };

  bool get isLocked => status == LessonStatus.locked;
  bool get isCompleted => status == LessonStatus.completed;
  bool get isAvailable => status == LessonStatus.available || status == LessonStatus.inProgress;

  @override
  List<Object?> get props => [id, title, level, type, status, completionPercentage];
}

class LessonSection extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? audioUrl;
  final String? imageUrl;
  final int orderIndex;

  const LessonSection({
    required this.id,
    required this.title,
    required this.content,
    this.audioUrl,
    this.imageUrl,
    required this.orderIndex,
  });

  factory LessonSection.fromJson(Map<String, dynamic> json) => LessonSection(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        audioUrl: json['audio_url'] as String?,
        imageUrl: json['image_url'] as String?,
        orderIndex: json['order_index'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'audio_url': audioUrl,
        'image_url': imageUrl,
        'order_index': orderIndex,
      };

  @override
  List<Object?> get props => [id, title, content];
}

class LessonExercise extends Equatable {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int orderIndex;

  const LessonExercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.orderIndex,
  });

  factory LessonExercise.fromJson(Map<String, dynamic> json) => LessonExercise(
        id: json['id'] as String,
        type: json['type'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List? ?? []),
        correctAnswer: json['correct_answer'] as String,
        explanation: json['explanation'] as String?,
        orderIndex: json['order_index'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'question': question,
        'options': options,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'order_index': orderIndex,
      };

  @override
  List<Object?> get props => [id, type, question];
}

class LessonTest extends Equatable {
  final String id;
  final List<LessonExercise> questions;
  final int passingScore;
  final int? lastScore;
  final bool isPassed;

  const LessonTest({
    required this.id,
    required this.questions,
    required this.passingScore,
    this.lastScore,
    required this.isPassed,
  });

  factory LessonTest.fromJson(Map<String, dynamic> json) => LessonTest(
        id: json['id'] as String,
        questions: (json['questions'] as List? ?? [])
            .map((e) => LessonExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        passingScore: json['passing_score'] as int? ?? 70,
        lastScore: json['last_score'] as int?,
        isPassed: json['is_passed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'questions': questions.map((e) => e.toJson()).toList(),
        'passing_score': passingScore,
        'last_score': lastScore,
        'is_passed': isPassed,
      };

  @override
  List<Object?> get props => [id, passingScore, lastScore, isPassed];
}
