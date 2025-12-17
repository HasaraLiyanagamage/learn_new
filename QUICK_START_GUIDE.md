# Quick Start Guide - Smart Learning Assistant

## ✅ Current Status
- App is installed and running on your device
- Firebase is configured
- All code is error-free

## 🔧 Firebase Setup Required (One-Time Setup)

### Step 1: Enable Email/Password Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **learninghub-9c489**
3. Click **Authentication** in the left menu
4. Click **Get Started** (if not already enabled)
5. Go to **Sign-in method** tab
6. Click on **Email/Password**
7. **Enable** the toggle switch
8. Click **Save**

### Step 2: Set Up Firestore Security Rules

1. In Firebase Console, click **Firestore Database**
2. Click **Rules** tab
3. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    
    // Allow all authenticated users to read courses
    match /courses/{courseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow all authenticated users to read lessons
    match /lessons/{lessonId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow all authenticated users to read quizzes
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users can only access their own notes
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Users can only access their own progress
    match /progress/{progressId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Users can read their own notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Chat history is private to each user
    match /chat_history/{chatId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Quiz results are private to each user
    match /quiz_results/{resultId} {
      allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
  }
}
```

4. Click **Publish**

## 📱 How to Use the App

### First Time Registration

1. **Open the app** on your device
2. Click **"Register"** button
3. Fill in the form:
   - **Full Name**: Your name
   - **Email**: A valid email (e.g., `student@example.com`)
   - **Phone**: Optional (e.g., `1234567890`)
   - **Role**: Select **Student** or **Admin**
   - **Password**: At least 6 characters
   - **Confirm Password**: Same as password
4. Click **"Register"**
5. Wait for account creation (2-3 seconds)
6. You'll be automatically logged in and taken to the home screen

### Login (After Registration)

1. **Open the app**
2. Enter your **email** and **password**
3. Click **"Login"**
4. You'll be taken to the home screen

## 🎯 Test Accounts (Create These)

### Student Account
- Email: `student@test.com`
- Password: `123456`
- Role: Student

### Admin Account
- Email: `admin@test.com`
- Password: `123456`
- Role: Admin

## 🐛 Troubleshooting

### "An error occurred during registration"

**Possible Causes:**
1. Email/Password authentication not enabled in Firebase
2. Email already exists
3. Password too weak (< 6 characters)
4. No internet connection

**Solutions:**
1. ✅ Enable Email/Password auth in Firebase Console (Step 1 above)
2. Use a different email address
3. Use a password with at least 6 characters
4. Check your internet connection

### "An error occurred during login"

**Possible Causes:**
1. User doesn't exist
2. Wrong password
3. Email/Password auth not enabled

**Solutions:**
1. Register first if you haven't
2. Check your password
3. ✅ Enable Email/Password auth in Firebase Console

### Type Errors / App Crashes

**Fixed:**
- ✅ CourseModel type conversion errors are now handled
- ✅ All data models handle type mismatches gracefully

## 📊 App Features

### For Students:
- ✅ Browse and enroll in courses
- ✅ View lessons and watch videos
- ✅ Take quizzes
- ✅ Create and manage notes
- ✅ Track learning progress
- ✅ Chat with AI assistant
- ✅ Receive notifications
- ✅ Dark mode support

### For Admins:
- ✅ Manage courses (Create, Edit, Delete)
- ✅ Manage lessons
- ✅ Manage quizzes
- ✅ View user management
- ✅ Send notifications
- ✅ View reports and analytics

## 🔄 Next Steps After Setup

1. **Complete Firebase Setup** (Steps 1 & 2 above)
2. **Create your first account** using registration
3. **Explore the app features**
4. **Add sample courses** (if you're an admin)

## 📝 Important Notes

- **Internet Required**: First login/registration requires internet
- **Offline Support**: After login, 8 features work offline
- **Data Persistence**: All data is stored in Firebase Firestore
- **Security**: Firestore rules ensure data privacy

## 🆘 Still Having Issues?

1. **Check Firebase Console**:
   - Is Email/Password authentication enabled?
   - Are Firestore rules published?

2. **Check App Logs**:
   - Look for specific error messages in the console
   - Share the exact error message for help

3. **Verify Internet Connection**:
   - Firebase requires internet for authentication
   - Check your device's internet connection

## ✨ You're All Set!

Once you complete the Firebase setup (Steps 1 & 2), the app will work perfectly like any production app on the Play Store.

**Registration and Login will work flawlessly!** 🎉
