import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/course_model.dart';
import '../../core/models/user_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<CourseModel> _popularCourses = [];
  List<UserModel> _recentUsers = [];
  int _totalEnrollments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load courses and sort by enrolled count
      final coursesSnapshot = await FirestoreService.getCourses();
      final courses = coursesSnapshot.docs
          .map((doc) => CourseModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      
      courses.sort((a, b) => b.enrolledCount.compareTo(a.enrolledCount));
      _popularCourses = courses.take(5).toList();

      // Load recent users
      final usersSnapshot = await FirestoreService.getAllUsers();
      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentUsers = users.take(5).toList();

      // Calculate total enrollments
      _totalEnrollments = users.fold(0, (sum, user) => sum + user.enrolledCourses.length);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              adminProvider.fetchStatistics();
              _loadReportsData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Users',
                          '${adminProvider.totalStudents}',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Active Courses',
                          '${adminProvider.totalCourses}',
                          Icons.school,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Lessons',
                          '${adminProvider.totalLessons}',
                          Icons.book,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Quizzes',
                          '${adminProvider.totalQuizzes}',
                          Icons.quiz,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Enrollments',
                          '$_totalEnrollments',
                          Icons.assignment,
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Avg Enrollment',
                          adminProvider.totalStudents > 0
                              ? (_totalEnrollments / adminProvider.totalStudents).toStringAsFixed(1)
                              : '0',
                          Icons.trending_up,
                          Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Users
                  Text(
                    'Recent Users',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_recentUsers.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No recent users')),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: _recentUsers.map((user) {
                          return Column(
                            children: [
                              _buildActivityItem(
                                'New user registration',
                                '${user.name} (${user.role})',
                                _getTimeAgo(user.createdAt),
                                Icons.person_add,
                                Colors.blue,
                              ),
                              if (user != _recentUsers.last) const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Popular Courses
                  Text(
                    'Popular Courses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_popularCourses.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No courses available')),
                      ),
                    )
                  else
                    ..._popularCourses.map((course) {
                      return _buildCourseRankingCard(
                        course.title,
                        course.enrolledCount,
                        course.rating,
                      );
                    }),
                ],
              ),
            ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildCourseRankingCard(String title, int enrollments, double rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.school),
        ),
        title: Text(title),
        subtitle: Text('$enrollments enrollments'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
