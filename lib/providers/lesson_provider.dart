import 'package:flutter/material.dart';
import '../core/models/lesson_model.dart';
import '../core/services/api_service.dart';
import '../core/services/firestore_service.dart';

class LessonProvider with ChangeNotifier {
  final List<LessonModel> _lessons = [];
  List<LessonModel> _courseLessons = [];
  LessonModel? _currentLesson;
  bool _isLoading = false;
  String? _error;

  List<LessonModel> get lessons => _lessons;
  List<LessonModel> get courseLessons => _courseLessons;
  LessonModel? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch lessons by course ID (offline-enabled)
  Future<void> fetchLessonsByCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from API first
      try {
        final response = await ApiService.getLessonsByCourse(courseId);
        _courseLessons = response.map((json) => LessonModel.fromJson(json)).toList();
      } catch (e) {
        // If API fails, try Firestore with offline support
        final snapshot = await FirestoreService.getLessonsByCourse(courseId);
        _courseLessons = snapshot.docs.map((doc) => LessonModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get lesson by ID (offline-enabled)
  Future<void> fetchLessonById(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from API first
      try {
        final response = await ApiService.getLesson(lessonId);
        _currentLesson = LessonModel.fromJson(response);
      } catch (e) {
        // If API fails, try Firestore with offline support
        final doc = await FirestoreService.getLesson(lessonId);
        if (doc.exists) {
          _currentLesson = LessonModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create lesson (Admin only)
  Future<bool> createLesson(LessonModel lesson) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createLesson(lesson.toJson());
      final createdLesson = LessonModel.fromJson(response);
      _lessons.add(createdLesson);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update lesson (Admin only)
  Future<bool> updateLesson(String lessonId, LessonModel lesson) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateLesson(lessonId, lesson.toJson());
      final updatedLesson = LessonModel.fromJson(response);
      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        _lessons[index] = updatedLesson;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete lesson (Admin only)
  Future<bool> deleteLesson(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteLesson(lessonId);
      _lessons.removeWhere((l) => l.id == lessonId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
