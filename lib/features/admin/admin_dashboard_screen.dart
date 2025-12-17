import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch initial statistics and start real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      adminProvider.fetchStatistics();
      adminProvider.startRealtimeUpdates();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        Navigator.of(context).pushNamed('/admin/courses');
        break;
      case 2:
        Navigator.of(context).pushNamed('/admin/users');
        break;
      case 3:
        Navigator.of(context).pushNamed('/admin/reports');
        break;
      case 4:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have admin privileges'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed('/admin/notifications');
            },
            tooltip: 'View Sent Notifications',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading indicator
                if (adminProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Courses',
                        value: adminProvider.totalCourses.toString(),
                        icon: Icons.school,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Students',
                        value: adminProvider.totalStudents.toString(),
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Lessons',
                        value: adminProvider.totalLessons.toString(),
                        icon: Icons.book,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Quizzes',
                        value: adminProvider.totalQuizzes.toString(),
                        icon: Icons.quiz,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Management sections
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _ManagementCard(
                  title: 'Course Management',
                  subtitle: 'Create, edit, and delete courses',
                  icon: Icons.school,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/courses');
                  },
                ),
                const SizedBox(height: 12),

                _ManagementCard(
                  title: 'Lesson Management',
                  subtitle: 'Add and manage lessons',
                  icon: Icons.book,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/add-lesson');
                  },
                ),
                const SizedBox(height: 12),

                _ManagementCard(
                  title: 'Quiz Management',
                  subtitle: 'Add and manage quizzes',
                  icon: Icons.quiz,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/add-quiz');
                  },
                ),
                const SizedBox(height: 12),

                _ManagementCard(
                  title: 'User Management',
                  subtitle: 'View and manage users',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/users');
                  },
                ),
                const SizedBox(height: 12),

                _ManagementCard(
                  title: 'Send Notifications',
                  subtitle: 'Send notifications to users',
                  icon: Icons.notifications,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/send-notification');
                  },
                ),
                const SizedBox(height: 12),

                _ManagementCard(
                  title: 'Reports & Analytics',
                  subtitle: 'View system reports',
                  icon: Icons.analytics,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/reports');
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
