# Smart Learning Assistant - Group Project Distribution (Part 1)

## Project Overview
**App Name:** Smart Learning Assistant  
**Type:** AI-Powered Mobile Learning Platform  
**Technology Stack:** Flutter, Firebase (Firestore, Auth, Messaging), Google Gemini AI  
**Total Group Members:** 4

---

## 📊 Feature Distribution Summary

| Member | Features | Frontend Pages | Offline/Online | Lines of Code |
|--------|----------|----------------|----------------|---------------|
| **Member 1** | Authentication & User Management | 4 screens | Both | ~1,200 |
| **Member 2** | Course Management & Enrollment | 4 screens | Both | ~1,300 |
| **Member 3** | Lessons, Quizzes & Progress Tracking | 5 screens | Both | ~1,400 |
| **Member 4** | AI Chatbot, Notes & Notifications | 4 screens | Both | ~1,100 |

---

# 👤 MEMBER 1: Authentication & User Management

## Assigned Features

### 1. **User Authentication System** (Online)
- Email/Password authentication
- Google Sign-In integration
- Session management
- Token-based authentication
- Auto-login with saved credentials

### 2. **User Profile Management** (Both Offline & Online)
- View user profile
- Edit profile information
- Update profile picture
- Change password
- Account settings
- Offline profile caching

### 3. **Settings & Preferences** (Both Offline & Online)
- Theme settings (Light/Dark mode)
- Language/Locale preferences
- Notification preferences
- App settings management
- Offline settings persistence

---

## Frontend Pages (4 Screens)

### 1. **Login Screen** (`login_screen.dart`)
**Purpose:** User authentication entry point

**UI Components:**
- Email input field with validation
- Password input field with visibility toggle
- "Login" button
- "Forgot Password?" link
- "Sign in with Google" button
- "Don't have an account? Register" link
- Loading indicator during authentication
- Error message display

**Key Functionality:**
```dart
- Email/password validation
- Firebase Authentication integration
- Google Sign-In flow
- Error handling (invalid credentials, network errors)
- Navigation to home screen on success
- Remember me functionality
```

**Offline/Online:**
- **Online Required:** Authentication requires internet
- **Offline Fallback:** Shows cached user data if previously logged in

---

### 2. **Register Screen** (`register_screen.dart`)
**Purpose:** New user account creation

**UI Components:**
- Full name input field
- Email input field with validation
- Password input field with strength indicator
- Confirm password field
- Role selection (Student/Admin)
- "Create Account" button
- "Already have an account? Login" link
- Terms & conditions checkbox
- Loading indicator

**Key Functionality:**
```dart
- Form validation (name, email, password match)
- Password strength checking
- Firebase user creation
- Firestore user document creation
- Automatic login after registration
- Email verification (optional)
```

**Offline/Online:**
- **Online Required:** Account creation needs internet

---

### 3. **Profile Screen** (`profile_screen.dart`)
**Purpose:** Display user information and statistics

**UI Components:**
- Profile picture with edit option
- User name and email display
- Role badge (Student/Admin)
- Statistics cards:
  - Enrolled courses count
  - Completed courses count
  - Total quiz scores
  - Learning streak
- "Edit Profile" button
- "Settings" button
- "Logout" button

**Key Functionality:**
```dart
- Fetch user data from Firestore
- Display user statistics
- Navigate to edit profile
- Navigate to settings
- Logout functionality
- Real-time data updates
```

**Offline/Online:**
- **Offline:** Displays cached profile data
- **Online:** Syncs with Firestore for latest data

---

### 4. **Edit Profile Screen** (`edit_profile_screen.dart`)
**Purpose:** Modify user information

**UI Components:**
- Editable name field
- Editable email field
- Profile picture upload
- Bio/description text area
- "Save Changes" button
- "Cancel" button
- Loading indicator during save

**Key Functionality:**
```dart
- Pre-fill form with current user data
- Validate input fields
- Update Firestore user document
- Image upload handling
- Success/error notifications
- Navigate back on save
```

**Offline/Online:**
- **Offline:** Changes queued for sync
- **Online:** Immediate Firestore update

---

## Related Coding Files

### Core Files (6 files)

#### 1. **`lib/providers/auth_provider.dart`** (~580 lines)
**Purpose:** State management for authentication

**Key Code Components:**
```dart
class AuthProvider extends ChangeNotifier {
  // User state management
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Methods:
  - login(email, password)          // Email/password login
  - loginWithGoogle()               // Google Sign-In
  - register(userData)              // Create new account
  - logout()                        // Sign out user
  - updateProfile(userData)         // Update user info
  - resetPassword(email)            // Password reset
  - checkAuthState()                // Auto-login check
  - _saveUserLocally()              // Cache user data
  - _loadUserFromCache()            // Load cached data
}
```

**Offline/Online Logic:**
- Saves user credentials to SharedPreferences
- Loads cached user on app start
- Syncs with Firebase when online

---

#### 2. **`lib/providers/theme_provider.dart`** (~105 lines)
**Purpose:** Theme management (Light/Dark mode)

**Key Code Components:**
```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  // Theme definitions
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // ... theme configuration
  );
  
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    // ... theme configuration
  );
  
  // Methods:
  - toggleTheme()                   // Switch theme
  - setThemeMode(mode)              // Set specific theme
  - _saveThemePreference()          // Save to storage
  - _loadThemePreference()          // Load from storage
}
```

---

#### 3. **`lib/providers/locale_provider.dart`** (~43 lines)
**Purpose:** Language/locale management

**Key Code Components:**
```dart
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  
  // Methods:
  - setLocale(locale)               // Change language
  - _saveLocale()                   // Save preference
  - _loadLocale()                   // Load preference
}
```

---

#### 4. **`lib/core/models/user_model.dart`** (~78 lines)
**Purpose:** User data model

**Key Code Components:**
```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;              // 'student' or 'admin'
  final String? profilePicture;
  final String? bio;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  // Methods:
  - fromJson(json)                  // Parse from Firestore
  - toJson()                        // Convert to Firestore
  - copyWith()                      // Create modified copy
}
```

---

#### 5. **`lib/core/services/firestore_service.dart`** (User-related methods)
**Relevant Methods:**
```dart
// User CRUD operations
- createUser(userId, userData)      // Create user document
- getUser(userId)                   // Fetch user data
- updateUser(userId, userData)      // Update user info
- deleteUser(userId)                // Delete user account
- getAllUsers()                     // Admin: fetch all users
- getStudentsCount()                // Get student count
```

---

#### 6. **`lib/features/settings/settings_screen.dart`** (~280 lines)
**Purpose:** App settings and preferences

**UI Components:**
- Theme toggle (Light/Dark)
- Language selector
- Notification settings
- Cache management
- About app section
- Version information

**Key Functionality:**
```dart
- Theme switching
- Language selection
- Clear cache option
- Notification preferences
- App version display
```

---

## Database Schema (Firestore)

### Users Collection
```json
{
  "users": {
    "userId123": {
      "name": "John Doe",
      "email": "john@example.com",
      "role": "student",
      "profilePicture": "url_to_image",
      "bio": "Computer Science student",
      "createdAt": "2025-01-01T00:00:00Z",
      "lastLoginAt": "2025-12-18T10:00:00Z",
      "preferences": {
        "theme": "dark",
        "language": "en",
        "notifications": true
      }
    }
  }
}
```

---

## Technical Implementation Details

### Authentication Flow
1. **User opens app** → Check cached credentials
2. **If cached** → Auto-login with Firebase token
3. **If not cached** → Show login screen
4. **User enters credentials** → Validate locally
5. **Submit to Firebase** → Authenticate
6. **On success** → Create/update Firestore user document
7. **Save locally** → Cache credentials
8. **Navigate** → Home screen

### Google Sign-In Flow
1. **User clicks Google button** → Initialize GoogleSignIn
2. **Show Google account picker** → User selects account
3. **Get Google credentials** → Exchange for Firebase token
4. **Authenticate with Firebase** → Create user session
5. **Check Firestore** → Create user document if new
6. **Navigate** → Home screen

### Offline Capabilities
- **SharedPreferences** stores:
  - User ID
  - User name
  - Email
  - Role
  - Theme preference
  - Language preference
  - Last login timestamp

---

## Dependencies Used
```yaml
# Authentication
firebase_auth: ^6.0.0
google_sign_in: ^6.2.1

# State Management
provider: ^6.1.1

# Local Storage
shared_preferences: ^2.2.2

# Firebase Core
firebase_core: ^4.0.0
cloud_firestore: ^6.0.0
```

---

## Testing Checklist
- ✅ Email/password login
- ✅ Google Sign-In
- ✅ Registration with validation
- ✅ Profile viewing
- ✅ Profile editing
- ✅ Theme switching
- ✅ Language selection
- ✅ Logout functionality
- ✅ Offline profile caching
- ✅ Auto-login on app restart

---

# 📚 MEMBER 2: Course Management & Enrollment

## Assigned Features

### 1. **Course Browsing & Discovery** (Both Offline & Online)
- View all available courses
- Search courses by name
- Filter courses by category
- Sort courses (rating, popularity, newest)
- View course details
- Offline course caching

### 2. **Course Enrollment System** (Online)
- Enroll in courses
- View enrolled courses
- Unenroll from courses
- Track enrollment status
- Enrollment notifications

### 3. **Course Rating & Reviews** (Online)
- Rate courses (1-5 stars)
- Write course reviews
- View course ratings
- Edit/delete own ratings
- Calculate average ratings

### 4. **Course Favorites** (Both Offline & Online)
- Add courses to favorites
- Remove from favorites
- View favorite courses list
- Sync favorites across devices

---

## Frontend Pages (4 Screens)

### 1. **Courses Screen** (`courses_screen.dart`)
**Purpose:** Browse and discover all available courses

**UI Components:**
- Search bar with real-time filtering
- Category filter chips (Programming, Math, Science, etc.)
- Sort dropdown (Rating, Newest, Popular)
- Course grid/list view
- Course cards showing:
  - Course thumbnail image
  - Course title
  - Category badge
  - Rating (stars)
  - Enrollment count
  - "Enroll" button
- Loading indicators
- Empty state message
- Pull-to-refresh

**Key Functionality:**
```dart
- Fetch courses from Firestore
- Real-time search filtering
- Category filtering
- Sort by multiple criteria
- Navigate to course detail
- Enroll button action
- Offline course caching
- Stream updates for real-time data
```

**Offline/Online:**
- **Offline:** Shows cached courses
- **Online:** Real-time updates from Firestore

---

### 2. **My Courses Screen** (`my_courses_screen.dart`)
**Purpose:** View enrolled courses and progress

**UI Components:**
- Tab bar (All, In Progress, Completed)
- Enrolled course cards showing:
  - Course thumbnail
  - Course title
  - Progress bar (percentage)
  - Last accessed date
  - "Continue Learning" button
  - Favorite heart icon
- Completion badges
- Statistics summary:
  - Total enrolled
  - In progress
  - Completed
- Empty state for no enrollments
- Pull-to-refresh

**Key Functionality:**
```dart
- Fetch user's enrolled courses
- Filter by completion status
- Display progress percentage
- Calculate completion stats
- Navigate to course detail
- Show last accessed timestamp
- Sync with progress data
```

**Offline/Online:**
- **Offline:** Shows cached enrolled courses
- **Online:** Syncs progress and enrollment data

---

### 3. **Course Detail Screen** (`course_detail_screen.dart`)
**Purpose:** Detailed course information and content access

**UI Components:**
- App bar with:
  - Back button
  - Course title
  - Favorite heart icon
- Course header (gradient background):
  - Course image
  - Title
  - Category badge
  - Rating stars
  - Enrollment count
- "About this course" section:
  - Description
  - What you'll learn
  - Prerequisites
- Enrollment button (if not enrolled)
- Course completion button (if eligible)
- Completion badge (if completed)
- Progress card:
  - Progress bar
  - Lessons completed count
  - Quizzes completed count
  - Overall percentage
- Lessons list:
  - Lesson title
  - Duration
  - Completion checkmark
  - "Start" or "Continue" button
- Quizzes list:
  - Quiz title
  - Questions count
  - Best score
  - "Take Quiz" button
- Rating section:
  - Average rating display
  - "Rate this course" button
  - User reviews list

**Key Functionality:**
```dart
- Fetch course details from Firestore
- Check enrollment status
- Handle enrollment action
- Toggle favorite status
- Display progress tracking
- Navigate to lessons
- Navigate to quizzes
- Show/submit ratings
- Mark course as complete
- Real-time updates
```

**Offline/Online:**
- **Offline:** Cached course content, queued actions
- **Online:** Real-time sync, enrollment, ratings

---

### 4. **Admin Course Management Screen** (`course_management_screen.dart`)
**Purpose:** Admin interface for managing courses

**UI Components:**
- "Add New Course" floating action button
- Course list with:
  - Course thumbnail
  - Title and category
  - Enrollment count
  - Edit button
  - Delete button
  - Manage lessons button
- Search bar
- Filter options
- Course statistics:
  - Total courses
  - Total enrollments
  - Average rating
- Add/Edit course dialog:
  - Title input
  - Description textarea
  - Category dropdown
  - Image URL input
  - Prerequisites input
  - "Save" button

**Key Functionality:**
```dart
- Fetch all courses (admin view)
- Create new course
- Edit existing course
- Delete course (with confirmation)
- Navigate to lesson management
- View course statistics
- Real-time course updates
```

**Offline/Online:**
- **Online Required:** Admin operations need internet

---

## Related Coding Files

### Core Files (8 files)

#### 1. **`lib/providers/course_provider.dart`** (~305 lines)
**Purpose:** Course state management

**Key Code Components:**
```dart
class CourseProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  List<CourseModel> _enrolledCourses = [];
  List<CourseModel> _favoriteCourses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  
  // Methods:
  - fetchCoursesStream()            // Real-time course updates
  - fetchCourses()                  // One-time fetch
  - fetchEnrolledCourses(userId)    // User's courses
  - enrollCourse(userId, courseId)  // Enroll action
  - unenrollCourse(userId, courseId)// Unenroll action
  - searchCourses(query)            // Filter by search
  - filterByCategory(category)      // Filter by category
  - sortCourses(sortBy)             // Sort courses
  - toggleFavorite(userId, courseId)// Add/remove favorite
  - fetchFavoriteCourses(userId)    // Get favorites
  - getCourseById(courseId)         // Single course
  - _cacheCourses()                 // Save offline
  - _loadCachedCourses()            // Load offline
}
```

**Offline/Online Logic:**
- Caches course list to local storage
- Loads cached data when offline
- Queues enrollment actions for sync
- Real-time Firestore streams when online

---

#### 2. **`lib/core/models/course_model.dart`** (~113 lines)
**Purpose:** Course data structure

**Key Code Components:**
```dart
class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final double rating;
  final int enrollmentCount;
  final List<String> prerequisites;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Methods:
  - fromJson(json)                  // Parse from Firestore
  - toJson()                        // Convert to Firestore
  - copyWith()                      // Create modified copy
}
```

---

#### 3. **`lib/core/models/rating_model.dart`** (~73 lines)
**Purpose:** Course rating data structure

**Key Code Components:**
```dart
class RatingModel {
  final String id;
  final String userId;
  final String courseId;
  final double rating;              // 1-5 stars
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Methods:
  - fromJson(json)
  - toJson()
  - copyWith()
}
```

---

## Database Schema (Firestore)

### Courses Collection
```json
{
  "courses": {
    "courseId123": {
      "title": "Introduction to Flutter",
      "description": "Learn Flutter app development...",
      "category": "Programming",
      "imageUrl": "https://example.com/image.jpg",
      "rating": 4.5,
      "enrollmentCount": 150,
      "prerequisites": ["Basic programming knowledge"],
      "createdBy": "adminId",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-12-18T10:00:00Z"
    }
  }
}
```

### Ratings Collection
```json
{
  "ratings": {
    "ratingId123": {
      "userId": "user123",
      "courseId": "course456",
      "rating": 5.0,
      "review": "Excellent course! Highly recommended.",
      "createdAt": "2025-12-18T10:00:00Z",
      "updatedAt": null
    }
  }
}
```

### Favorites Collection
```json
{
  "favorites": {
    "favoriteId123": {
      "userId": "user123",
      "courseId": "course456",
      "addedAt": "2025-12-18T10:00:00Z"
    }
  }
}
```

---

## Dependencies Used
```yaml
# Firebase
cloud_firestore: ^6.0.0

# State Management
provider: ^6.1.1

# UI Components
cached_network_image: ^3.3.1

# Local Storage
shared_preferences: ^2.2.2
```

---

## Testing Checklist
- ✅ Browse all courses
- ✅ Search courses
- ✅ Filter by category
- ✅ Enroll in course
- ✅ View enrolled courses
- ✅ Rate course
- ✅ Add to favorites
- ✅ Remove from favorites
- ✅ Admin: Create course
- ✅ Admin: Edit course
- ✅ Admin: Delete course
- ✅ Offline course viewing
