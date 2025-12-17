import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/models/course_model.dart';
import '../core/services/firestore_service.dart';

class CourseProvider with ChangeNotifier {
  List<CourseModel> _courses = [];
  List<CourseModel> _enrolledCourses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all courses with real-time updates
  void fetchCoursesStream() {
    _isLoading = true;
    notifyListeners();

    FirestoreService.getCoursesStream().listen(
      (snapshot) {
        _courses = snapshot.docs
            .map((doc) => CourseModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load courses: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Fetch enrolled courses for a user
  Future<void> fetchEnrolledCourses(List<String> courseIds) async {
    if (courseIds.isEmpty) {
      _enrolledCourses = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _enrolledCourses = _courses.where((course) => courseIds.contains(course.id)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load enrolled courses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new course (Admin only)
  Future<bool> createCourse({
    required String title,
    required String description,
    required String category,
    required String level,
    required int duration,
    String? imageUrl,
    List<String>? topics,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final courseId = const Uuid().v4();
      final now = DateTime.now();

      final course = CourseModel(
        id: courseId,
        title: title,
        description: description,
        category: category,
        level: level,
        duration: duration,
        imageUrl: imageUrl,
        topics: topics ?? [],
        createdAt: now,
        updatedAt: now,
      );

      await FirestoreService.createCourse(courseId, course.toJson());

      _courses.add(course);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update a course (Admin only)
  Future<bool> updateCourse(String courseId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      updates['updatedAt'] = DateTime.now();
      await FirestoreService.updateCourse(courseId, updates);

      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        final updatedCourse = _courses[index].copyWith(
          title: updates['title'] ?? _courses[index].title,
          description: updates['description'] ?? _courses[index].description,
          category: updates['category'] ?? _courses[index].category,
          level: updates['level'] ?? _courses[index].level,
          duration: updates['duration'] ?? _courses[index].duration,
          imageUrl: updates['imageUrl'] ?? _courses[index].imageUrl,
          topics: updates['topics'] ?? _courses[index].topics,
          updatedAt: updates['updatedAt'],
        );
        _courses[index] = updatedCourse;
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a course (Admin only)
  Future<bool> deleteCourse(String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirestoreService.deleteCourse(courseId);
      _courses.removeWhere((c) => c.id == courseId);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get a single course by ID
  CourseModel? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((c) => c.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Search courses
  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _courses;
    
    final lowerQuery = query.toLowerCase();
    return _courses.where((course) {
      return course.title.toLowerCase().contains(lowerQuery) ||
          course.description.toLowerCase().contains(lowerQuery) ||
          course.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter courses by category
  List<CourseModel> filterByCategory(String category) {
    if (category.isEmpty) return _courses;
    return _courses.where((course) => course.category == category).toList();
  }

  // Filter courses by level
  List<CourseModel> filterByLevel(String level) {
    if (level.isEmpty) return _courses;
    return _courses.where((course) => course.level == level).toList();
  }

  // Enroll in a course
  Future<bool> enrollInCourse(String userId, String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get current user data
      final userDoc = await FirestoreService.getUser(userId);
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final enrolledCourses = List<String>.from(userData['enrolledCourses'] ?? []);

      // Check if already enrolled
      if (enrolledCourses.contains(courseId)) {
        _errorMessage = 'Already enrolled in this course';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Add course to enrolled list
      enrolledCourses.add(courseId);

      // Update user document
      await FirestoreService.updateUser(userId, {
        'enrolledCourses': enrolledCourses,
        'updatedAt': DateTime.now(),
      });

      // Update course enrolled count
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        await FirestoreService.updateCourse(courseId, {
          'enrolledCount': course.enrolledCount + 1,
          'updatedAt': DateTime.now(),
        });
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to enroll in course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Unenroll from a course
  Future<bool> unenrollFromCourse(String userId, String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get current user data
      final userDoc = await FirestoreService.getUser(userId);
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final enrolledCourses = List<String>.from(userData['enrolledCourses'] ?? []);

      // Remove course from enrolled list
      enrolledCourses.remove(courseId);

      // Update user document
      await FirestoreService.updateUser(userId, {
        'enrolledCourses': enrolledCourses,
        'updatedAt': DateTime.now(),
      });

      // Update course enrolled count
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final newCount = course.enrolledCount > 0 ? course.enrolledCount - 1 : 0;
        await FirestoreService.updateCourse(courseId, {
          'enrolledCount': newCount,
          'updatedAt': DateTime.now(),
        });
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unenroll from course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user is enrolled in a course
  Future<bool> isEnrolled(String userId, String courseId) async {
    try {
      final userDoc = await FirestoreService.getUser(userId);
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final enrolledCourses = List<String>.from(userData['enrolledCourses'] ?? []);
      return enrolledCourses.contains(courseId);
    } catch (e) {
      print('Error checking enrollment: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
