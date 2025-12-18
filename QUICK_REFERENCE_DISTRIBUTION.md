# Quick Reference - Feature Distribution Table

## Member Assignment Overview

| Member | Primary Features | Frontend Pages | Key Files | Lines of Code |
|--------|-----------------|----------------|-----------|---------------|
| **Member 1** | Authentication & User Management | 4 pages | 5 files | ~13,100 |
| **Member 2** | Courses & Lessons | 5 pages | 8 files | ~28,200 |
| **Member 3** | Quiz & Progress | 2 pages | 6 files | ~16,000 |
| **Member 4** | Notes, AI, Notifications, Settings | 4 pages | 12 files | ~22,200 |

---

## Detailed Breakdown

### 👤 Member 1: Authentication & User Management

#### Features
- ✅ User Registration & Login (Online)
- ✅ Profile Management (Hybrid)
- ✅ Password Reset (Online)
- ✅ Session Management (Hybrid)

#### Frontend Pages (4)
1. `LoginScreen` - User login interface
2. `RegisterScreen` - New user registration
3. `ProfileScreen` - View user profile
4. `EditProfileScreen` - Edit profile details

#### Key Files (5)
| File | Type | Size | Purpose |
|------|------|------|---------|
| `auth_provider.dart` | Provider | 12,142 bytes | Authentication logic |
| `user_model.dart` | Model | ~200 bytes | User data structure |
| `validators.dart` | Utility | ~150 bytes | Input validation |
| `login_screen.dart` | UI | ~400 lines | Login interface |
| `register_screen.dart` | UI | ~400 lines | Registration interface |

#### Technical Stack
- Firebase Authentication
- Provider state management
- Form validation
- Secure token storage

---

### 📚 Member 2: Courses & Lessons

#### Features
- ✅ Course Browsing (Hybrid)
- ✅ Course Enrollment (Online)
- ✅ Lesson Viewing (Hybrid)
- ✅ Course Search & Filter (Offline)
- ✅ My Courses (Hybrid)

#### Frontend Pages (5)
1. `HomeScreen` - Dashboard with course overview
2. `CoursesScreen` - Browse all courses
3. `MyCoursesScreen` - View enrolled courses
4. `CourseDetailScreen` - Course details & lessons
5. `LessonViewerScreen` - View lesson content

#### Key Files (8)
| File | Type | Size | Purpose |
|------|------|------|---------|
| `course_provider.dart` | Provider | 9,108 bytes | Course state management |
| `lesson_provider.dart` | Provider | 3,936 bytes | Lesson state management |
| `student_provider.dart` | Provider | 4,196 bytes | Student data management |
| `course_model.dart` | Model | ~300 bytes | Course data structure |
| `lesson_model.dart` | Model | ~250 bytes | Lesson data structure |
| `course_card.dart` | Widget | 8,938 bytes | Course card component |
| `lesson_content_viewer.dart` | Widget | 5,482 bytes | Lesson content renderer |
| `firestore_service.dart` (courses) | Service | ~100 lines | Course database ops |

#### Technical Stack
- Firestore real-time streams
- Offline persistence
- Content caching
- Progress tracking integration

---

### 📝 Member 3: Quiz & Progress Tracking

#### Features
- ✅ Quiz Taking (Hybrid)
- ✅ Quiz Submission (Online)
- ✅ Score Calculation (Client-side)
- ✅ Progress Tracking (Hybrid)
- ✅ Completion Percentage (Offline)
- ✅ Quiz History (Hybrid)

#### Frontend Pages (2)
1. `QuizScreen` - Take quizzes
2. `ProgressScreen` - View learning progress

#### Key Files (6)
| File | Type | Size | Purpose |
|------|------|------|---------|
| `quiz_provider.dart` | Provider | 6,320 bytes | Quiz state management |
| `progress_provider.dart` | Provider | 2,908 bytes | Progress tracking |
| `quiz_model.dart` | Model | ~400 bytes | Quiz data structure |
| `progress_model.dart` | Model | ~200 bytes | Progress data structure |
| `quiz_option_button.dart` | Widget | 3,295 bytes | Quiz option UI |
| `progress_indicator_widget.dart` | Widget | 2,969 bytes | Progress visualization |

#### Technical Stack
- Client-side quiz logic
- Score calculation algorithms
- Progress analytics
- Visual progress indicators

---

### 🤖 Member 4: Notes, AI, Notifications & Settings

#### Features
- ✅ Note Taking (Hybrid)
- ✅ AI Chatbot (Online)
- ✅ Notifications (Hybrid)
- ✅ Settings & Theme (Offline)
- ✅ Note Search (Offline)
- ✅ AI Study Tips (Online)

#### Frontend Pages (4)
1. `NotesScreen` - Create/view notes
2. `ChatbotScreen` - AI assistant chat
3. `NotificationsScreen` - View notifications
4. `SettingsScreen` - App settings

#### Key Files (12)
| File | Type | Size | Purpose |
|------|------|------|---------|
| `notes_provider.dart` | Provider | 4,523 bytes | Notes state management |
| `chatbot_provider.dart` | Provider | 3,835 bytes | Chat state management |
| `notification_provider.dart` | Provider | 4,818 bytes | Notification management |
| `theme_provider.dart` | Provider | 3,134 bytes | Theme management |
| `locale_provider.dart` | Provider | 1,281 bytes | Language management |
| `chatbot_service.dart` | Service | 111 lines | Gemini AI integration |
| `notification_service.dart` | Service | ~150 lines | FCM integration |
| `note_model.dart` | Model | ~250 bytes | Note data structure |
| `chat_message_model.dart` | Model | ~150 bytes | Chat message structure |
| `notification_model.dart` | Model | ~200 bytes | Notification structure |
| `chat_message_bubble.dart` | Widget | 2,281 bytes | Chat UI component |
| `note_editor.dart` | Widget | 5,095 bytes | Note editor component |

#### Technical Stack
- Google Gemini AI API
- Firebase Cloud Messaging
- Real-time chat interface
- Theme persistence
- Note search algorithms

---

## Admin Features Distribution

| Member | Admin Feature | Screen | Functionality |
|--------|--------------|--------|---------------|
| **Member 1** | User Management | `user_management_screen.dart` | View/Edit/Delete users |
| **Member 2** | Course & Lesson Mgmt | `course_management_screen.dart`<br>`lesson_management_screen.dart`<br>`add_lesson_screen.dart` | CRUD courses & lessons |
| **Member 3** | Quiz Mgmt & Reports | `quiz_management_screen.dart`<br>`add_quiz_screen.dart`<br>`reports_screen.dart` | CRUD quizzes, analytics |
| **Member 4** | Dashboard & Notifications | `admin_dashboard_screen.dart`<br>`send_notification_screen.dart`<br>`admin_notifications_screen.dart` | Overview, send notifications |

---

## Offline vs Online Features

### 🔴 Online-Only Features
| Feature | Member | Reason |
|---------|--------|--------|
| Login/Register | Member 1 | Firebase Auth requires connection |
| AI Chatbot | Member 4 | Gemini API is cloud-based |
| Course Enrollment | Member 2 | Real-time database update |
| Quiz Submission | Member 3 | Server-side validation |
| Send Notifications | Member 4 | FCM requires connection |

### 🟡 Hybrid Features (Work Offline with Cached Data)
| Feature | Member | Offline Capability |
|---------|--------|-------------------|
| Profile Viewing | Member 1 | View cached profile data |
| Course Browsing | Member 2 | View cached courses |
| Lesson Viewing | Member 2 | View downloaded lessons |
| Quiz Taking | Member 3 | Take quiz, submit later |
| Progress Viewing | Member 3 | View cached progress |
| Notes | Member 4 | Full CRUD, syncs later |
| Notifications | Member 4 | View cached notifications |

### 🟢 Fully Offline Features
| Feature | Member | Details |
|---------|--------|---------|
| Note Search | Member 4 | Client-side search |
| Theme Toggle | Member 4 | Local preference |
| Settings | Member 4 | Stored locally |
| Progress Calculation | Member 3 | Client-side computation |

---

## File Structure Reference

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart (Shared)
│   │   └── api_endpoints.dart (Shared)
│   ├── models/
│   │   ├── user_model.dart (Member 1)
│   │   ├── course_model.dart (Member 2)
│   │   ├── lesson_model.dart (Member 2)
│   │   ├── quiz_model.dart (Member 3)
│   │   ├── progress_model.dart (Member 3)
│   │   ├── note_model.dart (Member 4)
│   │   ├── chat_message_model.dart (Member 4)
│   │   └── notification_model.dart (Member 4)
│   ├── services/
│   │   ├── firestore_service.dart (Shared)
│   │   ├── api_service.dart (Shared)
│   │   ├── chatbot_service.dart (Member 4)
│   │   ├── notification_service.dart (Member 4)
│   │   └── notification_helper.dart (Member 4)
│   └── utils/
│       ├── validators.dart (Member 1)
│       ├── connectivity_helper.dart (Shared)
│       └── date_formatter.dart (Shared)
├── features/
│   ├── auth/ (Member 1)
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── profile/ (Member 1)
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   ├── home/ (Member 2)
│   │   └── home_screen.dart
│   ├── courses/ (Member 2)
│   │   ├── courses_screen.dart
│   │   ├── my_courses_screen.dart
│   │   └── course_detail_screen.dart
│   ├── lessons/ (Member 2)
│   │   └── lesson_viewer_screen.dart
│   ├── quiz/ (Member 3)
│   │   └── quiz_screen.dart
│   ├── progress/ (Member 3)
│   │   └── progress_screen.dart
│   ├── notes/ (Member 4)
│   │   └── notes_screen.dart
│   ├── chatbot/ (Member 4)
│   │   └── chatbot_screen.dart
│   ├── notifications/ (Member 4)
│   │   └── notifications_screen.dart
│   ├── settings/ (Member 4)
│   │   └── settings_screen.dart
│   └── admin/
│       ├── admin_dashboard_screen.dart (Member 4)
│       ├── user_management_screen.dart (Member 1)
│       ├── course_management_screen.dart (Member 2)
│       ├── lesson_management_screen.dart (Member 2)
│       ├── add_lesson_screen.dart (Member 2)
│       ├── quiz_management_screen.dart (Member 3)
│       ├── add_quiz_screen.dart (Member 3)
│       ├── reports_screen.dart (Member 3)
│       ├── send_notification_screen.dart (Member 4)
│       └── admin_notifications_screen.dart (Member 4)
├── providers/
│   ├── auth_provider.dart (Member 1)
│   ├── course_provider.dart (Member 2)
│   ├── lesson_provider.dart (Member 2)
│   ├── student_provider.dart (Member 2)
│   ├── quiz_provider.dart (Member 3)
│   ├── progress_provider.dart (Member 3)
│   ├── notes_provider.dart (Member 4)
│   ├── chatbot_provider.dart (Member 4)
│   ├── notification_provider.dart (Member 4)
│   ├── theme_provider.dart (Member 4)
│   ├── locale_provider.dart (Member 4)
│   └── admin_provider.dart (Shared)
├── widgets/
│   ├── course_card.dart (Member 2)
│   ├── lesson_content_viewer.dart (Member 2)
│   ├── quiz_option_button.dart (Member 3)
│   ├── progress_indicator_widget.dart (Member 3)
│   ├── note_editor.dart (Member 4)
│   └── chat_message_bubble.dart (Member 4)
└── main.dart (Shared)
```

---

## Integration Dependencies

### Member 1 Dependencies
- **Provides to all:** User authentication state
- **Used by:** All members for user ID and authentication

### Member 2 Dependencies
- **Depends on:** Member 1 (user authentication)
- **Provides to:** Member 3 (course/lesson IDs), Member 4 (course context for notes)

### Member 3 Dependencies
- **Depends on:** Member 1 (user ID), Member 2 (course/lesson IDs)
- **Provides to:** Member 2 (progress data for courses)

### Member 4 Dependencies
- **Depends on:** Member 1 (user ID), Member 2 (course context)
- **Provides to:** All members (notifications about updates)

---

## Testing Checklist per Member

### Member 1 Testing
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Register new user
- [ ] Password validation
- [ ] Profile view
- [ ] Profile edit
- [ ] Logout functionality
- [ ] Session persistence

### Member 2 Testing
- [ ] View all courses
- [ ] Search courses
- [ ] Enroll in course
- [ ] View course details
- [ ] View lessons
- [ ] Navigate between lessons
- [ ] Mark lesson complete
- [ ] Offline course access

### Member 3 Testing
- [ ] Load quiz questions
- [ ] Select quiz answers
- [ ] Submit quiz
- [ ] View quiz results
- [ ] Check passing/failing logic
- [ ] View progress dashboard
- [ ] Progress percentage calculation
- [ ] Quiz history

### Member 4 Testing
- [ ] Create note
- [ ] Edit note
- [ ] Delete note
- [ ] Search notes
- [ ] Send chat message
- [ ] Receive AI response
- [ ] View notifications
- [ ] Mark notification as read
- [ ] Toggle theme
- [ ] Change settings
- [ ] Offline note sync

---

## Documentation Template for Each Member

### Section 1: Feature Overview
- Brief description of assigned features
- User stories/use cases
- Feature importance

### Section 2: Technical Implementation
**Architecture:**
- State management approach
- Data flow diagrams
- Component hierarchy

**Database Schema:**
- Firestore collections used
- Document structure
- Relationships

**API Integration:**
- External APIs used
- Request/response formats
- Error handling

**Offline Strategy:**
- What works offline
- Sync mechanism
- Conflict resolution

### Section 3: Code Walkthrough
**Key Classes:**
- Provider classes with methods
- Model classes with fields
- Service classes with functions

**Important Methods:**
- Method signatures
- Parameters and return types
- Business logic explanation

**UI Components:**
- Screen layouts
- Widget tree structure
- User interactions

### Section 4: Screenshots & Diagrams
- Screen mockups
- User flow diagrams
- Sequence diagrams
- ER diagrams

### Section 5: Challenges & Solutions
- Technical challenges encountered
- Solutions implemented
- Lessons learned

### Section 6: Testing
- Test cases
- Edge cases
- Test results

---

## Workload Balance Analysis

| Metric | Member 1 | Member 2 | Member 3 | Member 4 |
|--------|----------|----------|----------|----------|
| **Frontend Pages** | 4 | 5 | 2 | 4 |
| **Providers** | 1 | 3 | 2 | 5 |
| **Services** | 0 | 0 | 0 | 3 |
| **Models** | 1 | 2 | 2 | 3 |
| **Widgets** | 0 | 2 | 2 | 2 |
| **Admin Screens** | 1 | 3 | 3 | 3 |
| **Total Files** | 7 | 15 | 11 | 20 |
| **Lines of Code** | 13,100 | 28,200 | 16,000 | 22,200 |
| **Complexity** | Medium | High | Medium | High |

### Complexity Factors
- **Member 1:** Authentication logic, security considerations
- **Member 2:** Most UI screens, content management, offline sync
- **Member 3:** Quiz logic, score calculation, progress analytics
- **Member 4:** AI integration, multiple providers, real-time features

---

## Key Technologies per Member

### Member 1
- Firebase Authentication
- Form validation
- Secure storage
- Session management

### Member 2
- Firestore queries
- Real-time streams
- Content rendering
- Offline persistence

### Member 3
- Quiz algorithms
- Progress calculation
- Data visualization
- Analytics

### Member 4
- Google Gemini AI
- Firebase Cloud Messaging
- Theme management
- Search algorithms

---

## Recommended Documentation Tools

1. **Diagrams:** draw.io, Lucidchart, Figma
2. **Screenshots:** Built-in screen capture, Snagit
3. **Code Documentation:** Dartdoc comments
4. **API Documentation:** Postman, Swagger
5. **Collaboration:** Google Docs, Notion, Confluence

---

## Final Notes

- Each member has a balanced mix of frontend and backend work
- All members work with both online and offline features
- Clear separation of concerns with minimal overlap
- Shared components facilitate collaboration
- Admin features distributed to match main feature expertise

**Total Project Size:** ~81,300 lines of code  
**Average per Member:** ~20,325 lines of code  
**Development Time Estimate:** 4-6 weeks per member
