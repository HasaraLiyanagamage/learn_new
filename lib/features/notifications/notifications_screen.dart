import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        // Use stream for real-time updates
        context.read<NotificationProvider>().fetchNotificationsStream(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                final userId = authProvider.currentUser?.id;
                if (userId != null) {
                  notificationProvider.markAllAsRead(userId);
                }
              },
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: notificationProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${notificationProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userId = authProvider.currentUser?.id;
                      if (userId != null) {
                        notificationProvider.fetchNotificationsStream(userId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : notificationProvider.isLoading && notifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No notifications'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              final userId = authProvider.currentUser?.id;
                              if (userId != null) {
                                notificationProvider.fetchNotificationsStream(userId);
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: notification.isRead ? null : Colors.blue.shade50,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getNotificationColor(notification.type),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notification.body),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(notification.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: !notification.isRead
                            ? IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  notificationProvider.markAsRead(notification.id);
                                },
                              )
                            : null,
                        onTap: () {
                          if (!notification.isRead) {
                            notificationProvider.markAsRead(notification.id);
                          }
                          // Navigate to related content if relatedId exists
                          if (notification.relatedId != null) {
                            // Handle navigation based on type
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'course':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      case 'lesson':
        return Icons.book;
      case 'enrollment':
        return Icons.person_add;
      case 'completion':
        return Icons.celebration;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'course':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'lesson':
        return Colors.green;
      case 'enrollment':
        return Colors.indigo;
      case 'completion':
        return Colors.amber;
      case 'system':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
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
}
