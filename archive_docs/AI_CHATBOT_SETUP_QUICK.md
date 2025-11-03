# AI Chatbot Quick Setup

## 🚀 5-Minute Setup Guide

### For Users

1. **Get Your API Key** (2 minutes)
   - Visit https://ai.google.dev
   - Sign in with your Google account
   - Click "Get API Key" → "Create API Key"
   - Copy the key

2. **Open AI Chatbot** (30 seconds)
   - Open Campus Mesh app
   - Go to **Tools** tab
   - Tap **AI Chatbot**

3. **Enter API Key** (1 minute)
   - Paste your API key
   - Tap "Save & Continue"
   - Wait for validation

4. **Start Chatting!** (30 seconds)
   - Type your first message
   - Press send
   - Get instant AI responses

### For Developers

#### Dependencies Added
```yaml
dependencies:
  google_generative_ai: ^0.2.2  # Gemini API
```

#### Files Created
```
lib/models/
  ├── ai_chat_message_model.dart      # Message model
  └── ai_chat_session_model.dart      # Session model

lib/services/
  ├── ai_chatbot_service.dart         # Main AI service
  └── ai_chat_database.dart           # Local database

lib/screens/ai_chat/
  ├── api_key_input_screen.dart       # API key setup
  ├── ai_chat_screen.dart             # Chat interface
  └── ai_chat_history_screen.dart     # Session list
```

#### Integration Points
- **Tools Screen**: Added AI Chatbot tile
- **Auth Service**: Clears API key on logout
- **Secure Storage**: Extended with generic read/write/delete methods

#### Database Schema
```sql
-- Sessions table
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  title TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  lastMessageAt TEXT NOT NULL,
  messageCount INTEGER NOT NULL
);

-- Messages table
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  sessionId TEXT NOT NULL,
  content TEXT NOT NULL,
  isUser INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (sessionId) REFERENCES sessions (id)
);
```

#### Key Features
- ✅ Singleton service pattern
- ✅ Secure API key storage
- ✅ Local-only chat history
- ✅ Context-aware conversations (20 msg history)
- ✅ Custom educational instructions
- ✅ Auto-clear API key on logout

## 📱 Testing Checklist

### Basic Flow
- [ ] Open AI Chatbot from Tools
- [ ] Enter API key
- [ ] Validate API key works
- [ ] Send first message
- [ ] Receive AI response
- [ ] Session title auto-generated

### Session Management
- [ ] Create multiple sessions
- [ ] View session list
- [ ] Open existing session
- [ ] Continue conversation
- [ ] Delete session

### Security
- [ ] API key stored securely
- [ ] Logout clears API key
- [ ] Login requires API key re-entry
- [ ] Chat history persists locally
- [ ] No data sent to our servers

### API Key Management
- [ ] Change API key
- [ ] Remove API key
- [ ] Invalid key error handling
- [ ] API key validation works

### Edge Cases
- [ ] Empty message handling
- [ ] Very long messages
- [ ] Network timeout
- [ ] API rate limiting
- [ ] Invalid API responses

## 🔧 Troubleshooting

**API Key Issues**
```dart
// Check if API key exists
final hasKey = await AIChatbotService().hasApiKey();

// Clear API key manually
await AIChatbotService().clearApiKey();

// Validate API key
final isValid = await AIChatbotService().validateApiKey(apiKey);
```

**Database Issues**
```dart
// Clear all chat data
final db = AIChatDatabase();
await db.clearAllData();

// Check session count
final sessions = await db.getSessions(userId);
print('Total sessions: ${sessions.length}');
```

**Model Issues**
```dart
// Model version is configurable
// Change in ai_chatbot_service.dart:
static const String _modelVersion = 'gemini-1.5-flash';
```

## 📊 Performance

- **API Response Time**: 1-3 seconds (depends on Gemini API)
- **Local Database**: SQLite (fast, efficient)
- **Memory Usage**: Minimal (messages paginated)
- **Context Window**: 20 messages (configurable)

## 🔐 Security Summary

✅ **API Keys**: Encrypted, cleared on logout  
✅ **Chat History**: Local-only storage  
✅ **No Server Storage**: Zero data sent to our servers  
✅ **User Privacy**: Each user has own API key  
✅ **Dependencies**: No vulnerabilities (checked)

## 📚 Documentation

- **Full Guide**: [AI_CHATBOT_GUIDE.md](AI_CHATBOT_GUIDE.md)
- **README**: Updated with AI chatbot section
- **Code Comments**: Inline documentation

## 🎯 Next Steps

1. **Install Dependencies**
   ```bash
   cd apps/mobile
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Test the Feature**
   - Follow testing checklist above

4. **Deploy**
   - Build APK as usual
   - No additional configuration needed

---

**Need Help?** Check [AI_CHATBOT_GUIDE.md](AI_CHATBOT_GUIDE.md) for detailed documentation.
