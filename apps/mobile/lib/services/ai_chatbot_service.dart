// ignore_for_file: cascade_invocations
import 'package:campus_mesh/models/ai_chat_message_model.dart';
import 'package:campus_mesh/models/ai_chat_session_model.dart';
import 'package:campus_mesh/services/ai_chat_database.dart';
import 'package:campus_mesh/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIChatbotService {
  factory AIChatbotService() => _instance;
  AIChatbotService._internal();
  static final AIChatbotService _instance = AIChatbotService._internal();

  final _secureStorage = SecureStorageService();
  final _database = AIChatDatabase();

  GenerativeModel? _model;
  String? _currentApiKey;

  // Model version constant
  static const String _modelVersion = 'gemini-1.5-flash';

  // Custom system instruction for better responses
  static const String _systemInstruction = '''
You are an AI assistant for a college communication app called "Campus Mesh" used at Rangpur Polytechnic Institute.
Your role is to help students, teachers, and staff with:
- Academic questions and study tips
- College-related information
- General knowledge and educational support
- Technical questions related to their courses
- Advice on assignments and projects

Be friendly, professional, and educational in your responses.
Keep your answers concise but informative.
If asked about something you're unsure about, be honest about it.
Always maintain a respectful and supportive tone.
''';

  // Check if API key is stored
  Future<bool> hasApiKey() async {
    final key = await _secureStorage.read('gemini_api_key');
    return key != null && key.isNotEmpty;
  }

  // Store API key securely
  Future<void> storeApiKey(String apiKey) async {
    // Trim whitespace that might have been accidentally copied
    final trimmedKey = apiKey.trim();

    await _secureStorage.write('gemini_api_key', trimmedKey);
    _currentApiKey = trimmedKey;
    _initializeModel();
  }

  // Get stored API key
  Future<String?> getApiKey() async {
    if (_currentApiKey != null) return _currentApiKey;
    _currentApiKey = await _secureStorage.read('gemini_api_key');
    return _currentApiKey;
  }

  // Clear API key (on logout)
  Future<void> clearApiKey() async {
    await _secureStorage.delete('gemini_api_key');
    _currentApiKey = null;
    _model = null;
  }

  // Validate API key
  Future<bool> validateApiKey(String apiKey) async {
    // Basic format validation first
    if (apiKey.isEmpty || apiKey.length < 10) {
      return false;
    }

    // Gemini API keys can have various formats
    // Just ensure it's a reasonable length and alphanumeric/special chars
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty || trimmedKey.length < 10) {
      return false;
    }

    try {
      final testModel = GenerativeModel(
        model: _modelVersion,
        apiKey: trimmedKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 50, // Smaller for validation
        ),
      );

      // Test with a simple prompt - use timeout to avoid hanging
      final response = await testModel
          .generateContent([Content.text('Say hello')])
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('API validation timeout'),
          );

      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      // Log the error for debugging
      debugPrint('API validation error: $e');
      return false;
    }
  }

  // Initialize the Gemini model
  void _initializeModel() {
    if (_currentApiKey == null || _currentApiKey!.isEmpty) return;

    _model = GenerativeModel(
      model: _modelVersion,
      apiKey: _currentApiKey!,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  // Ensure model is initialized
  Future<void> _ensureModelInitialized() async {
    if (_model == null) {
      await getApiKey();
      _initializeModel();
    }
    if (_model == null) {
      throw Exception('Gemini API key not configured');
    }
  }

  // Send message and get response with retry logic
  Future<String> sendMessage(
    String message,
    String sessionId, {
    int retryCount = 0,
  }) async {
    await _ensureModelInitialized();

    try {
      // Get chat history for context
      final messages = await _database.getMessages(sessionId);

      // Build conversation history with proper roles
      final history = <Content>[];

      // Add system instruction as first user message if this is first message
      if (messages.isEmpty) {
        history.add(Content.text(_systemInstruction));
        history.add(
          Content.model([
            TextPart(
              'I understand. I am here to assist students, teachers, and staff at Rangpur Polytechnic Institute. How can I help you today?',
            ),
          ]),
        );
      }

      for (final msg in messages.take(20)) {
        // Limit to last 20 messages for context
        if (msg.isUser) {
          history.add(Content.text(msg.content));
        } else {
          history.add(Content.model([TextPart(msg.content)]));
        }
      }

      // Add current message
      history.add(Content.text(message));

      // Generate response with timeout
      final response = await _model!
          .generateContent(history)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception(
              'Gemini API took too long to respond. Please try again.',
            ),
          );

      // Check for valid response
      if (response.text == null || response.text!.isEmpty) {
        // Retry once if response is empty
        if (retryCount < 1) {
          debugPrint('Empty response from Gemini, retrying...');
          await Future.delayed(const Duration(seconds: 1));
          return sendMessage(message, sessionId, retryCount: retryCount + 1);
        }
        return 'I apologize, but I could not generate a response. Please try again.';
      }

      return response.text!;
    } catch (e) {
      final errorStr = e.toString();

      // Check for timeout errors
      if (errorStr.contains('timeout') ||
          errorStr.contains('TimeoutException') ||
          errorStr.contains('Gemini API took too long')) {
        if (retryCount < 1) {
          debugPrint('Timeout, retrying request...');
          await Future.delayed(const Duration(seconds: 1));
          return sendMessage(message, sessionId, retryCount: retryCount + 1);
        }
        throw Exception(
          'Request timed out. The Gemini API is taking too long. Please check your internet connection and try again.',
        );
      }

      // Handle rate limiting (429 errors)
      if (errorStr.contains('429') || errorStr.contains('RESOURCE_EXHAUSTED')) {
        if (retryCount < 2) {
          final delaySeconds = (2 * (retryCount + 1)).toDouble();
          debugPrint('Rate limited, retrying after ${delaySeconds}s...');
          await Future.delayed(Duration(seconds: delaySeconds.toInt()));
          return sendMessage(message, sessionId, retryCount: retryCount + 1);
        }
        throw Exception(
          'API rate limit exceeded. You\'ve made too many requests. Please wait a few minutes and try again.',
        );
      }

      // Handle quota exceeded
      if (errorStr.contains('QUOTA_EXCEEDED') ||
          errorStr.contains('quota') ||
          errorStr.contains('daily')) {
        throw Exception(
          'Daily API quota exceeded. Please check your Gemini API usage and try again tomorrow.',
        );
      }

      // Handle invalid API key
      if (errorStr.contains('INVALID_ARGUMENT') ||
          errorStr.contains('invalid API key') ||
          errorStr.contains('401') ||
          errorStr.contains('403')) {
        throw Exception(
          'Invalid or expired API key. Please verify your API key and try again.',
        );
      }

      // Handle network errors
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Failed host lookup') ||
          errorStr.contains('Connection refused')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      }

      throw Exception('Failed to get AI response: $e');
    }
  }

  // Create a new chat session
  Future<AIChatSession> createSession(String userId, {String? title}) async {
    final session = AIChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title ?? 'New Chat ${DateTime.now().toString().split(' ')[0]}',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      messageCount: 0,
    );

    await _database.createSession(session);
    return session;
  }

  // Get all sessions for a user
  Future<List<AIChatSession>> getSessions(String userId) async {
    return _database.getSessions(userId);
  }

  // Get a specific session
  Future<AIChatSession?> getSession(String sessionId) async {
    return _database.getSession(sessionId);
  }

  // Get messages for a session
  Future<List<AIChatMessage>> getMessages(String sessionId) async {
    return _database.getMessages(sessionId);
  }

  // Save a message
  Future<void> saveMessage(AIChatMessage message) async {
    await _database.addMessage(message);

    // Update session
    final session = await _database.getSession(message.sessionId);
    if (session != null) {
      final messageCount = await _database.getMessageCount(message.sessionId);
      await _database.updateSession(
        session.copyWith(
          lastMessageAt: message.timestamp,
          messageCount: messageCount,
        ),
      );
    }
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    await _database.deleteAllMessagesInSession(sessionId);
    await _database.deleteSession(sessionId);
  }

  // Update session title
  Future<void> updateSessionTitle(String sessionId, String title) async {
    final session = await _database.getSession(sessionId);
    if (session != null) {
      await _database.updateSession(session.copyWith(title: title));
    }
  }

  // Generate title from first message
  Future<String> generateSessionTitle(String firstMessage) async {
    if (firstMessage.length <= 40) {
      return firstMessage;
    }

    // Take first 40 characters and add ellipsis
    return '${firstMessage.substring(0, 40)}...';
  }

  // Clear all chat data (on logout)
  Future<void> clearAllData() async {
    await clearApiKey();
    await _database.clearAllData();
  }

  // Stream response for real-time updates with better error handling
  Stream<String> streamMessage(String message, String sessionId) async* {
    await _ensureModelInitialized();

    try {
      // Get chat history for context
      final messages = await _database.getMessages(sessionId);

      // Build conversation history with proper roles
      final history = <Content>[];

      // Add system instruction as first user message if this is first message
      if (messages.isEmpty) {
        history.add(Content.text(_systemInstruction));
        history.add(
          Content.model([
            TextPart(
              'I understand. I am here to assist students, teachers, and staff at Rangpur Polytechnic Institute. How can I help you today?',
            ),
          ]),
        );
      }

      for (final msg in messages.take(20)) {
        if (msg.isUser) {
          history.add(Content.text(msg.content));
        } else {
          history.add(Content.model([TextPart(msg.content)]));
        }
      }

      // Add current message
      history.add(Content.text(message));

      // Generate streaming response with timeout
      try {
        final response = _model!.generateContentStream(history);

        await for (final chunk in response) {
          if (chunk.text != null && chunk.text!.isNotEmpty) {
            yield chunk.text!;
          }
        }
      } catch (e) {
        final errorStr = e.toString();

        // Check for timeout
        if (errorStr.contains('timeout') ||
            errorStr.contains('TimeoutException')) {
          yield 'The request timed out. Please try again.';
        }
        // Check for rate limiting
        else if (errorStr.contains('429') ||
            errorStr.contains('RESOURCE_EXHAUSTED')) {
          yield 'Rate limit exceeded. Please wait a moment and try again.';
        }
        // Check for authentication errors
        else if (errorStr.contains('401') || errorStr.contains('403')) {
          yield 'Authentication error. Please check your API key.';
        } else {
          yield 'Error: Unable to generate response: $e';
        }
      }
    } catch (e) {
      yield 'Error initializing response stream: $e';
    }
  }
}
