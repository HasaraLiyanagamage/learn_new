// Quick test script to verify Gemini API key
// Run with: dart test_gemini_api.dart

import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // Replace with your actual API key
  const apiKey = 'AIzaSyBWPHBDJLkvMIpypS-acGlNnZ163qkgZS8';
  
  print('🔍 Testing Gemini API Key...\n');
  
  try {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    
    print('✅ Model created successfully');
    print('📤 Sending test message...\n');
    
    final content = [Content.text('Say "Hello, the API key is working!" in one sentence.')];
    final response = await model.generateContent(content);
    
    if (response.text != null && response.text!.isNotEmpty) {
      print('✅ SUCCESS! API key is valid and working!\n');
      print('📨 Response from Gemini:');
      print('   ${response.text}\n');
      print('🎉 Your chatbot should work now!');
    } else {
      print('❌ ERROR: Empty response from API');
      print('   The API key might be valid but there\'s an issue with the response.');
    }
  } on GenerativeAIException catch (e) {
    print('❌ GEMINI API ERROR:');
    print('   ${e.message}\n');
    
    final errorMsg = e.message.toLowerCase();
    if (errorMsg.contains('api key') || errorMsg.contains('api_key')) {
      print('💡 SOLUTION:');
      print('   1. Your API key is invalid or expired');
      print('   2. Get a new key from: https://makersuite.google.com/app/apikey');
      print('   3. Replace the apiKey in app_constants.dart');
    } else if (errorMsg.contains('quota') || errorMsg.contains('limit')) {
      print('💡 SOLUTION:');
      print('   1. You\'ve exceeded your API quota');
      print('   2. Wait for quota reset or upgrade your plan');
      print('   3. Check: https://console.cloud.google.com/');
    } else if (errorMsg.contains('blocked') || errorMsg.contains('safety')) {
      print('💡 SOLUTION:');
      print('   1. The request was blocked by safety filters');
      print('   2. This shouldn\'t happen with the test message');
      print('   3. Check your API settings');
    }
  } catch (e) {
    print('❌ GENERAL ERROR:');
    print('   $e\n');
    
    if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
      print('💡 SOLUTION:');
      print('   1. Check your internet connection');
      print('   2. Make sure you\'re not behind a firewall blocking API requests');
    } else {
      print('💡 SOLUTION:');
      print('   1. Make sure google_generative_ai package is installed');
      print('   2. Run: dart pub get');
      print('   3. Check if the API key format is correct (should start with AIza)');
    }
  }
  
  print('\n${'='*60}');
  print('TEST COMPLETE');
  print('='*60);
}
