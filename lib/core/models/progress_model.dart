import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final List<String> completedLessons;
  final List<String> completedQuizzes;
  final int totalLessons;
  final int totalQuizzes;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    this.completedLessons = const [],
    this.completedQuizzes = const [],
    required this.totalLessons,
    required this.totalQuizzes,
    this.isCompleted = false,
    this.completedAt,
    required this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      completedQuizzes: List<String>.from(json['completedQuizzes'] ?? []),
      totalLessons: json['totalLessons'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt']))
          : null,
      lastAccessedAt: json['lastAccessedAt'] is Timestamp
          ? (json['lastAccessedAt'] as Timestamp).toDate()
          : DateTime.parse(json['lastAccessedAt'] ?? DateTime.now().toIso8601String()),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'completedLessons': completedLessons,
      'completedQuizzes': completedQuizzes,
      'totalLessons': totalLessons,
      'totalQuizzes': totalQuizzes,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double get progressPercentage {
    final total = totalLessons + totalQuizzes;
    if (total == 0) return 0;
    final completed = completedLessons.length + completedQuizzes.length;
    return (completed / total) * 100;
  }
}
