import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int duration; // in minutes
  final int passingScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.questions,
    required this.duration,
    required this.passingScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // Parse questions - handle both List and Map formats
    List<QuizQuestion> questionsList = [];
    final questionsData = json['questions'];
    
    if (questionsData is List) {
      questionsList = questionsData
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    } else if (questionsData is Map) {
      // If questions is a Map with numeric string keys
      final sortedKeys = questionsData.keys.toList()..sort((a, b) {
        final aNum = int.tryParse(a.toString()) ?? 0;
        final bNum = int.tryParse(b.toString()) ?? 0;
        return aNum.compareTo(bNum);
      });
      questionsList = sortedKeys
          .map((key) => QuizQuestion.fromJson(questionsData[key] as Map<String, dynamic>))
          .toList();
    }
    
    return QuizModel(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: questionsList,
      duration: _parseInt(json['duration']) ?? 0,
      passingScore: _parseInt(json['passingScore']) ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'duration': duration,
      'passingScore': passingScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer; // index of correct option
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // Handle options - can be either List or Map with string indices
    List<String> optionsList = [];
    final optionsData = json['options'];
    
    if (optionsData is List) {
      // Normal array
      optionsList = List<String>.from(optionsData);
    } else if (optionsData is Map) {
      // Map with string indices like {"0": "test", "1": "test2"}
      // Sort keys numerically to maintain order
      final sortedKeys = optionsData.keys.toList()..sort((a, b) {
        final aNum = int.tryParse(a.toString()) ?? 0;
        final bNum = int.tryParse(b.toString()) ?? 0;
        return aNum.compareTo(bNum);
      });
      optionsList = sortedKeys.map((key) => optionsData[key].toString()).toList();
    }
    
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: optionsList,
      correctAnswer: _parseIntValue(json['correctAnswer']) ?? 0,
      points: _parseIntValue(json['points']) ?? 1,
    );
  }

  static int? _parseIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'points': points,
    };
  }
}

class QuizResultModel {
  final String id;
  final String quizId;
  final String userId;
  final Map<String, int> answers; // questionId -> selectedOption
  final int score;
  final int totalScore;
  final bool passed;
  final DateTime submittedAt;

  QuizResultModel({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.answers,
    required this.score,
    required this.totalScore,
    required this.passed,
    required this.submittedAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    // Parse answers map with type conversion
    final answersMap = <String, int>{};
    if (json['answers'] != null) {
      (json['answers'] as Map<String, dynamic>).forEach((key, value) {
        answersMap[key] = _parseIntSafe(value) ?? 0;
      });
    }

    return QuizResultModel(
      id: json['id'] ?? '',
      quizId: json['quizId'] ?? '',
      userId: json['userId'] ?? '',
      answers: answersMap,
      score: _parseIntSafe(json['score']) ?? 0,
      totalScore: _parseIntSafe(json['totalScore']) ?? 0,
      passed: json['passed'] ?? false,
      submittedAt: json['submittedAt'] is Timestamp
          ? (json['submittedAt'] as Timestamp).toDate()
          : DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static int? _parseIntSafe(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'answers': answers,
      'score': score,
      'totalScore': totalScore,
      'passed': passed,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  double get percentage => totalScore > 0 ? (score / totalScore) * 100 : 0;
}
