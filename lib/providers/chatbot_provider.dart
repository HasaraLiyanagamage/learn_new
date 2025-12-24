import 'package:flutter/foundation.dart';
import '../core/models/chat_message_model.dart';
import '../core/services/chatbot_service.dart';
import '../core/utils/connectivity_helper.dart';
import 'package:uuid/uuid.dart';

class ChatbotProvider with ChangeNotifier {
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Send a message to the chatbot
  Future<void> sendMessage(String userId, String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Check internet connection first
      final isConnected = await ConnectivityHelper.isConnected();
      if (!isConnected) {
        _errorMessage = ' No internet connection. The AI chatbot requires an active internet connection to work.';
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
      _errorMessage = null;
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get course recommendations
  Future<void> getCourseRecommendations(String userId, String interests) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ChatbotService.getCourseRecommendations(interests);

      final botMessage = ChatMessageModel(
        id: const Uuid().v4(),
        userId: userId,
        message: 'Recommend courses for: $interests',
        response: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(botMessage);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to get recommendations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Explain a concept
  Future<void> explainConcept(String userId, String concept) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ChatbotService.explainConcept(concept);

      final botMessage = ChatMessageModel(
        id: const Uuid().v4(),
        userId: userId,
        message: 'Explain: $concept',
        response: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(botMessage);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to explain concept: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get study tips
  Future<void> getStudyTips(String userId, String topic) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ChatbotService.getStudyTips(topic);

      final botMessage = ChatMessageModel(
        id: const Uuid().v4(),
        userId: userId,
        message: 'Study tips for: $topic',
        response: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(botMessage);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to get study tips: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
