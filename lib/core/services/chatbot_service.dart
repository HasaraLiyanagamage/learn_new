import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_constants.dart';

class ChatbotService {
  static GenerativeModel? _model;

  static void initialize() {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
  }

  static Future<String> sendMessage(String message) async {
    if (_model == null) {
      throw Exception('Chatbot not initialized. Please restart the app.');
    }

    try {
      // Create a context-aware prompt for learning assistance
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
        throw Exception('Empty response from AI. Please try again.');
      }

      return response.text!;
    } on GenerativeAIException catch (e) {
      // Handle specific Gemini API errors
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('api key') || errorMsg.contains('api_key')) {
        throw Exception('Invalid API key. Please check your Gemini API configuration.');
      } else if (errorMsg.contains('quota') || errorMsg.contains('limit')) {
        throw Exception('API quota exceeded. Please try again later or check your API limits.');
      } else if (errorMsg.contains('blocked') || errorMsg.contains('safety')) {
        throw Exception('Request blocked by safety filters. Try rephrasing your question.');
      } else if (errorMsg.contains('network') || errorMsg.contains('connection')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      throw Exception('AI Error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Failed to get response: $e');
    }
  }

  static Future<String> getCourseRecommendations(String userInterests) async {
    if (_model == null) {
      throw Exception('Chatbot not initialized');
    }

    try {
      final prompt = '''
Based on the following interests: $userInterests

Recommend 3-5 relevant courses or topics that would be beneficial for learning.
Format your response as a numbered list with brief descriptions.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'Unable to generate recommendations.';
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  static Future<String> explainConcept(String concept) async {
    if (_model == null) {
      throw Exception('Chatbot not initialized');
    }

    try {
      final prompt = '''
Explain the following concept in simple terms that a student can understand:

Concept: $concept

Provide:
1. A clear definition
2. A simple example
3. Why it's important to learn

Keep the explanation concise and easy to understand.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'Unable to explain the concept.';
    } catch (e) {
      throw Exception('Failed to explain concept: $e');
    }
  }

  static Future<String> getStudyTips(String topic) async {
    if (_model == null) {
      throw Exception('Chatbot not initialized');
    }

    try {
      final prompt = '''
Provide 5 practical study tips for learning: $topic

Format your response as a numbered list with actionable advice.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'Unable to generate study tips.';
    } catch (e) {
      throw Exception('Failed to get study tips: $e');
    }
  }
}
