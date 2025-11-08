# Group Chat Improvements - Comprehensive Plan

**Date:** November 8, 2025  
**Status:** Planning Phase

## Current Structure Analysis

### Current Implementation

1. **ChatScreen** - P2P (1-on-1) chat only
   - Takes a single `UserModel` as parameter
   - Not designed for group conversations
2. **CreateGroupChatScreen** - Group creation UI
   - Allows creating named groups with multiple participants
   - Stores group in `chat_service.dart`
3. **Messages Flow**
   - P2P messages go through `message_service.dart`
   - Group chat logic exists in `chat_service.dart` but UI missing
4. **Chat Management**
   - `ChatManagementScreen` exists for admin management
   - Groups can be created and joined via invite codes

### Issues Identified

1. **No Dedicated Group Chat Screen** - Groups created but no UI to view/chat in them
2. **P2P Chat Screen Not Adapted** - Current ChatScreen is hardcoded for 1-on-1
3. **Message Structure** - Messages may not properly track group context
4. **Sender Attribution** - Need to show who sent each message in groups
5. **UI/UX Gaps**
   - No participant list view
   - No group member indicators
   - No context switching (P2P vs Group)
   - Message timestamps/read receipts limited

## Improvement Plan

### Phase 1: Message Model Enhancement

- [ ] Extend `MessageModel` to support group message context
- [ ] Add fields: `groupId`, `groupName`, `senderDisplayName`, `senderPhotoUrl`
- [ ] Ensure backward compatibility with P2P messages

### Phase 2: Create GroupChatScreen

- [ ] New file: `group_chat_screen.dart`
- [ ] Display group name in AppBar
- [ ] Show participant list (expandable)
- [ ] Display sender name in message bubbles for group context
- [ ] Handle group-specific actions (leave group, etc.)

### Phase 3: Unify Chat Navigation

- [ ] Modify `ChatScreen` to accept both P2P and group context
- **OR** Create abstraction layer to route to correct screen

### Phase 4: Message Service Updates

- [ ] Add group message sending capability
- [ ] Fetch group messages with participant info
- [ ] Handle group-specific permissions

### Phase 5: UI/UX Enhancements

- [ ] Add participant avatars in message bubbles
- [ ] Show "Person is typing..." for group chats
- [ ] Add member count badge
- [ ] Improve message grouping by sender

### Phase 6: Group Settings/Management

- [ ] Add settings button in group chat header
- [ ] Ability to leave group
- [ ] View group members list
- [ ] Search messages within group

## Implementation Priority

**HIGH Priority:**

1. Create GroupChatScreen (required for group functionality)
2. Message model updates for group support
3. Service layer for group messaging

**MEDIUM Priority:** 4. Participant display in bubbles 5. Group member list view 6. Message improvements (timestamps, avatars)

**LOW Priority (Polish):** 7. Typing indicators 8. Read receipts 9. Message reactions 10. Search/filter

## Expected Deliverables

1. **GroupChatScreen** - Fully functional group chat UI
2. **Enhanced MessageModel** - Group-aware message structure
3. **Updated Services** - Group message handling
4. **Improved ChatList** - Shows both P2P and group conversations
5. **Better UX** - Clear sender attribution, group context

## Technical Considerations

- **Backward Compatibility** - Must work with existing P2P chats
- **Performance** - Groups with many members should load efficiently
- **Offline Support** - Groups should work with local database
- **Real-time Updates** - Stream-based updates for group messages
- **Accessibility** - Clear visual hierarchy for group context
