import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String? videoUrl;
  final List<String> attachments;
  final int order;
  final int duration; // in minutes
  final bool isDownloaded;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    this.videoUrl,
    this.attachments = const [],
    required this.order,
    required this.duration,
    this.isDownloaded = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'],
      attachments: List<String>.from(json['attachments'] ?? []),
      order: json['order'] ?? 0,
      duration: json['duration'] ?? 0,
      isDownloaded: json['isDownloaded'] ?? false,
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
      'courseId': courseId,
      'title': title,
      'content': content,
      'videoUrl': videoUrl,
      'attachments': attachments,
      'order': order,
      'duration': duration,
      'isDownloaded': isDownloaded,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LessonModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? content,
    String? videoUrl,
    List<String>? attachments,
    int? order,
    int? duration,
    bool? isDownloaded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      attachments: attachments ?? this.attachments,
      order: order ?? this.order,
      duration: duration ?? this.duration,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
