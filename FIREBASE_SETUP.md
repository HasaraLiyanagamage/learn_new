# Firebase Setup Guide

## Current Issue

The app is showing "An error occurred during login/registration" because Firebase Authentication needs to be properly configured with test users.

## Solution Options

### Option 1: Use Demo Mode (Quick Testing)
1. On the login screen, click **"Continue as Demo User"** button
2. This bypasses authentication and lets you explore the app
3. Perfect for testing UI and features without backend setup

### Option 2: Create Test Users in Firebase Console

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com/
   - Select your project: `learninghub-9c489`

2. **Enable Email/Password Authentication:**
   - Go to **Authentication** → **Sign-in method**
   - Click on **Email/Password**
   - Enable it and save

3. **Create Test Users:**
   - Go to **Authentication** → **Users**
   - Click **Add User**
   - Create test accounts:
     - **Student Account:**
       - Email: `student@test.com`
       - Password: `123456`
     - **Admin Account:**
       - Email: `admin@test.com`
       - Password: `123456`

4. **Add User Roles in Firestore:**
   - Go to **Firestore Database**
   - Create a collection named `users`
   - Add documents with the user IDs from Authentication:
     
     **Student Document:**
     ```json
     {
       "id": "<user_id_from_auth>",
       "email": "student@test.com",
       "name": "Test Student",
       "role": "student",
       "createdAt": "<current_timestamp>",
       "updatedAt": "<current_timestamp>"
     }
     ```
     
     **Admin Document:**
     ```json
     {
       "id": "<user_id_from_auth>",
       "email": "admin@test.com",
       "name": "Test Admin",
       "role": "admin",
       "createdAt": "<current_timestamp>",
       "updatedAt": "<current_timestamp>"
     }
     ```

### Option 3: Use the Registration Screen

1. Click **"Register"** on the login screen
2. Fill in the form:
   - Full Name: `Your Name`
   - Email: `your@email.com`
   - Phone: `1234567890` (optional)
   - Role: Select **Student** or **Admin**
   - Password: At least 6 characters
3. Click **Register**
4. The account will be created in Firebase
5. Go back and login with the credentials

## Firestore Security Rules

Make sure your Firestore has proper security rules. For development/testing, you can use:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users (for testing)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ Warning:** These rules allow any authenticated user to read/write all data. Use more restrictive rules in production.

## Production Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Courses are readable by all authenticated users
    match /courses/{courseId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Lessons are readable by all authenticated users
    match /lessons/{lessonId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notes are private to each user
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
    }
    
    // Progress is private to each user
    match /progress/{progressId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
    }
  }
}
```

## Testing the App

### With Demo Mode:
1. Click "Continue as Demo User"
2. Explore all features
3. Note: Data won't persist as there's no real user session

### With Real Authentication:
1. Create a test account (Option 2 or 3 above)
2. Login with the credentials
3. All features will work with real Firebase backend
4. Data will persist in Firestore

## Common Errors and Solutions

### Error: "An error occurred during login"
**Causes:**
- User doesn't exist in Firebase
- Wrong password
- Email/Password auth not enabled

**Solutions:**
- Use Demo Mode for testing
- Create user in Firebase Console
- Enable Email/Password authentication

### Error: "An error occurred during registration"
**Causes:**
- Email already exists
- Weak password (< 6 characters)
- Firebase connection issues

**Solutions:**
- Use a different email
- Use a stronger password
- Check internet connection

### Error: "Failed to load FirebaseOptions"
**Causes:**
- google-services.json not properly configured
- Package name mismatch

**Solutions:**
- Already fixed in the codebase
- Package name is now: `com.example.learninghub`

## Backend API Setup (Optional)

The app is designed to work with a REST API backend. The API endpoints are defined in:
`lib/core/constants/api_endpoints.dart`

Base URL: `https://us-central1-learninghub-9c489.cloudfunctions.net/api`

To set up the backend:
1. Deploy Firebase Cloud Functions
2. Implement the API endpoints
3. Update the base URL if needed

For now, the app works with Firestore directly for most features.

## Next Steps

1. **For Quick Testing:** Use Demo Mode
2. **For Full Testing:** Create test users in Firebase Console
3. **For Production:** Implement proper security rules and backend API
4. **For Development:** Use Firebase Emulator Suite for local testing

## Support

If you encounter any issues:
1. Check the Flutter console for detailed error messages
2. Verify Firebase configuration in Firebase Console
3. Ensure internet connection is active
4. Try Demo Mode to isolate authentication issues
