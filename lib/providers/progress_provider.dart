import 'package:flutter/material.dart';
import '../core/models/progress_model.dart';
import '../core/services/api_service.dart';
import '../core/services/firestore_service.dart';

class ProgressProvider with ChangeNotifier {
  List<ProgressModel> _progressList = [];
  final Map<String, ProgressModel> _courseProgressMap = {};
  bool _isLoading = false;
  String? _error;

  List<ProgressModel> get progressList => _progressList;
  Map<String, ProgressModel> get courseProgressMap => _courseProgressMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch user progress (offline-enabled)
  Future<void> fetchUserProgress(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try API first
      try {
        final response = await ApiService.getProgressByUser(userId);
        _progressList = response.map((json) => ProgressModel.fromJson(json)).toList();
        
        // Build map for quick access
        for (var progress in _progressList) {
          _courseProgressMap[progress.courseId] = progress;
        }
      } catch (e) {
        // Fallback to Firestore with offline support
        final snapshot = await FirestoreService.getProgressByUser(userId);
        _progressList = snapshot.docs.map((doc) => ProgressModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
        
        // Build map for quick access
        for (var progress in _progressList) {
          _courseProgressMap[progress.courseId] = progress;
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

  // Update progress
  Future<bool> updateProgress(String userId, String courseId, String lessonId, bool completed) async {
    try {
      await ApiService.updateProgress({
        'userId': userId,
        'courseId': courseId,
        'lessonId': lessonId,
        'completed': completed,
      });
      
      // Refresh progress
      await fetchUserProgress(userId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Calculate overall progress percentage
  double getOverallProgress() {
    if (_progressList.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (var progress in _progressList) {
      totalProgress += progress.progressPercentage;
    }
    
    return totalProgress / _progressList.length;
  }

  // Get course-specific progress
  ProgressModel? getCourseProgress(String courseId) {
    return _courseProgressMap[courseId];
  }

  double getCourseProgressPercentage(String courseId) {
    final progress = _courseProgressMap[courseId];
    return progress?.progressPercentage ?? 0.0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
