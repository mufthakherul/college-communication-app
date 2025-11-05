import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:campus_mesh/services/secure_storage_service.dart';
import 'package:campus_mesh/services/ai_chat_database.dart';
import 'package:campus_mesh/models/ai_chat_message_model.dart';
import 'package:campus_mesh/models/ai_chat_session_model.dart';

class AIChatbotService {
  static final AIChatbotService _instance = AIChatbotService._internal();
  factory AIChatbotService() => _instance;
  AIChatbotService._internal();

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
    if (apiKey.isEmpty || apiKey.length < 20) {
      return false;
    }

    // Check for common API key format (starts with expected prefix)
    if (!apiKey.startsWith('AI')) {
      // Gemini API keys typically start with 'AI'
      return false;
    }

    try {
      final testModel = GenerativeModel(
        model: _modelVersion,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 50, // Smaller for validation
        ),
      );

      // Test with a simple prompt - use timeout to avoid hanging
      final response = await testModel
          .generateContent([
            Content.text('Test'),
          ])
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('API validation timeout'),
          );

      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      // Return false for validation errors but don't throw
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

  // Send message and get response
  Future<String> sendMessage(String message, String sessionId) async {
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

      // Generate response
      final response = await _model!.generateContent(history);

      return response.text ??
          'I apologize, but I could not generate a response. Please try again.';
    } catch (e) {
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
    return await _database.getSessions(userId);
  }

  // Get a specific session
  Future<AIChatSession?> getSession(String sessionId) async {
    return await _database.getSession(sessionId);
  }

  // Get messages for a session
  Future<List<AIChatMessage>> getMessages(String sessionId) async {
    return await _database.getMessages(sessionId);
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

  // Stream response for real-time updates (optional enhancement)
  Stream<String> streamMessage(String message, String sessionId) async* {
    await _ensureModelInitialized();

    try {
      // Get chat history for context
      final messages = await _database.getMessages(sessionId);

      // Build conversation history with proper roles
      final history = <Content>[];
      for (final msg in messages.take(20)) {
        if (msg.isUser) {
          history.add(Content.text(msg.content));
        } else {
          history.add(Content.model([TextPart(msg.content)]));
        }
      }

      // Add current message
      history.add(Content.text(message));

      // Generate streaming response
      final response = _model!.generateContentStream(history);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield 'Error: Failed to get AI response: $e';
    }
  }
}
