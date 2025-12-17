import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Core services
import 'core/services/firestore_service.dart';
import 'core/services/api_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/chatbot_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/student_provider.dart';

// Screens
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/courses/courses_screen.dart';
import 'features/courses/my_courses_screen.dart';
import 'features/courses/course_detail_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/chatbot/chatbot_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/course_management_screen.dart';
import 'features/admin/lesson_management_screen.dart';
import 'features/admin/quiz_management_screen.dart';
import 'features/admin/add_lesson_screen.dart';
import 'features/admin/add_quiz_screen.dart';
import 'features/admin/user_management_screen.dart';
import 'features/admin/reports_screen.dart';
import 'features/admin/send_notification_screen.dart';
import 'features/admin/admin_notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable Firestore offline persistence
  await FirestoreService.enableOfflinePersistence();
  
  // Initialize services
  await ApiService.init();
  await NotificationService.initialize();
  ChatbotService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Smart Learning Assistant',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/courses': (context) => const CoursesScreen(),
              '/my-courses': (context) => const MyCoursesScreen(),
              '/notes': (context) => const NotesScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
              '/progress': (context) => const ProgressScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/admin': (context) => const AdminDashboardScreen(),
              '/admin/courses': (context) => const CourseManagementScreen(),
              '/admin/add-lesson': (context) => const AddLessonScreen(),
              '/admin/add-quiz': (context) => const AddQuizScreen(),
              '/admin/users': (context) => const UserManagementScreen(),
              '/admin/reports': (context) => const ReportsScreen(),
              '/admin/send-notification': (context) => const SendNotificationScreen(),
              '/admin/notifications': (context) => const AdminNotificationsScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle dynamic routes with parameters
              if (settings.name == '/course-detail') {
                final courseId = settings.arguments as String?;
                if (courseId != null) {
                  return MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(courseId: courseId),
                  );
                }
              }
              
              if (settings.name == '/admin/lessons') {
                final courseId = settings.arguments as String?;
                if (courseId != null) {
                  return MaterialPageRoute(
                    builder: (context) => LessonManagementScreen(courseId: courseId),
                  );
                }
              }
              
              if (settings.name == '/admin/quizzes') {
                final lessonId = settings.arguments as String?;
                if (lessonId != null) {
                  return MaterialPageRoute(
                    builder: (context) => QuizManagementScreen(lessonId: lessonId),
                  );
                }
              }
              
              return null;
            },
          );
        },
      ),
    );
  }
}
