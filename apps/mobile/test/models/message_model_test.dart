import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('should create MessageModel with required fields', () {
      final message = MessageModel(
        id: 'msg123',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Hello!',
        type: MessageType.text,
        createdAt: DateTime(2024, 1, 1),
        read: false,
      );

      expect(message.id, 'msg123');
      expect(message.senderId, 'sender123');
      expect(message.recipientId, 'recipient123');
      expect(message.content, 'Hello!');
      expect(message.type, MessageType.text);
      expect(message.read, false);
    });

    test('should convert MessageModel to Map', () {
      final message = MessageModel(
        id: 'msg123',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Test message',
        type: MessageType.text,
        createdAt: DateTime(2024, 1, 1),
        read: false,
      );

      final map = message.toMap();

      expect(map['senderId'], 'sender123');
      expect(map['recipientId'], 'recipient123');
      expect(map['content'], 'Test message');
      expect(map['type'], 'text');
      expect(map['isRead'], false);
    });

    test('should handle all MessageType enum values', () {
      expect(MessageType.text.name, 'text');
      expect(MessageType.image.name, 'image');
      expect(MessageType.file.name, 'file');
    });

    test('should handle read status', () {
      final unreadMessage = MessageModel(
        id: 'msg1',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Unread message',
        type: MessageType.text,
        createdAt: DateTime.now(),
        read: false,
      );

      expect(unreadMessage.read, false);

      final readMessage = MessageModel(
        id: 'msg2',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Read message',
        type: MessageType.text,
        createdAt: DateTime.now(),
        read: true,
      );

      expect(readMessage.read, true);
    });

    test('should support different message types', () {
      final textMessage = MessageModel(
        id: 'msg1',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Text content',
        type: MessageType.text,
        createdAt: DateTime.now(),
        read: false,
      );

      expect(textMessage.type, MessageType.text);

      final imageMessage = MessageModel(
        id: 'msg2',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'https://example.com/image.jpg',
        type: MessageType.image,
        createdAt: DateTime.now(),
        read: false,
      );

      expect(imageMessage.type, MessageType.image);

      final fileMessage = MessageModel(
        id: 'msg3',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'https://example.com/document.pdf',
        type: MessageType.file,
        createdAt: DateTime.now(),
        read: false,
      );

      expect(fileMessage.type, MessageType.file);
    });

    test('should handle optional fileUrl field', () {
      final messageWithFile = MessageModel(
        id: 'msg1',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Check this file',
        type: MessageType.file,
        createdAt: DateTime.now(),
        read: false,
        content: 'https://example.com/file.pdf',
      );

      expect(messageWithFile.content, 'https://example.com/file.pdf');

      final messageWithoutFile = MessageModel(
        id: 'msg2',
        senderId: 'sender123',
        recipientId: 'recipient123',
        content: 'Just text',
        type: MessageType.text,
        createdAt: DateTime.now(),
        read: false,
      );

      expect(messageWithoutFile.content, null);
    });
  });
}
