import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Helper class for creating and sending notifications
class NotificationHelper {
  /// Send a notification to a specific user
  static Future<void> sendToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('notifications').doc();
      final notificationData = {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      print('[Notification] Sending notification to user: $userId');
      print('   Title: $title');
      print('   Type: $type');
      
      await docRef.set(notificationData);
      print('[Notification] Notification sent successfully! Doc ID: ${docRef.id}');
    } catch (e) {
      print('[Notification] Error sending notification: $e');
      rethrow;
    }
  }

  /// Send enrollment notification
  static Future<void> sendEnrollmentNotification({
    required String userId,
    required String courseId,
    required String courseTitle,
  }) async {
    await sendToUser(
      userId: userId,
      title: 'Course Enrollment',
      body: 'You have successfully enrolled in "$courseTitle"',
      type: 'course',
      relatedId: courseId,
    );
  }

  /// Send course completion notification
  static Future<void> sendCompletionNotification({
    required String userId,
    required String courseId,
    required String courseTitle,
  }) async {
    await sendToUser(
      userId: userId,
      title: 'Course Completed!',
      body: 'Congratulations! You have completed "$courseTitle"',
      type: 'course',
      relatedId: courseId,
    );
  }

  /// Send quiz completion notification
  static Future<void> sendQuizCompletionNotification({
    required String userId,
    required String quizId,
    required String quizTitle,
    required double score,
    required bool passed,
  }) async {
    await sendToUser(
      userId: userId,
      title: passed ? 'Quiz Passed!' : 'Quiz Completed',
      body: passed
          ? 'Great job! You passed "$quizTitle" with ${score.toStringAsFixed(0)}%'
          : 'You completed "$quizTitle" with ${score.toStringAsFixed(0)}%. Keep trying!',
      type: 'quiz',
      relatedId: quizId,
    );
  }

  /// Send lesson completion notification
  static Future<void> sendLessonCompletionNotification({
    required String userId,
    required String lessonId,
    required String lessonTitle,
  }) async {
    await sendToUser(
      userId: userId,
      title: 'Lesson Completed',
      body: 'You have completed the lesson "$lessonTitle"',
      type: 'lesson',
      relatedId: lessonId,
    );
  }

  /// Send admin broadcast notification to all users with specific role
  static Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    required String type,
    String? targetRole, // 'student', 'admin', or null for all
  }) async {
    try {
      await FirestoreService.sendNotificationByRole(
        title: title,
        body: body,
        type: type,
        targetRole: targetRole,
      );
    } catch (e) {
      print('Error sending broadcast notification: $e');
      rethrow;
    }
  }
}
