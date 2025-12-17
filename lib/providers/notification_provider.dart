import 'package:flutter/material.dart';
import '../core/models/notification_model.dart';
import '../core/services/firestore_service.dart';
import '../core/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Fetch notifications for a user
  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await FirestoreService.getNotificationsByUser(userId);
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
      _calculateUnreadCount();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch notifications with stream
  void fetchNotificationsStream(String userId) {
    print('[Notification] Fetching notifications stream for user: $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    FirestoreService.getNotificationsByUserStream(userId).listen(
      (snapshot) {
        print('[Notification] Received ${snapshot.docs.length} notifications');
        _notifications = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('   - ${data['title']} (${data['type']})');
                return NotificationModel.fromJson({
                  ...data,
                  'id': doc.id,
                });
              } catch (e) {
                print('[Notification] Error parsing notification ${doc.id}: $e');
                rethrow;
              }
            })
            .toList();
        _calculateUnreadCount();
        _isLoading = false;
        print('[Notification] Notifications loaded. Unread: $_unreadCount');
        notifyListeners();
      },
      onError: (error) {
        print('[Notification] Error fetching notifications: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await FirestoreService.updateNotification(notificationId, {
        'isRead': true,
      });
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _calculateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      for (var notification in _notifications.where((n) => !n.isRead)) {
        await FirestoreService.updateNotification(notification.id, {
          'isRead': true,
        });
      }
      
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _calculateUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Send notification (Admin only)
  Future<bool> sendNotification({
    required String title,
    required String body,
    required String type,
    required String targetAudience,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? targetRole;
      
      // Map target audience to role
      if (targetAudience == 'students') {
        targetRole = 'student';
      } else if (targetAudience == 'admins') {
        targetRole = 'admin';
      }
      // 'all' means targetRole stays null

      await FirestoreService.sendNotificationByRole(
        title: title,
        body: body,
        type: type,
        targetRole: targetRole,
      );

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

  // Send push notification
  Future<void> sendPushNotification(String title, String body) async {
    await NotificationService.showNotification(
      title: title,
      body: body,
    );
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
