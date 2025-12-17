import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static String? _authToken;

  static Future<void> init() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to headers
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            // Attempt to refresh token
            try {
              await _refreshToken();
              // Retry the request
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              );
              final response = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Future<void> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken != null) {
        final response = await _dio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );
        if (response.statusCode == 200) {
          _authToken = response.data['token'];
          await prefs.setString('auth_token', _authToken!);
        }
      }
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Generic HTTP methods
  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Exception _handleError(DioException error) {
    String message = 'An error occurred';
    
    if (error.response != null) {
      message = error.response?.data['message'] ?? error.response?.statusMessage ?? message;
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection';
    }
    
    return Exception(message);
  }

  // Auth API calls
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await post(ApiEndpoints.register, data: userData);
    return response.data;
  }

  static Future<void> logout() async {
    await post(ApiEndpoints.logout);
    clearAuthToken();
  }

  // User API calls
  static Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await get(ApiEndpoints.userById(userId));
    return response.data;
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    final response = await put(ApiEndpoints.updateProfile, data: userData);
    return response.data;
  }

  // Course API calls
  static Future<List<dynamic>> getCourses() async {
    final response = await get(ApiEndpoints.courses);
    return response.data['courses'] ?? [];
  }

  static Future<Map<String, dynamic>> getCourse(String courseId) async {
    final response = await get(ApiEndpoints.courseById(courseId));
    return response.data;
  }

  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> courseData) async {
    final response = await post(ApiEndpoints.courses, data: courseData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    final response = await put(ApiEndpoints.courseById(courseId), data: courseData);
    return response.data;
  }

  static Future<void> deleteCourse(String courseId) async {
    await delete(ApiEndpoints.courseById(courseId));
  }

  static Future<Map<String, dynamic>> enrollCourse(String courseId) async {
    final response = await post(ApiEndpoints.enrollCourse(courseId));
    return response.data;
  }

  // Lesson API calls
  static Future<List<dynamic>> getLessonsByCourse(String courseId) async {
    final response = await get(ApiEndpoints.lessonsByCourse(courseId));
    return response.data['lessons'] ?? [];
  }

  static Future<Map<String, dynamic>> getLesson(String lessonId) async {
    final response = await get(ApiEndpoints.lessonById(lessonId));
    return response.data;
  }

  static Future<Map<String, dynamic>> createLesson(Map<String, dynamic> lessonData) async {
    final response = await post(ApiEndpoints.lessons, data: lessonData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateLesson(String lessonId, Map<String, dynamic> lessonData) async {
    final response = await put(ApiEndpoints.lessonById(lessonId), data: lessonData);
    return response.data;
  }

  static Future<void> deleteLesson(String lessonId) async {
    await delete(ApiEndpoints.lessonById(lessonId));
  }

  // Quiz API calls
  static Future<List<dynamic>> getQuizzesByLesson(String lessonId) async {
    final response = await get(ApiEndpoints.quizzesByLesson(lessonId));
    return response.data['quizzes'] ?? [];
  }

  static Future<Map<String, dynamic>> getQuiz(String quizId) async {
    final response = await get(ApiEndpoints.quizById(quizId));
    return response.data;
  }

  static Future<Map<String, dynamic>> createQuiz(Map<String, dynamic> quizData) async {
    final response = await post(ApiEndpoints.quizzes, data: quizData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateQuiz(String quizId, Map<String, dynamic> quizData) async {
    final response = await put(ApiEndpoints.quizById(quizId), data: quizData);
    return response.data;
  }

  static Future<void> deleteQuiz(String quizId) async {
    await delete(ApiEndpoints.quizById(quizId));
  }

  static Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> answers) async {
    final response = await post(ApiEndpoints.submitQuiz(quizId), data: answers);
    return response.data;
  }

  // Notes API calls
  static Future<List<dynamic>> getNotesByUser(String userId) async {
    final response = await get(ApiEndpoints.notesByUser(userId));
    return response.data['notes'] ?? [];
  }

  static Future<Map<String, dynamic>> getNote(String noteId) async {
    final response = await get(ApiEndpoints.noteById(noteId));
    return response.data;
  }

  static Future<Map<String, dynamic>> createNote(Map<String, dynamic> noteData) async {
    final response = await post(ApiEndpoints.notes, data: noteData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateNote(String noteId, Map<String, dynamic> noteData) async {
    final response = await put(ApiEndpoints.noteById(noteId), data: noteData);
    return response.data;
  }

  static Future<void> deleteNote(String noteId) async {
    await delete(ApiEndpoints.noteById(noteId));
  }

  // Progress API calls
  static Future<List<dynamic>> getProgressByUser(String userId) async {
    final response = await get(ApiEndpoints.progressByUser(userId));
    return response.data['progress'] ?? [];
  }

  static Future<Map<String, dynamic>> updateProgress(Map<String, dynamic> progressData) async {
    final response = await post(ApiEndpoints.updateProgress, data: progressData);
    return response.data;
  }

  // Notification API calls
  static Future<List<dynamic>> getNotificationsByUser(String userId) async {
    final response = await get(ApiEndpoints.notificationsByUser(userId));
    return response.data['notifications'] ?? [];
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await put(ApiEndpoints.markNotificationRead(notificationId));
  }

  static Future<void> sendNotification(Map<String, dynamic> notificationData) async {
    await post(ApiEndpoints.sendNotification, data: notificationData);
  }

  // Chatbot API calls
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final response = await post(ApiEndpoints.chatbot, data: {'message': message});
    return response.data;
  }

  static Future<List<dynamic>> getChatHistory(String userId) async {
    final response = await get('${ApiEndpoints.chatHistory}?userId=$userId');
    return response.data['history'] ?? [];
  }
}
