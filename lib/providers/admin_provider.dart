import 'package:flutter/foundation.dart';
import '../core/services/firestore_service.dart';
import '../core/constants/app_constants.dart';

class AdminProvider with ChangeNotifier {
  int _totalCourses = 0;
  int _totalStudents = 0;
  int _totalLessons = 0;
  int _totalQuizzes = 0;
  bool _isLoading = false;

  int get totalCourses => _totalCourses;
  int get totalStudents => _totalStudents;
  int get totalLessons => _totalLessons;
  int get totalQuizzes => _totalQuizzes;
  bool get isLoading => _isLoading;

  // Fetch all statistics
  Future<void> fetchStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch all counts in parallel
      final results = await Future.wait([
        FirestoreService.getCollectionCount(AppConstants.coursesCollection),
        FirestoreService.getStudentsCount(),
        FirestoreService.getCollectionCount(AppConstants.lessonsCollection),
        FirestoreService.getCollectionCount(AppConstants.quizzesCollection),
      ]);

      _totalCourses = results[0];
      _totalStudents = results[1];
      _totalLessons = results[2];
      _totalQuizzes = results[3];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching statistics: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to real-time updates for courses
  void listenToCoursesCount() {
    FirestoreService.getCoursesStream().listen((snapshot) {
      _totalCourses = snapshot.docs.length;
      notifyListeners();
    });
  }

  // Listen to real-time updates for students
  void listenToStudentsCount() {
    FirestoreService.getAllUsersStream().listen((snapshot) {
      _totalStudents = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'student';
      }).length;
      notifyListeners();
    });
  }

  // Listen to real-time updates for lessons
  void listenToLessonsCount() {
    FirestoreService.getAllLessonsStream().listen((snapshot) {
      _totalLessons = snapshot.docs.length;
      notifyListeners();
    });
  }

  // Listen to real-time updates for quizzes
  void listenToQuizzesCount() {
    FirestoreService.getAllQuizzesStream().listen((snapshot) {
      _totalQuizzes = snapshot.docs.length;
      notifyListeners();
    });
  }

  // Start listening to all real-time updates
  void startRealtimeUpdates() {
    listenToCoursesCount();
    listenToStudentsCount();
    listenToLessonsCount();
    listenToQuizzesCount();
  }
}
