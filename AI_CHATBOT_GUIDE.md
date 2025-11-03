# AI Chatbot Guide

## Overview

The Campus Mesh app now includes an AI-powered chatbot feature using Google's Gemini Flash API. This feature allows users to have intelligent conversations with an AI assistant that can help with academic questions, college-related information, and general educational support.

## Key Features

### 🔐 Privacy & Security First
- **Your Own API Key**: Users provide their own Google Gemini API key
- **Secure Storage**: API keys are stored securely on your device
- **Auto-Clear on Logout**: API keys are automatically cleared when you log out
- **Local Chat History**: All conversations are stored locally on your device
- **No Third-Party Access**: Only you can see your conversations

### 💬 Intelligent Conversations
- **Context-Aware**: The AI remembers the last 20 messages in your conversation
- **Custom Instructions**: Pre-configured with educational prompts for better responses
- **Multiple Sessions**: Create and manage multiple chat sessions
- **Fast Responses**: Powered by Gemini 1.5 Flash for quick answers

### 📱 User-Friendly Interface
- **Chat History**: View all your previous conversations
- **Session Management**: Create, view, and delete chat sessions
- **Message Timestamps**: See when each message was sent
- **Clean UI**: Simple and intuitive chat interface

## Getting Started

### Step 1: Get Your Gemini API Key

1. Visit [Google AI Studio](https://ai.google.dev)
2. Sign in with your Google account
3. Click "Get API Key"
4. Create a new API key
5. Copy the key (you'll need it in the next step)

**Note**: Gemini API has a free tier with generous limits for personal use.

### Step 2: Open AI Chatbot

1. Open the Campus Mesh app
2. Navigate to the **Tools** tab
3. Tap on **AI Chatbot**

### Step 3: Enter Your API Key

On first use, you'll see the API Key setup screen:

1. Paste your Gemini API key
2. Tap **Save & Continue**
3. The app will validate your key
4. Once validated, you'll be taken to the chat screen

### Step 4: Start Chatting

1. Type your message in the input field
2. Tap the send button
3. Wait for the AI to respond
4. Continue the conversation!

## Features in Detail

### Chat Sessions

**Creating a New Session**:
- Tap the "New Chat" button on the chat history screen
- Start typing to begin a conversation
- The session title is automatically generated from your first message

**Viewing Previous Sessions**:
- All your chat sessions are listed on the history screen
- Each session shows:
  - Title (based on first message)
  - Number of messages
  - Last activity time

**Deleting a Session**:
- Tap the delete icon on any session
- Confirm deletion
- The session and all its messages are removed

### API Key Management

**Viewing API Key Status**:
- The key icon in the app bar shows if an API key is configured
- 🔑 (filled) = API key configured
- 🔓 (outline) = No API key

**Changing Your API Key**:
1. Tap the key icon in the chat history screen
2. Select "Change Key"
3. Enter your new API key
4. Tap "Save & Continue"

**Removing Your API Key**:
1. Tap the key icon
2. Select "Remove Key"
3. Your API key is deleted (chat history remains)

### Security Features

**On Logout**:
- Your API key is automatically cleared
- Chat history is preserved on your device
- You'll need to re-enter your API key after logging back in

**On New Device**:
- Chat history won't transfer to a new device (stored locally)
- You'll need to enter your API key on the new device
- Previous conversations remain on your old device

## Custom Instructions

The AI chatbot is pre-configured with custom instructions to:

- Act as an educational assistant for college students
- Help with academic questions and study tips
- Provide college-related information
- Assist with technical questions related to courses
- Offer advice on assignments and projects

The AI is instructed to be:
- Friendly and professional
- Concise but informative
- Honest about limitations
- Respectful and supportive

## Use Cases

### Academic Help
- "Explain the concept of object-oriented programming"
- "What are the main differences between AC and DC current?"
- "Help me understand calculus derivatives"

### Study Tips
- "What's the best way to prepare for exams?"
- "How can I manage my time better?"
- "Give me tips for effective note-taking"

### Project Assistance
- "I'm working on a web development project. What technologies should I use?"
- "How do I structure a research paper?"
- "What are best practices for database design?"

### College Information
- "What are the important dates I should remember?"
- "How do I access the library resources?"
- "Explain the grading system"

## Tips for Best Results

1. **Be Specific**: Ask clear, specific questions for better answers
2. **Provide Context**: Give background information when relevant
3. **Follow Up**: Ask follow-up questions to dive deeper
4. **Break Down Complex Topics**: Split large questions into smaller ones
5. **Use Proper Grammar**: Clear questions get better responses

## Troubleshooting

### Invalid API Key Error
- **Problem**: The app says your API key is invalid
- **Solution**: 
  - Double-check you copied the entire key
  - Make sure there are no extra spaces
  - Try generating a new key from Google AI Studio
  - Verify your Google account has API access enabled

### API Key Cleared After Logout
- **Problem**: You have to re-enter your API key after logging out
- **Solution**: This is a security feature. Your API key is intentionally cleared on logout to protect your account. Simply re-enter it after logging back in.

### Slow Responses
- **Problem**: The AI takes a long time to respond
- **Solution**:
  - Check your internet connection
  - Try a shorter message
  - The Gemini API might be experiencing high traffic

### Chat History Not Syncing
- **Problem**: Chat history doesn't appear on a new device
- **Solution**: Chat history is stored locally for privacy. It won't sync across devices. This is by design to keep your conversations secure.

### Can't Delete a Session
- **Problem**: Unable to delete a chat session
- **Solution**: 
  - Try closing and reopening the app
  - Check if you have permission issues
  - Contact support if the problem persists

## Privacy Policy

### Data Collection
- **API Key**: Stored locally on your device, encrypted
- **Chat Messages**: Stored locally in a separate database
- **No Cloud Backup**: Nothing is sent to our servers

### Data Sharing
- **With Google**: Your messages are sent to Google's Gemini API for processing
- **With Campus Mesh**: We never see your API key or chat messages
- **With Third Parties**: No data is shared with any other parties

### Data Retention
- **On Device**: Chat history remains until you delete it
- **On Logout**: API key is cleared, chat history remains
- **On Uninstall**: All data is removed with the app

## API Limits

Google's Gemini Flash API has the following limits (as of 2025):

**Free Tier**:
- 15 requests per minute
- 1,500 requests per day
- 1 million tokens per month

If you exceed these limits, you may see rate limit errors. Wait a few minutes and try again.

## Future Enhancements

Planned features:
- [ ] Voice input/output
- [ ] Image analysis support
- [ ] Export chat history
- [ ] Share conversations
- [ ] Offline mode with cached responses
- [ ] Custom system instructions
- [ ] Multiple AI model support

## Support

If you encounter any issues or have questions:

1. Check this guide first
2. Review the [Troubleshooting](#troubleshooting) section
3. Check the [GitHub Issues](https://github.com/mufthakherul/college-communication-app/issues)
4. Contact the developer: Mufthakherul

## Frequently Asked Questions

**Q: Is my API key safe?**  
A: Yes, your API key is encrypted and stored securely on your device. It's never sent to our servers.

**Q: Can I use the same API key on multiple devices?**  
A: Yes, you can use the same API key on multiple devices. Just enter it when prompted.

**Q: Will my chat history sync across devices?**  
A: No, chat history is stored locally for privacy and security. Each device maintains its own history.

**Q: What happens if I forget to log out?**  
A: Your API key remains on the device until you explicitly log out. Make sure to log out on shared devices.

**Q: Can I export my chat history?**  
A: This feature is planned for a future update.

**Q: Is there a limit to how many messages I can send?**  
A: The limit is based on Google's API limits (see [API Limits](#api-limits) section).

**Q: Can other users see my conversations?**  
A: No, all conversations are stored locally on your device and are not accessible to other users.

**Q: What if Google changes their API pricing?**  
A: Google's free tier is generous, but if you exceed the limits, you may need to set up billing in Google Cloud Console.

## Credits

- **AI Model**: Google Gemini 1.5 Flash
- **Developer**: Mufthakherul
- **Institution**: Rangpur Polytechnic Institute

---

**Last Updated**: November 2025  
**Version**: 1.0.0
