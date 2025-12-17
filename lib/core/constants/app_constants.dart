class AppConstants {
  // App Info
  static const String appName = 'Smart Learning Assistant';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://us-central1-learn-a150e.cloudfunctions.net/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String lessonsCollection = 'lessons';
  static const String quizzesCollection = 'quizzes';
  static const String quizResultsCollection = 'quiz_results';
  static const String notesCollection = 'notes';
  static const String progressCollection = 'progress';
  static const String notificationsCollection = 'notifications';
  static const String chatHistoryCollection = 'chat_history';
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';
  
  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  
  // Gemini AI Configuration
  static const String geminiApiKey = 'AIzaSyBWPHBDJLkvMIpypS-acGlNnZ163qkgZS8'; 
  static const String geminiModel = 'gemini-pro';
}
