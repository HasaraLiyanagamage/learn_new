# Google Sign-In Setup Guide

This guide will help you configure Google Sign-In for both Android and iOS platforms.

## Prerequisites

1. Firebase project already set up (✓ Already done)
2. `google_sign_in` package added to `pubspec.yaml` (✓ Already done)
3. Google Sign-In method implemented in `AuthProvider` (✓ Already done)
4. UI buttons added to login and registration screens (✓ Already done)

## Platform-Specific Configuration

### Android Configuration

#### 1. Get SHA-1 Certificate Fingerprint

Run this command in your project root:

```bash
cd android
./gradlew signingReport
```

Or for debug builds:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA-1** fingerprint from the output.

#### 2. Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on your Android app
6. Click **Add fingerprint**
7. Paste the SHA-1 fingerprint
8. Click **Save**

#### 3. Download Updated google-services.json

1. In Firebase Console, after adding SHA-1
2. Download the updated `google-services.json`
3. Replace the existing file at: `android/app/google-services.json`

#### 4. Verify android/build.gradle

Ensure you have the Google Services plugin (should already be configured):

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 5. Verify android/app/build.gradle

Ensure the plugin is applied at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS Configuration

#### 1. Get iOS Client ID

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **General**
4. Scroll to **Your apps** section
5. Find your iOS app
6. Copy the **iOS Client ID** (looks like: `xxxxx.apps.googleusercontent.com`)

#### 2. Update Info.plist

Add the following to `ios/Runner/Info.plist` (inside the `<dict>` tag):

```xml
<!-- Google Sign-In Configuration -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>

<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

**Important:** 
- Replace `YOUR_CLIENT_ID` with the reversed client ID from `GoogleService-Info.plist`
- Replace `YOUR_IOS_CLIENT_ID` with your actual iOS client ID from Firebase

#### 3. Find REVERSED_CLIENT_ID

Open `ios/Runner/GoogleService-Info.plist` and find the value for `REVERSED_CLIENT_ID`. It looks like:

```
com.googleusercontent.apps.123456789-abcdefg
```

Use this value in the `CFBundleURLSchemes` array above.

#### 4. Update Podfile (if needed)

Ensure your `ios/Podfile` has the minimum iOS version:

```ruby
platform :ios, '12.0'
```

Then run:

```bash
cd ios
pod install
cd ..
```

## Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Click on **Google**
5. Toggle **Enable**
6. Set a **Project support email**
7. Click **Save**

## Testing

### Run the app

```bash
flutter clean
flutter pub get
flutter run
```

### Test Google Sign-In

1. Open the app
2. Go to Login or Register screen
3. Tap **Continue with Google**
4. Select a Google account
5. Grant permissions
6. You should be signed in and redirected to the home screen

## Troubleshooting

### Android Issues

**Error: "Developer Error" or "Sign in failed"**
- Verify SHA-1 fingerprint is added to Firebase Console
- Download and replace `google-services.json`
- Run `flutter clean` and rebuild

**Error: "API not enabled"**
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Enable **Google+ API** or **People API**

### iOS Issues

**Error: "No client ID found"**
- Verify `GIDClientID` is set in `Info.plist`
- Verify `CFBundleURLSchemes` contains `REVERSED_CLIENT_ID`
- Check `GoogleService-Info.plist` exists in `ios/Runner/`

**Error: "The operation couldn't be completed"**
- Run `cd ios && pod install`
- Clean and rebuild: `flutter clean && flutter run`

### General Issues

**User cancels sign-in**
- This is normal behavior, no error is shown to the user

**Network errors**
- Check internet connection
- Verify Firebase project is active
- Check API quotas in Google Cloud Console

## Code Implementation Summary

### AuthProvider (`lib/providers/auth_provider.dart`)

The `signInWithGoogle()` method:
1. Triggers Google Sign-In flow
2. Gets Google credentials
3. Signs in to Firebase with Google credentials
4. Creates/updates user in Firestore
5. Saves login state locally
6. Returns success/failure

### UI Buttons

Both login and registration screens have:
- Google Sign-In button with Google logo
- Loading state handling
- Error message display
- Automatic navigation on success

## Security Notes

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repositories
2. Add them to `.gitignore` if needed
3. Use environment-specific configurations for production
4. Regularly rotate API keys and credentials

## Next Steps

After successful setup:
1. Test on both Android and iOS devices
2. Test with multiple Google accounts
3. Verify user data is correctly stored in Firestore
4. Test logout and re-login functionality
5. Consider adding profile photo from Google account

## Additional Resources

- [Firebase Google Sign-In Documentation](https://firebase.google.com/docs/auth/flutter/federated-auth)
- [google_sign_in Package](https://pub.dev/packages/google_sign_in)
- [Flutter Firebase Authentication](https://firebase.flutter.dev/docs/auth/overview)
