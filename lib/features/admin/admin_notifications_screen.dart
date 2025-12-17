import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String _filterType = 'all';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sent Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              Navigator.of(context).pushNamed('/admin/send-notification');
            },
            tooltip: 'Send New Notification',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('System', 'system'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Course', 'course'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Quiz', 'quiz'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Lesson', 'lesson'),
                ],
              ),
            ),
          ),
          
          // Notifications list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getNotificationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No notifications sent yet'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/admin/send-notification');
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Send Notification'),
                        ),
                      ],
                    ),
                  );
                }

                // Group notifications by unique combinations
                final notifications = _groupNotifications(snapshot.data!.docs);

                return ListView.builder(
                  itemCount: notifications.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100);

    if (_filterType != 'all') {
      query = query.where('type', isEqualTo: _filterType);
    }

    return query.snapshots();
  }

  List<Map<String, dynamic>> _groupNotifications(List<QueryDocumentSnapshot> docs) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title'] ?? '';
      final body = data['body'] ?? '';
      final type = data['type'] ?? 'system';
      
      // Create a unique key based on title, body, and type
      final key = '$title|$body|$type';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'title': title,
          'body': body,
          'type': type,
          'createdAt': data['createdAt'],
          'recipientCount': 1,
          'recipients': [data['userId']],
        };
      } else {
        grouped[key]!['recipientCount'] = (grouped[key]!['recipientCount'] as int) + 1;
        (grouped[key]!['recipients'] as List).add(data['userId']);
      }
    }

    // Convert to list and sort by creation time
    final result = grouped.values.toList();
    result.sort((a, b) {
      final aTime = a['createdAt'] as Timestamp?;
      final bTime = b['createdAt'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return result;
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final title = notification['title'] as String;
    final body = notification['body'] as String;
    final type = notification['type'] as String;
    final recipientCount = notification['recipientCount'] as int;
    final createdAt = notification['createdAt'] as Timestamp?;
    
    final color = _getNotificationColor(type);
    final icon = _getNotificationIcon(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showNotificationDetails(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$recipientCount recipient${recipientCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (createdAt != null)
                    Text(
                      _formatTimestamp(createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final title = notification['title'] as String;
        final body = notification['body'] as String;
        final type = notification['type'] as String;
        final recipientCount = notification['recipientCount'] as int;
        final createdAt = notification['createdAt'] as Timestamp?;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Notification Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Title', title),
                  const SizedBox(height: 16),
                  _buildDetailRow('Message', body),
                  const SizedBox(height: 16),
                  _buildDetailRow('Type', type.toUpperCase()),
                  const SizedBox(height: 16),
                  _buildDetailRow('Recipients', '$recipientCount user${recipientCount > 1 ? 's' : ''}'),
                  const SizedBox(height: 16),
                  if (createdAt != null)
                    _buildDetailRow('Sent At', _formatFullTimestamp(createdAt)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'course':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'lesson':
        return Colors.green;
      case 'system':
        return Colors.purple;
      case 'enrollment':
        return Colors.indigo;
      case 'completion':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'course':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      case 'lesson':
        return Icons.book;
      case 'system':
        return Icons.info;
      case 'enrollment':
        return Icons.person_add;
      case 'completion':
        return Icons.celebration;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String _formatFullTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, y \'at\' h:mm a').format(date);
  }
}
