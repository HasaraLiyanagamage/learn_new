import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final String level; // beginner, intermediate, advanced
  final int duration; // in hours
  final List<String> topics;
  final int enrolledCount;
  final double rating;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.level,
    required this.duration,
    this.topics = const [],
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
      level: json['level'] ?? 'beginner',
      duration: (json['duration'] is int) ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      topics: (json['topics'] is List) ? List<String>.from(json['topics']) : [],
      enrolledCount: (json['enrolledCount'] is int) ? json['enrolledCount'] : int.tryParse(json['enrolledCount']?.toString() ?? '0') ?? 0,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      isPublished: json['isPublished'] ?? true,
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
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'level': level,
      'duration': duration,
      'topics': topics,
      'enrolledCount': enrolledCount,
      'rating': rating,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    String? level,
    int? duration,
    List<String>? topics,
    int? enrolledCount,
    double? rating,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      topics: topics ?? this.topics,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      rating: rating ?? this.rating,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
