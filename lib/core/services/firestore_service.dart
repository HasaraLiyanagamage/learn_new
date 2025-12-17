import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enable offline persistence
  static Future<void> enableOfflinePersistence() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print('Error enabling offline persistence: $e');
    }
  }

  // Generic CRUD operations
  static Future<void> createDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  static Future<DocumentSnapshot> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  static Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  static Future<void> deleteDocument(
    String collection,
    String docId,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  static Stream<QuerySnapshot> getCollectionStream(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    try {
      Query query = _firestore.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return query.snapshots();
    } catch (e) {
      throw Exception('Failed to get collection stream: $e');
    }
  }

  static Future<QuerySnapshot> getCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return await query.get();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  // User operations
  static Future<void> createUser(String userId, Map<String, dynamic> userData) {
    return createDocument(AppConstants.usersCollection, userId, userData);
  }

  static Future<DocumentSnapshot> getUser(String userId) {
    return getDocument(AppConstants.usersCollection, userId);
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> userData) {
    return updateDocument(AppConstants.usersCollection, userId, userData);
  }

  static Future<void> deleteUser(String userId) {
    return deleteDocument(AppConstants.usersCollection, userId);
  }

  // Course operations
  static Stream<QuerySnapshot> getCoursesStream() {
    return getCollectionStream(AppConstants.coursesCollection);
  }

  static Future<QuerySnapshot> getCourses() {
    return getCollection(AppConstants.coursesCollection);
  }

  static Future<DocumentSnapshot> getCourse(String courseId) {
    return getDocument(AppConstants.coursesCollection, courseId);
  }

  static Future<void> createCourse(String courseId, Map<String, dynamic> courseData) {
    return createDocument(AppConstants.coursesCollection, courseId, courseData);
  }

  static Future<void> updateCourse(String courseId, Map<String, dynamic> courseData) {
    return updateDocument(AppConstants.coursesCollection, courseId, courseData);
  }

  static Future<void> deleteCourse(String courseId) {
    return deleteDocument(AppConstants.coursesCollection, courseId);
  }

  // Lesson operations
  static Stream<QuerySnapshot> getLessonsByCourseStream(String courseId) {
    return getCollectionStream(
      AppConstants.lessonsCollection,
      queryBuilder: (query) => query.where('courseId', isEqualTo: courseId).orderBy('order'),
    );
  }

  static Future<QuerySnapshot> getLessonsByCourse(String courseId) {
    return getCollection(
      AppConstants.lessonsCollection,
      queryBuilder: (query) => query.where('courseId', isEqualTo: courseId).orderBy('order'),
    );
  }

  static Future<DocumentSnapshot> getLesson(String lessonId) {
    return getDocument(AppConstants.lessonsCollection, lessonId);
  }

  static Future<void> createLesson(Map<String, dynamic> lessonData) {
    final docRef = _firestore.collection(AppConstants.lessonsCollection).doc();
    return docRef.set(lessonData);
  }
  
  static Future<void> createLessonWithId(String lessonId, Map<String, dynamic> lessonData) {
    return createDocument(AppConstants.lessonsCollection, lessonId, lessonData);
  }

  static Future<void> updateLesson(String lessonId, Map<String, dynamic> lessonData) {
    return updateDocument(AppConstants.lessonsCollection, lessonId, lessonData);
  }

  static Future<void> deleteLesson(String lessonId) {
    return deleteDocument(AppConstants.lessonsCollection, lessonId);
  }

  // Quiz operations
  static Stream<QuerySnapshot> getQuizzesByLessonStream(String lessonId) {
    return getCollectionStream(
      AppConstants.quizzesCollection,
      queryBuilder: (query) => query.where('lessonId', isEqualTo: lessonId),
    );
  }

  static Future<QuerySnapshot> getQuizzesByLesson(String lessonId) {
    return getCollection(
      AppConstants.quizzesCollection,
      queryBuilder: (query) => query.where('lessonId', isEqualTo: lessonId),
    );
  }

  static Future<DocumentSnapshot> getQuiz(String quizId) {
    return getDocument(AppConstants.quizzesCollection, quizId);
  }

  static Future<void> createQuiz(Map<String, dynamic> quizData) {
    final docRef = _firestore.collection(AppConstants.quizzesCollection).doc();
    return docRef.set(quizData);
  }
  
  static Future<void> createQuizWithId(String quizId, Map<String, dynamic> quizData) {
    return createDocument(AppConstants.quizzesCollection, quizId, quizData);
  }

  static Future<void> updateQuiz(String quizId, Map<String, dynamic> quizData) {
    return updateDocument(AppConstants.quizzesCollection, quizId, quizData);
  }

  static Future<void> deleteQuiz(String quizId) {
    return deleteDocument(AppConstants.quizzesCollection, quizId);
  }

  // Notes operations
  static Stream<QuerySnapshot> getNotesByUserStream(String userId) {
    return getCollectionStream(
      AppConstants.notesCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('updatedAt', descending: true),
    );
  }

  static Future<QuerySnapshot> getNotesByUser(String userId) {
    return getCollection(
      AppConstants.notesCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('updatedAt', descending: true),
    );
  }

  static Future<DocumentSnapshot> getNote(String noteId) {
    return getDocument(AppConstants.notesCollection, noteId);
  }

  static Future<void> createNote(String noteId, Map<String, dynamic> noteData) {
    return createDocument(AppConstants.notesCollection, noteId, noteData);
  }

  static Future<void> updateNote(String noteId, Map<String, dynamic> noteData) {
    return updateDocument(AppConstants.notesCollection, noteId, noteData);
  }

  static Future<void> deleteNote(String noteId) {
    return deleteDocument(AppConstants.notesCollection, noteId);
  }

  // Progress operations
  static Stream<QuerySnapshot> getProgressByUserStream(String userId) {
    return getCollectionStream(
      AppConstants.progressCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  static Future<QuerySnapshot> getProgressByUser(String userId) {
    return getCollection(
      AppConstants.progressCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  static Future<DocumentSnapshot> getProgress(String progressId) {
    return getDocument(AppConstants.progressCollection, progressId);
  }

  static Future<void> createProgress(String progressId, Map<String, dynamic> progressData) {
    return createDocument(AppConstants.progressCollection, progressId, progressData);
  }

  static Future<void> updateProgress(String progressId, Map<String, dynamic> progressData) {
    return updateDocument(AppConstants.progressCollection, progressId, progressData);
  }

  // Notification operations
  static Stream<QuerySnapshot> getNotificationsByUserStream(String userId) {
    return getCollectionStream(
      AppConstants.notificationsCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true),
    );
  }

  static Future<QuerySnapshot> getNotificationsByUser(String userId) {
    return getCollection(
      AppConstants.notificationsCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true),
    );
  }

  static Future<void> createNotification(String notificationId, Map<String, dynamic> notificationData) {
    return createDocument(AppConstants.notificationsCollection, notificationId, notificationData);
  }

  static Future<void> updateNotification(String notificationId, Map<String, dynamic> notificationData) {
    return updateDocument(AppConstants.notificationsCollection, notificationId, notificationData);
  }

  // Send notification to multiple users
  static Future<void> sendNotificationToUsers({
    required String title,
    required String body,
    required String type,
    required List<String> userIds,
  }) async {
    final batch = _firestore.batch();
    final timestamp = DateTime.now();

    for (final userId in userIds) {
      final docRef = _firestore.collection(AppConstants.notificationsCollection).doc();
      batch.set(docRef, {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': timestamp,
      });
    }

    await batch.commit();
  }

  // Send notification to all users of a specific role
  static Future<void> sendNotificationByRole({
    required String title,
    required String body,
    required String type,
    String? targetRole, // 'student', 'admin', or null for all
  }) async {
    // Get users based on role
    Query query = _firestore.collection(AppConstants.usersCollection);
    
    if (targetRole != null) {
      query = query.where('role', isEqualTo: targetRole);
    }

    final usersSnapshot = await query.get();
    final userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

    if (userIds.isEmpty) return;

    await sendNotificationToUsers(
      title: title,
      body: body,
      type: type,
      userIds: userIds,
    );
  }

  // Quiz Results operations
  static Stream<QuerySnapshot> getQuizResultsByUserStream(String userId) {
    return getCollectionStream(
      AppConstants.quizResultsCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('submittedAt', descending: true),
    );
  }

  static Future<QuerySnapshot> getQuizResultsByUser(String userId) {
    return getCollection(
      AppConstants.quizResultsCollection,
      queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('submittedAt', descending: true),
    );
  }

  static Future<void> createQuizResult(String resultId, Map<String, dynamic> resultData) {
    return createDocument(AppConstants.quizResultsCollection, resultId, resultData);
  }

  // Admin statistics operations
  static Stream<QuerySnapshot> getAllUsersStream() {
    return getCollectionStream(AppConstants.usersCollection);
  }

  static Future<QuerySnapshot> getAllUsers() {
    return getCollection(AppConstants.usersCollection);
  }

  static Stream<QuerySnapshot> getAllLessonsStream() {
    return getCollectionStream(AppConstants.lessonsCollection);
  }

  static Future<QuerySnapshot> getAllLessons() {
    return getCollection(AppConstants.lessonsCollection);
  }

  static Stream<QuerySnapshot> getAllQuizzesStream() {
    return getCollectionStream(AppConstants.quizzesCollection);
  }

  static Future<QuerySnapshot> getAllQuizzes() {
    return getCollection(AppConstants.quizzesCollection);
  }

  // Get count of documents in a collection
  static Future<int> getCollectionCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting collection count: $e');
      return 0;
    }
  }

  // Get students count (users with role 'student')
  static Future<int> getStudentsCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: 'student')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting students count: $e');
      return 0;
    }
  }
}
