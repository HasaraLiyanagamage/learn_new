# Smart Learning Assistant - Group Feature Distribution

## Project Overview
**App Name:** Smart Learning Assistant  
**Platform:** Flutter Mobile Application  
**Backend:** Firebase (Firestore + Authentication)  
**AI Integration:** Google Gemini AI  
**Group Members:** 4 People

---

## Member 1: Authentication & User Management

### Features Assigned

#### 1. **Authentication System (Online)**
- **Description:** Complete user authentication flow with Firebase Authentication
- **Functionality:**
  - User registration with email/password
  - User login with validation
  - Password reset functionality
  - Session management
  - Role-based access (Student/Admin)

#### 2. **User Profile Management (Hybrid - Online/Offline)**
- **Description:** User profile viewing and editing capabilities
- **Functionality:**
  - View user profile information
  - Edit profile details (name, email, bio)
  - Update profile picture
  - Display user statistics
  - Offline caching of profile data

### Frontend Pages
1. **LoginScreen** (`lib/features/auth/login_screen.dart`)
2. **RegisterScreen** (`lib/features/auth/register_screen.dart`)
3. **ProfileScreen** (`lib/features/profile/profile_screen.dart`)
4. **EditProfileScreen** (`lib/features/profile/edit_profile_screen.dart`)

### Related Coding Files

#### Providers
- **`lib/providers/auth_provider.dart`** (12,142 bytes)
  - Manages authentication state
  - Handles login/logout operations
  - User session management
  - Firebase Auth integration
  - Methods: `login()`, `register()`, `logout()`, `resetPassword()`

#### Services
- **Firebase Authentication Integration** (in `auth_provider.dart`)
  - Email/password authentication
  - User creation and validation
  - Session persistence

#### Models
- **`lib/core/models/user_model.dart`**
  - User data structure
  - Fields: id, name, email, role, profilePicture, createdAt
  - JSON serialization/deserialization

#### Utilities
- **`lib/core/utils/validators.dart`**
  - Email validation
  - Password strength validation
  - Form input validation

### Key Technical Details
- **State Management:** Provider pattern
- **Validation:** Custom validators for email and password
- **Security:** Firebase Authentication with secure token management
- **Offline Support:** User data cached locally after login
- **Error Handling:** Comprehensive error messages for auth failures

---

## Member 2: Course & Lesson Management

### Features Assigned

#### 1. **Course Browsing & Enrollment (Hybrid - Online/Offline)**
- **Description:** Browse available courses and enroll in them
- **Functionality:**
  - View all available courses
  - Search and filter courses
  - View course details (description, lessons, duration)
  - Enroll in courses
  - View enrolled courses (My Courses)
  - Offline access to enrolled course data

#### 2. **Lesson Viewing (Hybrid - Online/Offline)**
- **Description:** Access and view lesson content
- **Functionality:**
  - View lesson content (text, images, videos)
  - Navigate through lessons sequentially
  - Mark lessons as complete
  - Track lesson progress
  - Offline viewing of downloaded lessons

### Frontend Pages
1. **CoursesScreen** (`lib/features/courses/courses_screen.dart`)
2. **MyCoursesScreen** (`lib/features/courses/my_courses_screen.dart`)
3. **CourseDetailScreen** (`lib/features/courses/course_detail_screen.dart`)
4. **LessonViewerScreen** (`lib/features/lessons/lesson_viewer_screen.dart`)
5. **HomeScreen** (`lib/features/home/home_screen.dart`)

### Related Coding Files

#### Providers
- **`lib/providers/course_provider.dart`** (9,108 bytes)
  - Manages course data and state
  - Handles course enrollment
  - Fetches courses from Firestore
  - Methods: `fetchCourses()`, `enrollInCourse()`, `getCourseById()`

- **`lib/providers/lesson_provider.dart`** (3,936 bytes)
  - Manages lesson data
  - Tracks lesson completion
  - Methods: `fetchLessonsByCourse()`, `markLessonComplete()`

- **`lib/providers/student_provider.dart`** (4,196 bytes)
  - Manages student-specific data
  - Enrolled courses tracking
  - Student progress monitoring

#### Services
- **`lib/core/services/firestore_service.dart`** (414 lines)
  - Course CRUD operations
  - Lesson CRUD operations
  - Real-time course updates
  - Offline persistence enabled
  - Methods: `getCourses()`, `getLessonsByCourse()`, `getCourse()`

#### Models
- **`lib/core/models/course_model.dart`**
  - Course data structure
  - Fields: id, title, description, instructor, duration, imageUrl, lessons

- **`lib/core/models/lesson_model.dart`**
  - Lesson data structure
  - Fields: id, courseId, title, content, order, duration, type

#### Widgets
- **`lib/widgets/course_card.dart`** (8,938 bytes)
  - Reusable course card component
  - Displays course information
  - Enrollment button

- **`lib/widgets/lesson_content_viewer.dart`** (5,482 bytes)
  - Renders lesson content
  - Supports multiple content types
  - Video/text/image display

### Key Technical Details
- **State Management:** Provider pattern with real-time streams
- **Offline Support:** Firestore offline persistence for courses and lessons
- **Data Sync:** Automatic sync when online
- **Content Types:** Text, images, video URLs
- **Progress Tracking:** Lesson completion status stored in Firestore

---

## Member 3: Quiz System & Progress Tracking

### Features Assigned

#### 1. **Quiz System (Hybrid - Online/Offline)**
- **Description:** Interactive quiz system for course assessment
- **Functionality:**
  - View quiz questions
  - Multiple-choice question interface
  - Submit quiz answers
  - View quiz results and scores
  - Passing score validation
  - Quiz history tracking
  - Offline quiz taking (syncs when online)

#### 2. **Progress Tracking (Hybrid - Online/Offline)**
- **Description:** Track student learning progress
- **Functionality:**
  - View overall course progress
  - Lesson completion tracking
  - Quiz score history
  - Visual progress indicators
  - Course completion percentage
  - Achievement badges
  - Offline progress caching

### Frontend Pages
1. **QuizScreen** (`lib/features/quiz/quiz_screen.dart`)
2. **ProgressScreen** (`lib/features/progress/progress_screen.dart`)

### Related Coding Files

#### Providers
- **`lib/providers/quiz_provider.dart`** (6,320 bytes)
  - Manages quiz data and state
  - Handles quiz submission
  - Calculates scores
  - Methods: `fetchQuizById()`, `submitQuiz()`, `calculateScore()`

- **`lib/providers/progress_provider.dart`** (2,908 bytes)
  - Tracks user progress
  - Calculates completion percentages
  - Methods: `fetchProgress()`, `updateProgress()`, `getCompletionRate()`

#### Services
- **`lib/core/services/firestore_service.dart`** (Quiz & Progress sections)
  - Quiz CRUD operations
  - Quiz result storage
  - Progress tracking
  - Methods: `getQuizzesByLesson()`, `createQuizResult()`, `getProgressByUser()`

#### Models
- **`lib/core/models/quiz_model.dart`**
  - Quiz data structure
  - Fields: id, lessonId, title, description, questions, duration, passingScore
  - Question model with options and correct answer

- **`lib/core/models/progress_model.dart`**
  - Progress data structure
  - Fields: userId, courseId, completedLessons, quizScores, completionPercentage

#### Widgets
- **`lib/widgets/quiz_option_button.dart`** (3,295 bytes)
  - Quiz option selection button
  - Visual feedback for selection
  - Correct/incorrect indication

- **`lib/widgets/progress_indicator_widget.dart`** (2,969 bytes)
  - Visual progress bars
  - Circular progress indicators
  - Percentage display

### Key Technical Details
- **State Management:** Provider pattern
- **Quiz Logic:** Client-side score calculation with server validation
- **Offline Support:** Quiz results queued and synced when online
- **Data Persistence:** Progress stored in Firestore with offline cache
- **Validation:** Passing score threshold checking
- **Analytics:** Detailed quiz performance metrics

---

## Member 4: Notes, AI Chatbot & Notifications

### Features Assigned

#### 1. **Notes System (Hybrid - Online/Offline)**
- **Description:** Personal note-taking system for students
- **Functionality:**
  - Create notes with title and content
  - Edit existing notes
  - Delete notes
  - Search notes by title/content
  - Tag notes with keywords
  - Link notes to courses/lessons
  - Full offline support with sync

#### 2. **AI Chatbot (Online)**
- **Description:** AI-powered learning assistant using Google Gemini
- **Functionality:**
  - Ask questions about course content
  - Get concept explanations
  - Receive study tips
  - Course recommendations based on interests
  - Real-time chat interface
  - Chat history

#### 3. **Notifications System (Hybrid - Online/Offline)**
- **Description:** Push notifications and in-app notifications
- **Functionality:**
  - Receive course updates
  - Quiz reminders
  - New lesson notifications
  - Mark notifications as read
  - Notification history
  - Offline notification queue

#### 4. **Settings & Preferences (Offline)**
- **Description:** App settings and customization
- **Functionality:**
  - Theme toggle (Light/Dark mode)
  - Language selection
  - Notification preferences
  - Account settings

### Frontend Pages
1. **NotesScreen** (`lib/features/notes/notes_screen.dart`)
2. **ChatbotScreen** (`lib/features/chatbot/chatbot_screen.dart`)
3. **NotificationsScreen** (`lib/features/notifications/notifications_screen.dart`)
4. **SettingsScreen** (`lib/features/settings/settings_screen.dart`)

### Related Coding Files

#### Providers
- **`lib/providers/notes_provider.dart`** (4,523 bytes)
  - Manages notes CRUD operations
  - Real-time notes sync
  - Search and filter functionality
  - Methods: `createNote()`, `updateNote()`, `deleteNote()`, `searchNotes()`

- **`lib/providers/chatbot_provider.dart`** (3,835 bytes)
  - Manages chat messages
  - AI interaction handling
  - Methods: `sendMessage()`, `explainConcept()`, `getStudyTips()`, `getCourseRecommendations()`

- **`lib/providers/notification_provider.dart`** (4,818 bytes)
  - Manages notifications
  - Mark as read functionality
  - Methods: `fetchNotifications()`, `markAsRead()`, `clearAll()`

- **`lib/providers/theme_provider.dart`** (3,134 bytes)
  - Theme management (Light/Dark)
  - Theme persistence
  - Methods: `toggleTheme()`, `setThemeMode()`

- **`lib/providers/locale_provider.dart`** (1,281 bytes)
  - Language/locale management
  - Methods: `setLocale()`

#### Services
- **`lib/core/services/chatbot_service.dart`** (111 lines)
  - Google Gemini AI integration
  - Prompt engineering for learning context
  - Methods: `sendMessage()`, `explainConcept()`, `getStudyTips()`, `getCourseRecommendations()`

- **`lib/core/services/notification_service.dart`**
  - Firebase Cloud Messaging integration
  - Local notification handling
  - Methods: `initialize()`, `showNotification()`, `scheduleNotification()`

- **`lib/core/services/notification_helper.dart`**
  - Notification utility functions
  - Notification formatting

- **`lib/core/services/firestore_service.dart`** (Notes & Notifications sections)
  - Notes CRUD operations
  - Notification storage and retrieval
  - Methods: `getNotesByUser()`, `createNote()`, `getNotificationsByUser()`

#### Models
- **`lib/core/models/note_model.dart`**
  - Note data structure
  - Fields: id, userId, title, content, tags, courseId, lessonId, createdAt, updatedAt

- **`lib/core/models/chat_message_model.dart`**
  - Chat message structure
  - Fields: id, userId, message, response, timestamp, isUser

- **`lib/core/models/notification_model.dart`**
  - Notification data structure
  - Fields: id, userId, title, body, type, isRead, createdAt

#### Widgets
- **`lib/widgets/chat_message_bubble.dart`** (2,281 bytes)
  - Chat message UI component
  - User/bot message differentiation
  - Timestamp display

- **`lib/widgets/note_editor.dart`** (5,095 bytes)
  - Rich text note editor
  - Formatting options
  - Auto-save functionality

### Key Technical Details
- **State Management:** Provider pattern
- **AI Integration:** Google Gemini API with custom prompts
- **Offline Support:** Notes fully functional offline with Firestore sync
- **Real-time Updates:** Stream-based notifications
- **Theme Persistence:** SharedPreferences for settings
- **Search:** Client-side note search with indexing

---

## Admin Features Distribution

### Member 1: Admin User Management
**Admin Screen:** `lib/features/admin/user_management_screen.dart`
- View all users
- Edit user roles
- Delete users
- User statistics

**Provider:** `lib/providers/admin_provider.dart` (2,525 bytes)

---

### Member 2: Admin Course & Lesson Management
**Admin Screens:**
- `lib/features/admin/course_management_screen.dart`
- `lib/features/admin/lesson_management_screen.dart`
- `lib/features/admin/add_lesson_screen.dart`

**Functionality:**
- Create/Edit/Delete courses
- Create/Edit/Delete lessons
- Upload course materials
- Manage course structure

---

### Member 3: Admin Quiz Management & Reports
**Admin Screens:**
- `lib/features/admin/quiz_management_screen.dart`
- `lib/features/admin/add_quiz_screen.dart`
- `lib/features/admin/reports_screen.dart`

**Functionality:**
- Create/Edit/Delete quizzes
- Add quiz questions
- View student performance reports
- Analytics dashboard

---

### Member 4: Admin Notifications & Dashboard
**Admin Screens:**
- `lib/features/admin/admin_dashboard_screen.dart`
- `lib/features/admin/send_notification_screen.dart`
- `lib/features/admin/admin_notifications_screen.dart`

**Functionality:**
- Admin dashboard with statistics
- Send notifications to users/groups
- View notification history
- System overview

---

## Shared/Core Components (All Members)

### Constants
- **`lib/core/constants/app_constants.dart`**
  - App-wide constants
  - Collection names
  - API keys
  - Configuration values

- **`lib/core/constants/api_endpoints.dart`**
  - API endpoint definitions
  - Base URLs

### Utilities
- **`lib/core/utils/connectivity_helper.dart`** (19 lines)
  - Check internet connectivity
  - Monitor connection status
  - Methods: `isConnected()`, `onConnectivityChanged`

- **`lib/core/utils/date_formatter.dart`**
  - Date/time formatting utilities
  - Relative time display
  - Methods: `formatRelativeTime()`, `formatTime()`

### Main Application
- **`lib/main.dart`** (155 lines)
  - App initialization
  - Firebase setup
  - Provider configuration
  - Route definitions
  - Offline persistence enablement

---

## Technology Stack Summary

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Provider pattern
- **UI Components:** Material Design 3

### Backend
- **Database:** Firebase Firestore
- **Authentication:** Firebase Authentication
- **Storage:** Firebase Storage (for images/files)
- **Notifications:** Firebase Cloud Messaging

### AI/ML
- **AI Service:** Google Gemini AI
- **Use Cases:** Chatbot, concept explanation, study recommendations

### Offline Support
- **Strategy:** Firestore offline persistence
- **Cache:** Unlimited cache size
- **Sync:** Automatic background sync when online

### Key Packages
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Database
- `firebase_auth` - Authentication
- `provider` - State management
- `google_generative_ai` - Gemini AI
- `connectivity_plus` - Network status
- `uuid` - Unique ID generation

---

## Feature Summary by Online/Offline Capability

### Fully Offline Features
- Notes (create, edit, delete, search)
- View enrolled courses (cached)
- View downloaded lessons
- Quiz taking (syncs results later)
- Progress viewing (cached data)
- Settings/Theme changes

### Hybrid Features (Work Offline with Limitations)
- Course browsing (cached data)
- Lesson viewing (downloaded content)
- Profile viewing (cached)
- Notifications (view cached, new ones require online)

### Online-Only Features
- Authentication (login/register)
- AI Chatbot
- Course enrollment
- Real-time data sync
- Admin operations
- Sending notifications

---

## Development Guidelines

### Code Organization
- Features organized in `lib/features/` by functionality
- Shared code in `lib/core/`
- Reusable widgets in `lib/widgets/`
- State management in `lib/providers/`

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Methods: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

### Error Handling
- Try-catch blocks for async operations
- User-friendly error messages
- Loading states for async operations
- Offline fallbacks

### Testing Recommendations
- Unit tests for providers
- Widget tests for UI components
- Integration tests for critical flows
- Test offline scenarios

---

## Documentation Requirements for Each Member

### What to Document
1. **Feature Overview:** Brief description of assigned features
2. **Technical Implementation:**
   - State management approach
   - Database schema used
   - API integrations
   - Offline handling strategy
3. **Code Structure:**
   - File organization
   - Key classes and methods
   - Data flow diagrams
4. **UI/UX:**
   - Screenshots of screens
   - User flow diagrams
   - Design decisions
5. **Challenges & Solutions:**
   - Technical challenges faced
   - How they were resolved
6. **Testing:**
   - Test cases covered
   - Edge cases handled

---

## Collaboration Points

### Shared Responsibilities
- **Firestore Service:** All members use `firestore_service.dart`
- **Models:** Shared data models across features
- **Constants:** Common configuration values
- **Utilities:** Shared helper functions

### Integration Points
- Member 1 (Auth) → All members need user authentication
- Member 2 (Courses) → Member 3 (Quizzes), Member 4 (Notes)
- Member 3 (Progress) → Member 2 (Courses), Member 3 (Quizzes)
- Member 4 (Notifications) → All members for updates

---

## Estimated Lines of Code per Member

### Member 1 (Auth & Profile)
- **Frontend:** ~800 lines
- **Providers:** ~12,000 lines
- **Models/Utils:** ~300 lines
- **Total:** ~13,100 lines

### Member 2 (Courses & Lessons)
- **Frontend:** ~1,200 lines
- **Providers:** ~13,000 lines
- **Widgets:** ~14,000 lines
- **Total:** ~28,200 lines

### Member 3 (Quiz & Progress)
- **Frontend:** ~600 lines
- **Providers:** ~9,200 lines
- **Widgets:** ~6,200 lines
- **Total:** ~16,000 lines

### Member 4 (Notes, AI, Notifications, Settings)
- **Frontend:** ~1,100 lines
- **Providers:** ~13,500 lines
- **Services:** ~200 lines
- **Widgets:** ~7,400 lines
- **Total:** ~22,200 lines

### Shared Core
- **Services:** ~600 lines
- **Models:** ~800 lines
- **Utils:** ~200 lines
- **Main:** ~200 lines
- **Total:** ~1,800 lines

**Grand Total:** ~81,300 lines of code

---

## Conclusion

This distribution ensures each member has:
- **Balanced workload** (~13,000-28,000 lines each)
- **Mix of frontend and backend** work
- **Both online and offline** features
- **Complete feature ownership** from UI to database
- **Clear documentation scope**

Each member should focus on their assigned features while coordinating on shared components and integration points.
