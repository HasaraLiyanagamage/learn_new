class ApiEndpoints {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // User Endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String updateProfile = '/users/profile';
  
  // Course Endpoints
  static const String courses = '/courses';
  static String courseById(String id) => '/courses/$id';
  static String enrollCourse(String id) => '/courses/$id/enroll';
  static String unenrollCourse(String id) => '/courses/$id/unenroll';
  static String coursesByUser(String userId) => '/courses/user/$userId';
  
  // Lesson Endpoints
  static const String lessons = '/lessons';
  static String lessonById(String id) => '/lessons/$id';
  static String lessonsByCourse(String courseId) => '/lessons/course/$courseId';
  
  // Quiz Endpoints
  static const String quizzes = '/quizzes';
  static String quizById(String id) => '/quizzes/$id';
  static String quizzesByLesson(String lessonId) => '/quizzes/lesson/$lessonId';
  static String submitQuiz(String id) => '/quizzes/$id/submit';
  static String quizResults(String userId) => '/quiz-results/user/$userId';
  
  // Notes Endpoints
  static const String notes = '/notes';
  static String noteById(String id) => '/notes/$id';
  static String notesByUser(String userId) => '/notes/user/$userId';
  
  // Progress Endpoints
  static const String progress = '/progress';
  static String progressByUser(String userId) => '/progress/user/$userId';
  static String updateProgress = '/progress/update';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static String notificationsByUser(String userId) => '/notifications/user/$userId';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String sendNotification = '/notifications/send';
  
  // Chatbot Endpoints
  static const String chatbot = '/chatbot';
  static const String chatHistory = '/chatbot/history';
}
