import 'package:flutter/foundation.dart';
import '../core/services/firestore_service.dart';
import '../core/models/course_model.dart';

class StudentProvider with ChangeNotifier {
  int _enrolledCoursesCount = 0;
  int _completedLessonsCount = 0;
  int _totalQuizzesTaken = 0;
  double _averageScore = 0.0;
  List<CourseModel> _enrolledCourses = [];
  bool _isLoading = false;

  int get enrolledCoursesCount => _enrolledCoursesCount;
  int get completedLessonsCount => _completedLessonsCount;
  int get totalQuizzesTaken => _totalQuizzesTaken;
  double get averageScore => _averageScore;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  bool get isLoading => _isLoading;

  // Fetch student statistics
  Future<void> fetchStudentStatistics(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user data
      final userDoc = await FirestoreService.getUser(userId);
      if (!userDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final enrolledCourseIds = List<String>.from(userData['enrolledCourses'] ?? []);
      _enrolledCoursesCount = enrolledCourseIds.length;

      // Get enrolled courses details
      if (enrolledCourseIds.isNotEmpty) {
        final coursesSnapshot = await FirestoreService.getCourses();
        _enrolledCourses = coursesSnapshot.docs
            .where((doc) => enrolledCourseIds.contains(doc.id))
            .map((doc) => CourseModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList();
      } else {
        _enrolledCourses = [];
      }

      // Get progress data
      final progressSnapshot = await FirestoreService.getProgressByUser(userId);
      _completedLessonsCount = progressSnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['completed'] == true;
          })
          .length;

      // Get quiz results
      final quizResultsSnapshot = await FirestoreService.getQuizResultsByUser(userId);
      _totalQuizzesTaken = quizResultsSnapshot.docs.length;

      // Calculate average score
      if (_totalQuizzesTaken > 0) {
        double totalScore = 0;
        for (var doc in quizResultsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalScore += (data['score'] ?? 0.0) as num;
        }
        _averageScore = totalScore / _totalQuizzesTaken;
      } else {
        _averageScore = 0.0;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching student statistics: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to real-time updates for enrolled courses
  void listenToEnrolledCourses(String userId) {
    FirestoreService.getProgressByUserStream(userId).listen((snapshot) {
      _completedLessonsCount = snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['completed'] == true;
          })
          .length;
      notifyListeners();
    });
  }

  // Listen to real-time updates for quiz results
  void listenToQuizResults(String userId) {
    FirestoreService.getQuizResultsByUserStream(userId).listen((snapshot) {
      _totalQuizzesTaken = snapshot.docs.length;

      // Calculate average score
      if (_totalQuizzesTaken > 0) {
        double totalScore = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalScore += (data['score'] ?? 0.0) as num;
        }
        _averageScore = totalScore / _totalQuizzesTaken;
      } else {
        _averageScore = 0.0;
      }
      notifyListeners();
    });
  }

  // Start all real-time listeners
  void startRealtimeUpdates(String userId) {
    listenToEnrolledCourses(userId);
    listenToQuizResults(userId);
  }

  // Clear data on logout
  void clear() {
    _enrolledCoursesCount = 0;
    _completedLessonsCount = 0;
    _totalQuizzesTaken = 0;
    _averageScore = 0.0;
    _enrolledCourses = [];
    _isLoading = false;
    notifyListeners();
  }
}
