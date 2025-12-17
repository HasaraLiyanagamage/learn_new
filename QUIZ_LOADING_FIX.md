# Quiz Loading Fix

## Problem
Quizzes were not loading for students, showing "Quiz not found" error.

## Root Cause
The quiz provider was only trying to fetch quizzes from the API service, which is not running. There was no Firestore fallback, so all quiz fetches failed.

---

## Solution

Added Firestore fallback to quiz fetching methods with comprehensive error handling and debug logging.

---

## Changes Made

### File: `lib/providers/quiz_provider.dart`

#### 1. Fixed `fetchQuizById()` Method

**Before:**
```dart
Future<void> fetchQuizById(String quizId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await ApiService.getQuiz(quizId);
    _currentQuiz = QuizModel.fromJson(response);
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

**After:**
```dart
Future<void> fetchQuizById(String quizId) async {
  print('📝 Fetching quiz by ID: $quizId');
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // Try API first
    try {
      final response = await ApiService.getQuiz(quizId);
      _currentQuiz = QuizModel.fromJson(response);
      print('✅ Quiz loaded from API: ${_currentQuiz?.title}');
    } catch (apiError) {
      print('⚠️ API failed, trying Firestore: $apiError');
      // Fallback to Firestore
      final doc = await FirestoreService.getDocument('quizzes', quizId);
      if (doc.exists) {
        _currentQuiz = QuizModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
        print('✅ Quiz loaded from Firestore: ${_currentQuiz?.title}');
      } else {
        print('❌ Quiz not found in Firestore');
        throw Exception('Quiz not found');
      }
    }
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    print('❌ Error fetching quiz: $e');
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

#### 2. Fixed `fetchQuizzesByLesson()` Method

**Before:**
```dart
Future<void> fetchQuizzesByLesson(String lessonId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await ApiService.getQuizzesByLesson(lessonId);
    _lessonQuizzes = response.map((json) => QuizModel.fromJson(json)).toList();
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

**After:**
```dart
Future<void> fetchQuizzesByLesson(String lessonId) async {
  print('📝 Fetching quizzes for lesson: $lessonId');
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // Try API first
    try {
      final response = await ApiService.getQuizzesByLesson(lessonId);
      _lessonQuizzes = response.map((json) => QuizModel.fromJson(json)).toList();
      print('✅ Loaded ${_lessonQuizzes.length} quizzes from API');
    } catch (apiError) {
      print('⚠️ API failed, trying Firestore: $apiError');
      // Fallback to Firestore
      final snapshot = await FirestoreService.getCollection(
        'quizzes',
        queryBuilder: (query) => query.where('lessonId', isEqualTo: lessonId),
      );
      _lessonQuizzes = snapshot.docs
          .map((doc) => QuizModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
      print('✅ Loaded ${_lessonQuizzes.length} quizzes from Firestore');
    }
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    print('❌ Error fetching quizzes: $e');
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

### File: `lib/features/quiz/quiz_screen.dart`

#### Enhanced Error Display

**Added:**
- Error state with detailed error message
- Retry button for failed quiz loads
- Quiz ID display for debugging
- Go Back button when quiz not found

**Before:**
```dart
if (quiz == null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Quiz Not Found')),
    body: const Center(child: Text('Quiz not found')),
  );
}
```

**After:**
```dart
if (quizProvider.error != null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${quizProvider.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<QuizProvider>().fetchQuizById(widget.quizId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

if (quiz == null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Quiz Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Quiz not found'),
          const SizedBox(height: 8),
          Text('Quiz ID: ${widget.quizId}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    ),
  );
}
```

---

## How It Works Now

### Quiz Loading Flow

1. **Student clicks on a quiz**
2. **Quiz provider tries API first**
   - Console: `📝 Fetching quiz by ID: [quizId]`
3. **If API fails (no backend running)**
   - Console: `⚠️ API failed, trying Firestore`
4. **Fetches from Firestore**
   - Queries `quizzes` collection by document ID
5. **If found in Firestore**
   - Console: `✅ Quiz loaded from Firestore: [Quiz Title]`
   - Quiz screen displays quiz
6. **If not found**
   - Console: `❌ Quiz not found in Firestore`
   - Shows "Quiz not found" with retry button

---

## Console Output

### Successful Load (Firestore):
```
📝 Fetching quiz by ID: abc123xyz
⚠️ API failed, trying Firestore: [API error]
✅ Quiz loaded from Firestore: Introduction to Flutter
```

### Quiz Not Found:
```
📝 Fetching quiz by ID: abc123xyz
⚠️ API failed, trying Firestore: [API error]
❌ Quiz not found in Firestore
❌ Error fetching quiz: Exception: Quiz not found
```

### Successful Load (API):
```
📝 Fetching quiz by ID: abc123xyz
✅ Quiz loaded from API: Introduction to Flutter
```

---

## Testing

### Test 1: Load Quiz from Course
1. Open a course with quizzes
2. Click on a quiz
3. Check console for:
   ```
   📝 Fetching quiz by ID: [quizId]
   ✅ Quiz loaded from Firestore: [Quiz Title]
   ```
4. Verify quiz displays correctly

### Test 2: Quiz Not Found
1. Navigate to a quiz with invalid ID
2. Check console for error messages
3. Verify "Quiz not found" screen shows
4. Verify "Go Back" button works

### Test 3: Retry on Error
1. Turn off internet
2. Try to load a quiz
3. Verify error screen shows
4. Turn on internet
5. Click "Retry" button
6. Verify quiz loads

---

## Troubleshooting

### Issue: Quiz Still Not Loading

#### Check 1: Quiz Exists in Firestore
1. Open Firebase Console
2. Go to Firestore Database
3. Check `quizzes` collection
4. Verify quiz document exists with correct ID

#### Check 2: Quiz ID is Correct
1. Check console for: `📝 Fetching quiz by ID: [quizId]`
2. Verify the quiz ID matches Firestore document ID

#### Check 3: Quiz Data Structure
Ensure quiz document has required fields:
```json
{
  "id": "quiz123",
  "title": "Quiz Title",
  "description": "Quiz description",
  "lessonId": "lesson123",
  "courseId": "course123",
  "questions": [...],
  "duration": 30,
  "passingScore": 70,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

#### Check 4: Firestore Rules
Ensure students can read quizzes:
```
match /quizzes/{quizId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
                  get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

---

## Benefits

1. **Offline Support**: Quizzes load from Firestore even without backend API
2. **Better Error Handling**: Clear error messages and retry options
3. **Debug Logging**: Easy to track quiz loading in console
4. **User Feedback**: Students see what's happening (loading, error, not found)
5. **Graceful Degradation**: Falls back to Firestore if API fails

---

## Data Flow

```
Student clicks quiz
        ↓
Quiz Provider: fetchQuizById(quizId)
        ↓
Try API Service
        ↓
    [API fails]
        ↓
Try Firestore
        ↓
Query: quizzes/{quizId}
        ↓
    [Found]
        ↓
Parse QuizModel
        ↓
Display Quiz Screen
```

---

## Related Files

- `lib/providers/quiz_provider.dart` - Quiz fetching logic
- `lib/features/quiz/quiz_screen.dart` - Quiz display UI
- `lib/core/services/firestore_service.dart` - Firestore queries
- `lib/core/models/quiz_model.dart` - Quiz data model

---

## Future Enhancements

1. **Cache Quizzes**: Store loaded quizzes in memory
2. **Prefetch**: Load quizzes when course is opened
3. **Offline Mode**: Full offline quiz support with local storage
4. **Progress Indicator**: Show which step of loading process
5. **Better Error Messages**: More specific error types

---

## Summary

✅ **Firestore Fallback**: Quizzes now load from Firestore when API unavailable  
✅ **Error Handling**: Clear error messages with retry option  
✅ **Debug Logging**: Track quiz loading in console  
✅ **Better UX**: Loading states, error states, not found states  
✅ **Offline Support**: Works without backend API  

**Quizzes should now load properly for students!** 📝
