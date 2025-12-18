# Smart Learning Assistant - Group Project Distribution (Part 2)

# 📖 MEMBER 3: Lessons, Quizzes & Progress Tracking

## Assigned Features

### 1. **Lesson Management** (Both Offline & Online)
- View course lessons
- Read lesson content
- Mark lessons as complete
- Navigate between lessons
- Offline lesson caching
- Video/text content support

### 2. **Quiz System** (Both Offline & Online)
- Take quizzes
- Multiple choice questions
- True/False questions
- Submit quiz answers
- View quiz results
- Retry failed quizzes
- Quiz history tracking
- Offline quiz caching

### 3. **Progress Tracking** (Both Offline & Online)
- Track lesson completion
- Track quiz scores
- Calculate course progress
- View progress statistics
- Progress visualization (charts)
- Real-time progress updates
- Offline progress sync

### 4. **Admin Lesson & Quiz Management** (Online)
- Create/edit lessons
- Create/edit quizzes
- Add quiz questions
- Manage lesson order
- Delete lessons/quizzes

---

## Frontend Pages (5 Screens)

### 1. **Lesson Viewer Screen** (`lesson_viewer_screen.dart`)
**Purpose:** Display and interact with lesson content

**UI Components:**
- App bar with:
  - Back button
  - Lesson title
  - Bookmark icon
- Lesson content area:
  - Text content (formatted)
  - Code snippets (syntax highlighted)
  - Images
  - Videos (if applicable)
  - Bullet points
  - Headings
- Bottom navigation:
  - "Previous Lesson" button
  - "Mark as Complete" button
  - "Next Lesson" button
- Progress indicator (lesson X of Y)
- Reading time estimate
- Completion checkmark

**Key Functionality:**
```dart
- Fetch lesson content from Firestore
- Render formatted content
- Mark lesson as complete
- Update progress in real-time
- Navigate to next/previous lesson
- Save reading position
- Offline content caching
- Auto-scroll to saved position
```

**Offline/Online:**
- **Offline:** Cached lesson content available
- **Online:** Syncs completion status

---

### 2. **Quiz Screen** (`quiz_screen.dart`)
**Purpose:** Interactive quiz taking interface

**UI Components:**
- App bar with:
  - Back button (with confirmation)
  - Quiz title
  - Timer (if timed)
- Progress indicator:
  - Question X of Y
  - Progress bar
- Question display:
  - Question text
  - Question number
  - Points value
- Answer options:
  - Multiple choice buttons (A, B, C, D)
  - True/False buttons
  - Radio button selection
  - Selected state highlighting
- Navigation buttons:
  - "Previous" button
  - "Next" button
  - "Submit Quiz" button (last question)
- Question navigator (grid view):
  - All questions overview
  - Answered/unanswered indicators
  - Jump to specific question

**Key Functionality:**
```dart
- Fetch quiz questions from Firestore
- Display questions one at a time
- Track selected answers
- Validate answer selection
- Calculate score
- Submit quiz results
- Show results screen
- Save quiz attempt history
- Prevent multiple submissions
- Timer countdown (if applicable)
```

**Offline/Online:**
- **Offline:** Quiz questions cached, answers queued
- **Online:** Submit results to Firestore

---

### 3. **Progress Screen** (`progress_screen.dart`)
**Purpose:** Comprehensive progress tracking dashboard

**UI Components:**
- Statistics cards:
  - Total courses enrolled
  - Courses completed
  - Total lessons completed
  - Total quizzes taken
  - Average quiz score
  - Learning streak (days)
- Progress charts:
  - Course completion pie chart
  - Quiz scores line chart
  - Weekly activity bar chart
  - Category-wise progress
- Course progress list:
  - Each enrolled course with:
    - Course name
    - Progress bar
    - Completion percentage
    - Last accessed date
    - "Continue" button
- Achievements section:
  - Badges earned
  - Milestones reached
  - Completion certificates
- Time period filter:
  - This week
  - This month
  - All time

**Key Functionality:**
```dart
- Fetch all progress data
- Calculate statistics
- Generate charts using fl_chart
- Display course-wise progress
- Show quiz history
- Track learning streaks
- Real-time updates
- Export progress report
```

**Offline/Online:**
- **Offline:** Cached progress data
- **Online:** Real-time sync with Firestore

---

### 4. **Admin Lesson Management Screen** (`lesson_management_screen.dart`)
**Purpose:** Admin interface for lesson CRUD

**UI Components:**
- Course header:
  - Course name
  - Total lessons count
- "Add New Lesson" floating action button
- Lessons list:
  - Lesson order number
  - Lesson title
  - Duration
  - Edit button
  - Delete button
  - Reorder handle (drag to reorder)
- Add/Edit lesson dialog:
  - Title input
  - Content textarea (rich text)
  - Order number input
  - Duration input
  - Video URL input (optional)
  - "Save" button

**Key Functionality:**
```dart
- Fetch lessons for specific course
- Create new lesson
- Edit existing lesson
- Delete lesson (with confirmation)
- Reorder lessons (drag & drop)
- Navigate to quiz management
- Real-time lesson updates
```

**Offline/Online:**
- **Online Required:** Admin operations need internet

---

### 5. **Admin Quiz Management Screen** (`quiz_management_screen.dart`)
**Purpose:** Admin interface for quiz CRUD

**UI Components:**
- Lesson header:
  - Lesson name
  - Total quizzes count
- "Add New Quiz" floating action button
- Quizzes list:
  - Quiz title
  - Questions count
  - Passing score
  - Edit button
  - Delete button
- Add/Edit quiz dialog:
  - Title input
  - Passing score input (percentage)
  - Questions list:
    - Question text
    - Answer options (A, B, C, D)
    - Correct answer selector
    - Add/Remove question buttons
  - "Save" button

**Key Functionality:**
```dart
- Fetch quizzes for specific lesson
- Create new quiz with questions
- Edit existing quiz
- Delete quiz (with confirmation)
- Manage quiz questions
- Set passing score
- Real-time quiz updates
```

**Offline/Online:**
- **Online Required:** Admin operations need internet

---

## Related Coding Files

### Core Files (10 files)

#### 1. **`lib/providers/lesson_provider.dart`** (~132 lines)
**Purpose:** Lesson state management

**Key Code Components:**
```dart
class LessonProvider extends ChangeNotifier {
  List<LessonModel> _lessons = [];
  LessonModel? _currentLesson;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Methods:
  - fetchLessonsByCourse(courseId)  // Get course lessons
  - fetchLessonsByCourseStream(courseId) // Real-time
  - getLessonById(lessonId)         // Single lesson
  - markLessonComplete(userId, lessonId, courseId) // Complete
  - getNextLesson(currentLessonId)  // Navigate next
  - getPreviousLesson(currentLessonId) // Navigate prev
  - _cacheLessons(courseId)         // Save offline
  - _loadCachedLessons(courseId)    // Load offline
}
```

---

#### 2. **`lib/providers/quiz_provider.dart`** (~212 lines)
**Purpose:** Quiz state management

**Key Code Components:**
```dart
class QuizProvider extends ChangeNotifier {
  List<QuizModel> _quizzes = [];
  QuizModel? _currentQuiz;
  Map<int, String> _selectedAnswers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  int? _score;
  
  // Methods:
  - fetchQuizzesByLesson(lessonId)  // Get lesson quizzes
  - startQuiz(quizId)               // Initialize quiz
  - selectAnswer(questionIndex, answer) // Save answer
  - nextQuestion()                  // Navigate next
  - previousQuestion()              // Navigate previous
  - submitQuiz(userId, quizId)      // Submit answers
  - calculateScore()                // Calculate result
  - resetQuiz()                     // Clear state
  - _cacheQuizzes(lessonId)         // Save offline
  - _loadCachedQuizzes(lessonId)    // Load offline
}
```

---

#### 3. **`lib/providers/progress_provider.dart`** (~97 lines)
**Purpose:** Progress tracking state management

**Key Code Components:**
```dart
class ProgressProvider extends ChangeNotifier {
  Map<String, ProgressModel> _progressMap = {};
  bool _isLoading = false;
  
  // Methods:
  - fetchProgressByUser(userId)     // Get all progress
  - fetchProgressByCourse(userId, courseId) // Course progress
  - updateProgress(progressData)    // Update progress
  - calculateProgressPercentage(courseId) // Calculate %
  - getCompletedLessons(courseId)   // Get completed list
  - getCompletedQuizzes(courseId)   // Get quiz scores
  - markCourseComplete(userId, courseId) // Complete course
  - _cacheProgress()                // Save offline
  - _loadCachedProgress()           // Load offline
}
```

---

#### 4. **`lib/core/models/lesson_model.dart`** (~90 lines)
**Purpose:** Lesson data structure

**Key Code Components:**
```dart
class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final int order;
  final int duration;              // in minutes
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
}
```

---

#### 5. **`lib/core/models/quiz_model.dart`** (~217 lines)
**Purpose:** Quiz and question data structures

**Key Code Components:**
```dart
class QuizModel {
  final String id;
  final String lessonId;
  final String title;
  final List<QuizQuestion> questions;
  final int passingScore;          // percentage
  final DateTime createdAt;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
}

class QuizQuestion {
  final String question;
  final List<String> options;      // A, B, C, D
  final String correctAnswer;
  final String? explanation;
  
  // Methods:
  - fromJson(json)
  - toJson()
}
```

---

#### 6. **`lib/core/models/progress_model.dart`** (~97 lines)
**Purpose:** Progress tracking data structure

**Key Code Components:**
```dart
class ProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final List<String> completedLessons;
  final List<String> completedQuizzes;
  final Map<String, int> quizScores; // quizId: score
  final int totalLessons;
  final int totalQuizzes;
  final double progressPercentage;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final DateTime enrolledAt;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
  - calculateProgress()            // Calculate percentage
}
```

---

#### 7. **`lib/widgets/lesson_content_viewer.dart`** (~183 lines)
**Purpose:** Formatted lesson content display widget

**Key Code Components:**
```dart
class LessonContentViewer extends StatelessWidget {
  final String content;
  final String? videoUrl;
  
  // Features:
  - Parse markdown-style content
  - Display formatted text
  - Render code blocks
  - Show images
  - Embed videos
  - Syntax highlighting
  - Responsive layout
}
```

---

#### 8. **`lib/widgets/quiz_option_button.dart`** (~110 lines)
**Purpose:** Quiz answer option button widget

**Key Code Components:**
```dart
class QuizOptionButton extends StatelessWidget {
  final String option;
  final String label;              // A, B, C, D
  final bool isSelected;
  final bool showCorrect;
  final bool isCorrect;
  final VoidCallback onTap;
  
  // Features:
  - Interactive button
  - Selected state
  - Correct/incorrect indicators
  - Smooth animations
  - Accessibility support
}
```

---

#### 9. **`lib/widgets/progress_indicator_widget.dart`** (~99 lines)
**Purpose:** Visual progress indicator widget

**Key Code Components:**
```dart
class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;           // 0.0 to 1.0
  final String label;
  final Color? color;
  
  // Features:
  - Circular progress indicator
  - Linear progress bar
  - Percentage display
  - Animated transitions
  - Customizable colors
}
```

---

#### 10. **`lib/core/services/firestore_service.dart`** (Lesson/Quiz/Progress methods)
**Relevant Methods:**
```dart
// Lesson operations
- getLessonsByCourse(courseId)      // Fetch lessons
- getLessonsByCourseStream(courseId) // Real-time
- getLesson(lessonId)               // Single lesson
- createLesson(lessonData)          // Add lesson
- updateLesson(lessonId, data)      // Edit lesson
- deleteLesson(lessonId)            // Remove lesson

// Quiz operations
- getQuizzesByLesson(lessonId)      // Fetch quizzes
- getQuizzesByLessonStream(lessonId) // Real-time
- getQuiz(quizId)                   // Single quiz
- createQuiz(quizData)              // Add quiz
- updateQuiz(quizId, data)          // Edit quiz
- deleteQuiz(quizId)                // Remove quiz

// Progress operations
- getProgressByUser(userId)         // User progress
- getProgressByUserStream(userId)   // Real-time
- getProgress(progressId)           // Single progress
- createProgress(progressId, data)  // Initialize
- updateProgress(progressId, data)  // Update progress

// Quiz results
- createQuizResult(resultId, data)  // Save result
- getQuizResultsByUser(userId)      // User results
```

---

## Database Schema (Firestore)

### Lessons Collection
```json
{
  "lessons": {
    "lessonId123": {
      "courseId": "course456",
      "title": "Introduction to Variables",
      "content": "Variables are containers for storing data...",
      "order": 1,
      "duration": 15,
      "videoUrl": "https://youtube.com/watch?v=xyz",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": null
    }
  }
}
```

### Quizzes Collection
```json
{
  "quizzes": {
    "quizId123": {
      "lessonId": "lesson456",
      "title": "Variables Quiz",
      "questions": [
        {
          "question": "What is a variable?",
          "options": ["A container", "A function", "A loop", "A class"],
          "correctAnswer": "A container",
          "explanation": "Variables store data values."
        }
      ],
      "passingScore": 70,
      "createdAt": "2025-01-01T00:00:00Z"
    }
  }
}
```

### Progress Collection
```json
{
  "progress": {
    "progressId123": {
      "userId": "user123",
      "courseId": "course456",
      "completedLessons": ["lesson1", "lesson2"],
      "completedQuizzes": ["quiz1"],
      "quizScores": {
        "quiz1": 85,
        "quiz2": 90
      },
      "totalLessons": 10,
      "totalQuizzes": 5,
      "progressPercentage": 30.0,
      "isCompleted": false,
      "completedAt": null,
      "lastAccessedAt": "2025-12-18T10:00:00Z",
      "enrolledAt": "2025-12-01T00:00:00Z"
    }
  }
}
```

### Quiz Results Collection
```json
{
  "quiz_results": {
    "resultId123": {
      "userId": "user123",
      "quizId": "quiz456",
      "courseId": "course789",
      "score": 85,
      "totalQuestions": 10,
      "correctAnswers": 8,
      "answers": {
        "0": "A container",
        "1": "True",
        "2": "Option C"
      },
      "passed": true,
      "submittedAt": "2025-12-18T10:00:00Z"
    }
  }
}
```

---

## Technical Implementation Details

### Lesson Completion Flow
1. **User opens lesson** → Fetch lesson content
2. **Read lesson** → Track reading time
3. **Click "Mark Complete"** → Validate action
4. **Update progress** → Add to completedLessons array
5. **Recalculate percentage** → Update progressPercentage
6. **Show next lesson** → Navigate automatically

### Quiz Taking Flow
1. **User starts quiz** → Fetch quiz questions
2. **Display first question** → Show options
3. **User selects answer** → Save to state
4. **Navigate questions** → Previous/Next buttons
5. **Submit quiz** → Calculate score
6. **Save result** → Create quiz_result document
7. **Update progress** → Add to completedQuizzes
8. **Show results** → Display score and review

### Progress Calculation
```dart
progressPercentage = (
  (completedLessons.length / totalLessons) * 0.5 +
  (completedQuizzes.length / totalQuizzes) * 0.5
) * 100
```

### Offline Sync Strategy
- **Lessons cached** after first load
- **Quiz questions cached** before starting
- **Answers queued** when offline
- **Progress synced** on reconnection
- **Quiz results submitted** when online

---

## Dependencies Used
```yaml
# Firebase
cloud_firestore: ^6.0.0

# State Management
provider: ^6.1.1

# Charts
fl_chart: ^0.69.0

# Local Storage
shared_preferences: ^2.2.2
```

---

## Testing Checklist
- ✅ View lesson content
- ✅ Mark lesson complete
- ✅ Navigate between lessons
- ✅ Start quiz
- ✅ Answer questions
- ✅ Submit quiz
- ✅ View quiz results
- ✅ Retry failed quiz
- ✅ View progress dashboard
- ✅ Track completion percentage
- ✅ Admin: Create lesson
- ✅ Admin: Edit lesson
- ✅ Admin: Delete lesson
- ✅ Admin: Create quiz
- ✅ Admin: Edit quiz
- ✅ Offline lesson viewing
- ✅ Offline quiz taking

---

# 🤖 MEMBER 4: AI Chatbot, Notes & Notifications

## Assigned Features

### 1. **AI Chatbot Assistant** (Online)
- Chat with AI learning assistant
- Ask questions about courses
- Get study tips
- Concept explanations
- Course recommendations
- Chat history
- Google Gemini AI integration

### 2. **Notes Management** (Both Offline & Online)
- Create personal notes
- Edit notes
- Delete notes
- Search notes
- Organize by course/topic
- Rich text formatting
- Offline note creation
- Sync notes across devices

### 3. **Notification System** (Both Offline & Online)
- Receive push notifications
- View notification history
- Mark notifications as read
- Delete notifications
- Notification categories (course, quiz, system)
- Offline notification queue
- Firebase Cloud Messaging

### 4. **Admin Notification Management** (Online)
- Send notifications to users
- Broadcast to all students
- Target specific users
- Schedule notifications
- View notification history
- Notification templates

---

## Frontend Pages (4 Screens)

### 1. **Chatbot Screen** (`chatbot_screen.dart`)
**Purpose:** AI-powered learning assistant chat interface

**UI Components:**
- App bar with:
  - Back button
  - "AI Learning Assistant" title
  - Clear chat option (menu)
- Chat message list:
  - User messages (right-aligned, blue)
  - AI messages (left-aligned, gray)
  - Timestamp for each message
  - Loading indicator for AI response
  - Error message display
- Message input area:
  - Text input field
  - Send button
  - Microphone button (optional)
- Quick action chips:
  - "Explain a concept"
  - "Study tips"
  - "Course recommendations"
  - "Quiz help"
- Empty state:
  - Welcome message
  - Suggested questions

**Key Functionality:**
```dart
- Send message to Google Gemini AI
- Display chat history
- Real-time message streaming
- Error handling (API errors, network)
- Clear chat history
- Save chat to local storage
- Auto-scroll to latest message
- Typing indicator
- Quick action buttons
```

**Offline/Online:**
- **Online Required:** AI requires internet connection
- **Offline:** Shows cached chat history, queues messages

---

### 2. **Notes Screen** (`notes_screen.dart`)
**Purpose:** Personal note-taking and management

**UI Components:**
- App bar with:
  - Back button
  - "My Notes" title
  - Search icon
  - Add note button
- Search bar (expandable)
- Notes list/grid:
  - Note card showing:
    - Title
    - Preview text (first 2 lines)
    - Last updated date
    - Course tag (if linked)
    - Color indicator
  - Tap to open
  - Long press for options
- Floating action button:
  - "Add New Note" (plus icon)
- Empty state:
  - "No notes yet" message
  - "Create your first note" button
- Filter options:
  - All notes
  - By course
  - Recent
  - Favorites

**Key Functionality:**
```dart
- Fetch user notes from Firestore
- Create new note
- Edit existing note
- Delete note (with confirmation)
- Search notes by title/content
- Filter notes by course
- Sort notes (date, title)
- Pin important notes
- Offline note creation
- Sync notes when online
```

**Offline/Online:**
- **Offline:** Create/edit notes locally
- **Online:** Sync with Firestore

---

### 3. **Notifications Screen** (`notifications_screen.dart`)
**Purpose:** View and manage notifications

**UI Components:**
- App bar with:
  - Back button
  - "Notifications" title
  - Mark all read button
  - Filter icon
- Notification list:
  - Notification card showing:
    - Icon (based on type)
    - Title
    - Body text
    - Timestamp
    - Read/unread indicator
    - Tap to view details
  - Swipe to delete
  - Unread badge
- Filter tabs:
  - All
  - Unread
  - Course updates
  - Quiz reminders
  - System
- Empty state:
  - "No notifications" message
  - Illustration

**Key Functionality:**
```dart
- Fetch user notifications from Firestore
- Display notifications list
- Mark notification as read
- Mark all as read
- Delete notification
- Filter by type
- Navigate to related content (course, quiz)
- Real-time notification updates
- Push notification handling
```

**Offline/Online:**
- **Offline:** Shows cached notifications
- **Online:** Real-time updates via FCM

---

### 4. **Admin Send Notification Screen** (`send_notification_screen.dart`)
**Purpose:** Admin interface to send notifications

**UI Components:**
- App bar with:
  - Back button
  - "Send Notification" title
- Notification form:
  - Title input field
  - Body textarea
  - Type selector:
    - Course update
    - Quiz reminder
    - System announcement
  - Target selector:
    - All students
    - Specific course students
    - Individual users
  - Course selector (if course-specific)
  - User selector (if individual)
  - Schedule option:
    - Send now
    - Schedule for later (date/time picker)
  - "Send Notification" button
- Preview section:
  - Shows how notification will appear
- Notification history:
  - Recently sent notifications
  - Delivery status

**Key Functionality:**
```dart
- Create notification
- Select recipients
- Send to all students
- Send to course students
- Send to specific users
- Schedule notification
- Preview notification
- View sent notifications
- Track delivery status
```

**Offline/Online:**
- **Online Required:** Sending requires internet

---

## Related Coding Files

### Core Files (12 files)

#### 1. **`lib/providers/chatbot_provider.dart`** (~142 lines)
**Purpose:** Chatbot state management

**Key Code Components:**
```dart
class ChatbotProvider extends ChangeNotifier {
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Methods:
  - sendMessage(userId, message)    // Send to AI
  - clearChat()                     // Clear history
  - loadChatHistory(userId)         // Load saved chats
  - saveChatHistory(userId)         // Save to storage
  - clearError()                    // Clear error state
  - _addUserMessage(message)        // Add user msg
  - _addAIMessage(message)          // Add AI response
  - _cacheMessages()                // Save offline
  - _loadCachedMessages()           // Load offline
}
```

---

#### 2. **`lib/providers/notes_provider.dart`** (~151 lines)
**Purpose:** Notes state management

**Key Code Components:**
```dart
class NotesProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  
  // Methods:
  - fetchNotesByUser(userId)        // Get user notes
  - fetchNotesStream(userId)        // Real-time updates
  - createNote(noteData)            // Create new note
  - updateNote(noteId, noteData)    // Edit note
  - deleteNote(noteId)              // Remove note
  - searchNotes(query)              // Filter by search
  - filterByCourse(courseId)        // Filter by course
  - pinNote(noteId)                 // Pin important note
  - _cacheNotes()                   // Save offline
  - _loadCachedNotes()              // Load offline
  - _queueNoteAction(action)        // Queue for sync
}
```

---

#### 3. **`lib/providers/notification_provider.dart`** (~161 lines)
**Purpose:** Notification state management

**Key Code Components:**
```dart
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  
  // Methods:
  - fetchNotificationsByUser(userId) // Get notifications
  - fetchNotificationsStream(userId) // Real-time
  - markAsRead(notificationId)      // Mark read
  - markAllAsRead(userId)           // Mark all read
  - deleteNotification(notificationId) // Delete
  - getUnreadCount()                // Count unread
  - filterByType(type)              // Filter notifications
  - _cacheNotifications()           // Save offline
  - _loadCachedNotifications()      // Load offline
}
```

---

#### 4. **`lib/core/services/chatbot_service.dart`** (~131 lines)
**Purpose:** Google Gemini AI integration

**Key Code Components:**
```dart
class ChatbotService {
  static GenerativeModel? _model;
  
  // Initialization
  - initialize()                    // Setup Gemini model
  
  // AI Methods:
  - sendMessage(message)            // Send to AI
  - getCourseRecommendations(interests) // Get recommendations
  - explainConcept(concept)         // Explain topic
  - getStudyTips(topic)             // Study advice
  
  // Error Handling:
  - API key validation
  - Quota limit handling
  - Network error handling
  - Safety filter handling
}
```

**API Configuration:**
```dart
// Uses Google Generative AI package
- Model: gemini-pro
- API Key: Stored in app_constants.dart
- Context-aware prompts
- Streaming responses
```

---

#### 5. **`lib/core/services/notification_service.dart`** (~93 lines)
**Purpose:** Firebase Cloud Messaging setup

**Key Code Components:**
```dart
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Initialization
  - initialize()                    // Setup FCM
  - requestPermission()             // Ask user permission
  - getToken()                      // Get FCM token
  
  // Handlers:
  - onMessageReceived(message)      // Foreground notification
  - onMessageOpenedApp(message)     // Background tap
  - onBackgroundMessage(message)    // Background notification
  
  // Local Notifications:
  - showLocalNotification(title, body) // Display notification
}
```

---

#### 6. **`lib/core/services/notification_helper.dart`** (~115 lines)
**Purpose:** Local notification handling

**Key Code Components:**
```dart
class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin;
  
  // Methods:
  - initialize()                    // Setup local notifications
  - showNotification(id, title, body) // Display notification
  - scheduleNotification(id, title, body, time) // Schedule
  - cancelNotification(id)          // Cancel scheduled
  - cancelAllNotifications()        // Cancel all
}
```

---

#### 7. **`lib/core/models/chat_message_model.dart`** (~37 lines)
**Purpose:** Chat message data structure

**Key Code Components:**
```dart
class ChatMessageModel {
  final String id;
  final String userId;
  final String message;
  final bool isUser;               // true = user, false = AI
  final DateTime timestamp;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
}
```

---

#### 8. **`lib/core/models/note_model.dart`** (~73 lines)
**Purpose:** Note data structure

**Key Code Components:**
```dart
class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? courseId;
  final List<String> tags;
  final String color;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
}
```

---

#### 9. **`lib/core/models/notification_model.dart`** (~63 lines)
**Purpose:** Notification data structure

**Key Code Components:**
```dart
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;               // course, quiz, system
  final String? relatedId;         // courseId or quizId
  final bool isRead;
  final DateTime createdAt;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
}
```

---

#### 10. **`lib/widgets/chat_message_bubble.dart`** (~76 lines)
**Purpose:** Chat message bubble widget

**Key Code Components:**
```dart
class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isUser;
  
  // Features:
  - User messages (right, blue)
  - AI messages (left, gray)
  - Timestamp display
  - Avatar icon
  - Smooth animations
  - Copy message option
}
```

---

#### 11. **`lib/widgets/note_editor.dart`** (~170 lines)
**Purpose:** Rich text note editor widget

**Key Code Components:**
```dart
class NoteEditor extends StatefulWidget {
  final NoteModel? note;
  final Function(NoteModel) onSave;
  
  // Features:
  - Rich text editing
  - Formatting toolbar
  - Auto-save
  - Course linking
  - Tag management
  - Color picker
}
```

---

#### 12. **`lib/features/admin/admin_notifications_screen.dart`** (~250 lines)
**Purpose:** Admin notification history view

**Key Functionality:**
```dart
- View all sent notifications
- Filter by date/type
- View delivery statistics
- Resend notifications
- Delete notification history
```

---

## Database Schema (Firestore)

### Notes Collection
```json
{
  "notes": {
    "noteId123": {
      "userId": "user123",
      "title": "Flutter Basics",
      "content": "Flutter is a UI toolkit...",
      "courseId": "course456",
      "tags": ["flutter", "mobile", "programming"],
      "color": "#FFEB3B",
      "isPinned": false,
      "createdAt": "2025-12-01T00:00:00Z",
      "updatedAt": "2025-12-18T10:00:00Z"
    }
  }
}
```

### Notifications Collection
```json
{
  "notifications": {
    "notificationId123": {
      "userId": "user123",
      "title": "New Course Available",
      "body": "Check out the new Flutter course!",
      "type": "course",
      "relatedId": "course456",
      "isRead": false,
      "createdAt": "2025-12-18T10:00:00Z"
    }
  }
}
```

### Chat Messages (Local Storage - SharedPreferences)
```json
{
  "chatMessages_user123": [
    {
      "id": "msg123",
      "userId": "user123",
      "message": "Explain variables in programming",
      "isUser": true,
      "timestamp": "2025-12-18T10:00:00Z"
    },
    {
      "id": "msg124",
      "userId": "user123",
      "message": "Variables are containers...",
      "isUser": false,
      "timestamp": "2025-12-18T10:00:05Z"
    }
  ]
}
```

---

## Technical Implementation Details

### AI Chatbot Flow
1. **User types message** → Input field
2. **Click send** → Add to chat history (user message)
3. **Show loading** → Typing indicator
4. **Send to Gemini API** → ChatbotService.sendMessage()
5. **Receive AI response** → Parse response
6. **Add to chat** → Display AI message
7. **Save locally** → Cache chat history
8. **Handle errors** → Show error message

### Notes Sync Flow
1. **User creates note offline** → Save to local storage
2. **Queue action** → Add to sync queue
3. **App goes online** → Detect connectivity
4. **Process queue** → Upload to Firestore
5. **Sync complete** → Remove from queue
6. **Update UI** → Show synced status

### Notification Flow
1. **Admin sends notification** → Create in Firestore
2. **FCM triggered** → Firebase Cloud Messaging
3. **Device receives** → NotificationService handles
4. **Show notification** → Local notification displayed
5. **User taps** → Navigate to related content
6. **Mark as read** → Update Firestore

### Offline Capabilities
- **Chat history** cached in SharedPreferences
- **Notes** saved locally, synced when online
- **Notifications** cached for offline viewing
- **Queued actions** processed on reconnection

---

## Dependencies Used
```yaml
# AI Integration
google_generative_ai: ^0.4.6

# Firebase
cloud_firestore: ^6.0.0
firebase_messaging: ^16.0.0

# Notifications
flutter_local_notifications: ^19.5.0

# State Management
provider: ^6.1.1

# Local Storage
shared_preferences: ^2.2.2

# Network
connectivity_plus: ^7.0.0
```

---

## Testing Checklist
- ✅ Send message to AI chatbot
- ✅ Receive AI response
- ✅ Clear chat history
- ✅ Create note
- ✅ Edit note
- ✅ Delete note
- ✅ Search notes
- ✅ Filter notes by course
- ✅ Receive push notification
- ✅ View notifications
- ✅ Mark notification as read
- ✅ Delete notification
- ✅ Admin: Send notification to all
- ✅ Admin: Send to specific course
- ✅ Offline note creation
- ✅ Offline chat history viewing
- ✅ Sync notes when online

---

## Summary of Member 4 Contribution

**Total Lines of Code:** ~1,100 lines

**Key Technologies:**
- Google Gemini AI for chatbot
- Firebase Cloud Messaging for push notifications
- SharedPreferences for offline storage
- Firestore for notes and notifications

**Unique Features:**
- AI-powered learning assistant
- Rich text note editor
- Real-time push notifications
- Offline-first note-taking

**Integration Points:**
- Chatbot helps with course content
- Notes can be linked to courses
- Notifications for course/quiz updates
- Admin can broadcast to all students
