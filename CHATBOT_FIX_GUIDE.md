# Chatbot Not Responding - Troubleshooting Guide

## 🔴 Problem
The AI chatbot is not responding when you send messages.

## 🔍 Root Causes

### 1. **Invalid or Expired API Key**
The Gemini API key in `app_constants.dart` might be:
- Invalid
- Expired
- Not properly configured
- Exceeding quota limits

### 2. **API Key Security Issue** ⚠️
**CRITICAL:** Your API key is hardcoded in the source code, which is a security risk!

Current location: `lib/core/constants/app_constants.dart` line 39
```dart
static const String geminiApiKey = 'AIzaSyBWPHBDJLkvMIpypS-acGlNnZ163qkgZS8';
```

### 3. **Network Issues**
- No internet connection
- Firewall blocking API requests
- API endpoint unreachable

### 4. **Initialization Issues**
- ChatbotService not properly initialized
- Model not created correctly

---

## ✅ Solutions

### Solution 1: Get a New Gemini API Key

#### Step 1: Go to Google AI Studio
1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Select your Google Cloud project (or create a new one)
5. Copy the new API key

#### Step 2: Update the API Key (Temporarily)
For testing purposes, update the key in `app_constants.dart`:

```dart
// lib/core/constants/app_constants.dart
static const String geminiApiKey = 'YOUR_NEW_API_KEY_HERE';
```

#### Step 3: Test the Chatbot
1. Run the app: `flutter run`
2. Navigate to the Chatbot screen
3. Send a test message
4. Check if you get a response

---

### Solution 2: Secure API Key Storage (RECOMMENDED)

**Never hardcode API keys in your source code!** Here's how to fix it properly:

#### Step 1: Create Environment File
Create a file named `.env` in your project root:

```env
GEMINI_API_KEY=your_actual_api_key_here
```

#### Step 2: Add to .gitignore
Add this line to `.gitignore` to prevent committing the key:

```
.env
```

#### Step 3: Install flutter_dotenv Package
Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Run:
```bash
flutter pub get
```

#### Step 4: Load Environment Variables
Update `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // ... rest of your code
}
```

#### Step 5: Update app_constants.dart
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ... other constants
  
  // Gemini AI Configuration - Load from environment
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String geminiModel = 'gemini-pro';
}
```

#### Step 6: Update pubspec.yaml Assets
Add the .env file to assets:

```yaml
flutter:
  assets:
    - .env
```

---

### Solution 3: Add Better Error Handling

I've already added error display to the chatbot screen. Now let's improve the error messages:

#### Update chatbot_service.dart

```dart
static Future<String> sendMessage(String message) async {
  if (_model == null) {
    throw Exception('Chatbot not initialized. Please restart the app.');
  }

  try {
    final prompt = '''
You are a helpful learning assistant for the Smart Learning Assistant Platform. 
Your role is to help students with their studies, answer questions about courses, 
provide explanations, and offer study tips.

Student's question: $message

Please provide a helpful, clear, and concise response.
''';

    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(content);

    if (response.text == null || response.text!.isEmpty) {
      throw Exception('Empty response from AI');
    }

    return response.text!;
  } on GenerativeAIException catch (e) {
    // Handle specific Gemini API errors
    if (e.message.contains('API key')) {
      throw Exception('Invalid API key. Please check your Gemini API configuration.');
    } else if (e.message.contains('quota')) {
      throw Exception('API quota exceeded. Please try again later.');
    } else if (e.message.contains('blocked')) {
      throw Exception('Request blocked by safety filters. Try rephrasing your question.');
    }
    throw Exception('AI Error: ${e.message}');
  } catch (e) {
    throw Exception('Failed to get response: $e');
  }
}
```

---

### Solution 4: Check Network Connectivity

Add connectivity check before sending messages:

#### Update chatbot_provider.dart

```dart
import '../core/utils/connectivity_helper.dart';

Future<void> sendMessage(String userId, String message) async {
  if (message.trim().isEmpty) return;

  try {
    // Check internet connection
    final isConnected = await ConnectivityHelper.isConnected();
    if (!isConnected) {
      _errorMessage = 'No internet connection. Please check your network.';
      notifyListeners();
      return;
    }

    // Add user message
    final userMessage = ChatMessageModel(
      id: const Uuid().v4(),
      userId: userId,
      message: message,
      response: '',
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    // Get AI response
    final response = await ChatbotService.sendMessage(message);

    // Add bot response
    final botMessage = ChatMessageModel(
      id: const Uuid().v4(),
      userId: userId,
      message: message,
      response: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(botMessage);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Failed to get response: $e';
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 🧪 Testing Steps

### 1. Test API Key Validity
Run this test to verify your API key works:

```dart
// Create a test file: test/chatbot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learn/core/services/chatbot_service.dart';

void main() {
  test('Chatbot API Key Test', () async {
    ChatbotService.initialize();
    
    try {
      final response = await ChatbotService.sendMessage('Hello, test message');
      print('Success! Response: $response');
      expect(response, isNotEmpty);
    } catch (e) {
      print('Error: $e');
      fail('API key test failed: $e');
    }
  });
}
```

Run the test:
```bash
flutter test test/chatbot_test.dart
```

### 2. Test in App
1. Open the app
2. Navigate to Chatbot screen
3. Send a message: "Hello"
4. Wait for response (should appear within 5-10 seconds)
5. Check for error messages in the red banner at the top

### 3. Check Logs
Run the app with verbose logging:
```bash
flutter run -v
```

Look for error messages related to:
- `GenerativeAIException`
- `API key`
- `quota`
- `network`

---

## 🔧 Quick Fixes

### Fix 1: Restart the App
Sometimes the chatbot service doesn't initialize properly:
```bash
flutter clean
flutter pub get
flutter run
```

### Fix 2: Check Internet Connection
- Ensure your device/emulator has internet access
- Try opening a browser to verify connectivity
- Check if firewall is blocking API requests

### Fix 3: Verify API Key Format
The API key should:
- Start with `AIza`
- Be 39 characters long
- Contain only alphanumeric characters and hyphens

### Fix 4: Check API Quotas
1. Go to: https://console.cloud.google.com/
2. Select your project
3. Navigate to **APIs & Services > Dashboard**
4. Check **Generative Language API** quotas
5. Verify you haven't exceeded free tier limits

---

## 📊 Common Error Messages

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Chatbot not initialized" | Service not initialized in main.dart | Check `ChatbotService.initialize()` is called |
| "Invalid API key" | Wrong or expired API key | Get new API key from Google AI Studio |
| "API quota exceeded" | Too many requests | Wait or upgrade to paid plan |
| "No internet connection" | Device offline | Check network connectivity |
| "Request blocked by safety filters" | Message flagged as inappropriate | Rephrase the question |
| "Empty response from AI" | API returned null | Check API status or try again |

---

## 🚀 Recommended Implementation

Here's the complete, secure implementation:

### 1. File: `.env`
```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 2. File: `.gitignore`
```
.env
*.env
```

### 3. File: `pubspec.yaml`
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
  
flutter:
  assets:
    - .env
```

### 4. File: `lib/main.dart`
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables FIRST
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable Firestore offline persistence
  await FirestoreService.enableOfflinePersistence();
  
  // Initialize services
  await ApiService.init();
  await NotificationService.initialize();
  ChatbotService.initialize(); // This will now use the env variable
  
  runApp(const MyApp());
}
```

### 5. File: `lib/core/constants/app_constants.dart`
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ... other constants
  
  // Gemini AI Configuration
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    return key;
  }
  static const String geminiModel = 'gemini-pro';
}
```

---

## 📝 For Your Group Documentation

When documenting the chatbot feature (Member 4), include:

### Security Note
```markdown
## API Key Security

⚠️ **Important:** The Gemini API key is stored in a `.env` file and NOT committed to version control.

To run this project:
1. Create a `.env` file in the project root
2. Add your Gemini API key: `GEMINI_API_KEY=your_key_here`
3. Never commit the `.env` file to Git

The `.env` file is listed in `.gitignore` to prevent accidental exposure.
```

### Troubleshooting Section
```markdown
## Chatbot Troubleshooting

If the chatbot doesn't respond:
1. Check internet connection
2. Verify API key is valid
3. Check API quota limits
4. Look for error messages in the red banner
5. Check console logs for detailed errors
```

---

## 🎯 Next Steps

1. **Immediate:** Get a new API key and test
2. **Short-term:** Implement secure .env storage
3. **Long-term:** Add rate limiting and caching to reduce API calls

---

## 📞 Support Resources

- **Google AI Studio:** https://makersuite.google.com/
- **Gemini API Docs:** https://ai.google.dev/docs
- **Flutter Dotenv:** https://pub.dev/packages/flutter_dotenv
- **API Pricing:** https://ai.google.dev/pricing

---

## ✅ Checklist

- [ ] Get new Gemini API key
- [ ] Test API key with simple request
- [ ] Implement .env file storage
- [ ] Add .env to .gitignore
- [ ] Update app_constants.dart to use dotenv
- [ ] Test chatbot functionality
- [ ] Add error handling
- [ ] Document security practices
- [ ] Test offline behavior
- [ ] Monitor API usage and quotas
