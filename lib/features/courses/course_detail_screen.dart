import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/notification_helper.dart';
import '../../core/models/course_model.dart';
import '../../core/models/lesson_model.dart';
import '../quiz/quiz_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isCourseCompleted = false;
  CourseModel? _course;
  List<String> _completedLessons = [];
  List<String> _completedQuizzes = [];
  int _totalLessons = 0;
  int _totalQuizzes = 0;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      // Load course
      final courseDoc = await FirestoreService.getDocument('courses', widget.courseId);
      if (courseDoc.exists) {
        _course = CourseModel.fromJson({
          ...courseDoc.data() as Map<String, dynamic>,
          'id': courseDoc.id,
        });
      }

      // Check enrollment
      if (userId != null) {
        final progressSnapshot = await FirestoreService.getCollection(
          'progress',
          queryBuilder: (query) => query
              .where('userId', isEqualTo: userId)
              .where('courseId', isEqualTo: widget.courseId),
        );

        if (progressSnapshot.docs.isNotEmpty) {
          _isEnrolled = true;
          final progressData = progressSnapshot.docs.first.data() as Map<String, dynamic>;
          _completedLessons = List<String>.from(progressData['completedLessons'] ?? []);
          _completedQuizzes = List<String>.from(progressData['completedQuizzes'] ?? []);
          _totalLessons = progressData['totalLessons'] ?? 0;
          _totalQuizzes = progressData['totalQuizzes'] ?? 0;
          _isCourseCompleted = progressData['isCompleted'] ?? false;
        }

        // Check if course is favorited
        final favoritesSnapshot = await FirestoreService.getCollection(
          'favorites',
          queryBuilder: (query) => query
              .where('userId', isEqualTo: userId)
              .where('courseId', isEqualTo: widget.courseId),
        );
        _isFavorite = favoritesSnapshot.docs.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Error loading course: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enrollInCourse() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Create progress document
      final progressId = '${userId}_${widget.courseId}';
      await FirestoreService.createDocument('progress', progressId, {
        'userId': userId,
        'courseId': widget.courseId,
        'completedLessons': [],
        'completedQuizzes': [],
        'totalLessons': 0,
        'totalQuizzes': 0,
        'progressPercentage': 0.0,
        'lastAccessedAt': DateTime.now(),
        'enrolledAt': DateTime.now(),
      });

      // Update course enrollment count
      await FirestoreService.updateDocument('courses', widget.courseId, {
        'enrolledCount': (_course?.enrolledCount ?? 0) + 1,
      });

      setState(() => _isEnrolled = true);

      // Send enrollment notification
      await NotificationHelper.sendEnrollmentNotification(
        userId: userId,
        courseId: widget.courseId,
        courseTitle: _course?.title ?? 'Course',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in course!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh student statistics
      context.read<StudentProvider>().fetchStudentStatistics(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markLessonComplete(String lessonId) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null || _completedLessons.contains(lessonId)) return;

    try {
      final progressId = '${userId}_${widget.courseId}';
      final updatedLessons = [..._completedLessons, lessonId];

      // Get total lessons count
      final lessonsSnapshot = await FirestoreService.getCollection(
        'lessons',
        queryBuilder: (query) => query.where('courseId', isEqualTo: widget.courseId),
      );
      final totalLessons = lessonsSnapshot.docs.length;

      // Get total quizzes count
      final quizzesSnapshot = await FirestoreService.getCollection(
        'quizzes',
        queryBuilder: (query) => query.where('courseId', isEqualTo: widget.courseId),
      );
      final totalQuizzes = quizzesSnapshot.docs.length;

      // Calculate progress
      final totalItems = totalLessons + totalQuizzes;
      final completedItems = updatedLessons.length + _completedQuizzes.length;
      final progress = totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

      await FirestoreService.updateDocument('progress', progressId, {
        'completedLessons': updatedLessons,
        'totalLessons': totalLessons,
        'totalQuizzes': totalQuizzes,
        'progressPercentage': progress,
        'lastAccessedAt': DateTime.now(),
      });

      setState(() {
        _completedLessons = updatedLessons;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh student statistics
      context.read<StudentProvider>().fetchStudentStatistics(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _navigateToQuiz(String quizId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quizId: quizId,
          courseId: widget.courseId,
          onQuizComplete: _markQuizComplete,
        ),
      ),
    );

    // Reload course data after quiz completion
    if (result == true) {
      _loadCourseData();
    }
  }

  Future<void> _markQuizComplete(String quizId, double score) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null || _completedQuizzes.contains(quizId)) return;

    try {
      final progressId = '${userId}_${widget.courseId}';
      final updatedQuizzes = [..._completedQuizzes, quizId];

      // Get total lessons count
      final lessonsSnapshot = await FirestoreService.getCollection(
        'lessons',
        queryBuilder: (query) => query.where('courseId', isEqualTo: widget.courseId),
      );
      final totalLessons = lessonsSnapshot.docs.length;

      // Get total quizzes count
      final quizzesSnapshot = await FirestoreService.getCollection(
        'quizzes',
        queryBuilder: (query) => query.where('courseId', isEqualTo: widget.courseId),
      );
      final totalQuizzes = quizzesSnapshot.docs.length;

      // Calculate progress
      final totalItems = totalLessons + totalQuizzes;
      final completedItems = _completedLessons.length + updatedQuizzes.length;
      final progress = totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

      await FirestoreService.updateDocument('progress', progressId, {
        'completedQuizzes': updatedQuizzes,
        'totalLessons': totalLessons,
        'totalQuizzes': totalQuizzes,
        'progressPercentage': progress,
        'lastAccessedAt': DateTime.now(),
      });

      // Save quiz result
      await FirestoreService.createDocument('quiz_results', '${userId}_${quizId}_${DateTime.now().millisecondsSinceEpoch}', {
        'userId': userId,
        'quizId': quizId,
        'courseId': widget.courseId,
        'score': score,
        'submittedAt': DateTime.now(),
      });

      setState(() {
        _completedQuizzes = updatedQuizzes;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz complete! Score: ${score.toStringAsFixed(0)}%'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh student statistics
      context.read<StudentProvider>().fetchStudentStatistics(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    try {
      if (_isFavorite) {
        // Remove from favorites
        final favoritesSnapshot = await FirestoreService.getCollection(
          'favorites',
          queryBuilder: (query) => query
              .where('userId', isEqualTo: userId)
              .where('courseId', isEqualTo: widget.courseId),
        );

        if (favoritesSnapshot.docs.isNotEmpty) {
          await FirestoreService.deleteDocument('favorites', favoritesSnapshot.docs.first.id);
        }

        setState(() => _isFavorite = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add to favorites
        await FirestoreService.createDocument('favorites', '${userId}_${widget.courseId}', {
          'userId': userId,
          'courseId': widget.courseId,
          'addedAt': DateTime.now(),
        });

        setState(() => _isFavorite = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markCourseComplete() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    // Check if all lessons and quizzes are completed
    if (_completedLessons.length < _totalLessons || _completedQuizzes.length < _totalQuizzes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all lessons and quizzes first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final progressId = '${userId}_${widget.courseId}';
      await FirestoreService.updateDocument('progress', progressId, {
        'isCompleted': true,
        'completedAt': DateTime.now(),
        'progressPercentage': 100.0,
      });

      setState(() => _isCourseCompleted = true);

      // Send completion notification
      await NotificationHelper.sendCompletionNotification(
        userId: userId,
        courseId: widget.courseId,
        courseTitle: _course!.title,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber, size: 32),
                SizedBox(width: 12),
                Text('Congratulations!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have successfully completed the course:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _course!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.celebration, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text('Keep up the great work!'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      // Refresh student statistics and progress
      context.read<StudentProvider>().fetchStudentStatistics(userId);
      context.read<ProgressProvider>().fetchUserProgress(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  bool get _canCompleteCourse {
    return _isEnrolled &&
        !_isCourseCompleted &&
        _totalLessons > 0 &&
        _totalQuizzes > 0 &&
        _completedLessons.length == _totalLessons &&
        _completedQuizzes.length == _totalQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Details')),
        body: const Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_course!.title),
        actions: [
          if (_isEnrolled)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
              tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _course!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _course!.category,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.star,
                        label: _course!.rating.toStringAsFixed(1),
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.people,
                        label: '${_course!.enrolledCount} enrolled',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this course',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _course!.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Enroll Button
            if (!_isEnrolled)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enrollInCourse,
                    icon: const Icon(Icons.school),
                    label: const Text('Enroll in Course'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),

            // Complete Course Button
            if (_canCompleteCourse)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _markCourseComplete,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Course as Complete'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Course Completed Badge
            if (_isCourseCompleted)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Course Completed!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

            // Lessons Section
            if (_isEnrolled) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Lessons',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              StreamBuilder(
                stream: FirestoreService.getLessonsByCourseStream(widget.courseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No lessons available yet'),
                    );
                  }

                  final lessons = snapshot.data!.docs
                      .map((doc) => LessonModel.fromJson({
                            ...doc.data() as Map<String, dynamic>,
                            'id': doc.id,
                          }))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      final isCompleted = _completedLessons.contains(lesson.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCompleted
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white)
                                : Text(
                                    '${lesson.order}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                          title: Text(lesson.title),
                          subtitle: Text('${lesson.duration} min'),
                          trailing: isCompleted
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () => _markLessonComplete(lesson.id),
                                  child: const Text('Complete'),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Progress Indicator
              if (_totalLessons > 0 || _totalQuizzes > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Course Progress',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${_completedLessons.length + _completedQuizzes.length}/${_totalLessons + _totalQuizzes}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (_totalLessons + _totalQuizzes) > 0
                                ? (_completedLessons.length + _completedQuizzes.length) /
                                    (_totalLessons + _totalQuizzes)
                                : 0,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lessons: ${_completedLessons.length}/$_totalLessons | Quizzes: ${_completedQuizzes.length}/$_totalQuizzes',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Quizzes Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Quizzes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              StreamBuilder(
                stream: FirestoreService.getCollectionStream(
                  'quizzes',
                  queryBuilder: (query) => query.where('courseId', isEqualTo: widget.courseId),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No quizzes available yet'),
                    );
                  }

                  final quizzes = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quizDoc = quizzes[index];
                      final quiz = quizDoc.data() as Map<String, dynamic>;
                      final quizId = quizDoc.id;
                      final isCompleted = _completedQuizzes.contains(quizId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: isCompleted
                              ? null
                              : () => _navigateToQuiz(quizId),
                          leading: CircleAvatar(
                            backgroundColor: isCompleted
                                ? Colors.green
                                : Colors.orange,
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white)
                                : const Icon(Icons.quiz, color: Colors.white),
                          ),
                          title: Text(quiz['title'] ?? 'Quiz'),
                          subtitle: Text(
                            '${(quiz['questions'] as List?)?.length ?? 0} questions',
                          ),
                          trailing: isCompleted
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
