import 'package:flutter/material.dart';
import '../core/models/quiz_model.dart';
import '../core/services/api_service.dart';
import '../core/services/firestore_service.dart';
import '../core/constants/api_endpoints.dart';

class QuizProvider with ChangeNotifier {
  final List<QuizModel> _quizzes = [];
  List<QuizModel> _lessonQuizzes = [];
  QuizModel? _currentQuiz;
  List<QuizResultModel> _quizResults = [];
  bool _isLoading = false;
  String? _error;

  List<QuizModel> get quizzes => _quizzes;
  List<QuizModel> get lessonQuizzes => _lessonQuizzes;
  QuizModel? get currentQuiz => _currentQuiz;
  List<QuizResultModel> get quizResults => _quizResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch quizzes by lesson ID
  Future<void> fetchQuizzesByLesson(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getQuizzesByLesson(lessonId);
      _lessonQuizzes = response.map((json) => QuizModel.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get quiz by ID
  Future<void> fetchQuizById(String quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getQuiz(quizId);
      _currentQuiz = QuizModel.fromJson(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit quiz (online only)
  Future<QuizResultModel?> submitQuiz(String quizId, Map<String, dynamic> answers) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.submitQuiz(quizId, answers);
      final result = QuizResultModel.fromJson(response);
      _quizResults.insert(0, result);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Fetch quiz results for a user (offline-enabled)
  Future<void> fetchQuizResults(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try API first
      try {
        final response = await ApiService.get(ApiEndpoints.quizResults(userId));
        _quizResults = (response.data['results'] as List).map((json) => QuizResultModel.fromJson(json)).toList();
      } catch (e) {
        // Fallback to Firestore with offline support
        final snapshot = await FirestoreService.getQuizResultsByUser(userId);
        _quizResults = snapshot.docs.map((doc) => QuizResultModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create quiz (Admin only)
  Future<bool> createQuiz(QuizModel quiz) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createQuiz(quiz.toJson());
      final createdQuiz = QuizModel.fromJson(response);
      _quizzes.add(createdQuiz);
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

  // Update quiz (Admin only)
  Future<bool> updateQuiz(String quizId, QuizModel quiz) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateQuiz(quizId, quiz.toJson());
      final updatedQuiz = QuizModel.fromJson(response);
      final index = _quizzes.indexWhere((q) => q.id == quizId);
      if (index != -1) {
        _quizzes[index] = updatedQuiz;
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

  // Delete quiz (Admin only)
  Future<bool> deleteQuiz(String quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteQuiz(quizId);
      _quizzes.removeWhere((q) => q.id == quizId);
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
