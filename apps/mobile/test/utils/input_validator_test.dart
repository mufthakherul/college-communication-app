import 'package:campus_mesh/utils/input_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidator - Document ID Tests', () {
    test('should accept valid Appwrite document IDs', () {
      // Test various valid formats
      expect(InputValidator.isValidDocumentId('unique()'), isTrue);
      expect(InputValidator.isValidDocumentId('abc123'), isTrue);
      expect(InputValidator.isValidDocumentId('user_123'), isTrue);
      expect(InputValidator.isValidDocumentId('msg-456'), isTrue);
      expect(InputValidator.isValidDocumentId('a1b2c3d4e5f6'), isTrue);
      expect(InputValidator.isValidDocumentId('123456789'), isTrue);

      // Test longer IDs that Appwrite can generate
      expect(
        InputValidator.isValidDocumentId('a' * 37),
        isTrue,
      ); // 37 chars - should pass now
      expect(InputValidator.isValidDocumentId('a' * 50), isTrue); // 50 chars
      expect(InputValidator.isValidDocumentId('a' * 100), isTrue); // 100 chars
      expect(
        InputValidator.isValidDocumentId(
          'user_1234567890_abcdefghijklmnopqrstuvwxyz',
        ),
        isTrue,
      );

      // Test typical Appwrite ID.unique() format (longer IDs)
      expect(
        InputValidator.isValidDocumentId(
          '5f8a7b2c9d1e2f3g4h5i6j7k8l9m0n1o2p3q',
        ),
        isTrue,
      );
    });

    test('should reject invalid document IDs', () {
      // Test invalid formats
      expect(InputValidator.isValidDocumentId(null), isFalse);
      expect(InputValidator.isValidDocumentId(''), isFalse);
      expect(InputValidator.isValidDocumentId('id with spaces'), isFalse);
      expect(InputValidator.isValidDocumentId('id@special'), isFalse);
      expect(InputValidator.isValidDocumentId('id#hash'), isFalse);
      expect(
        InputValidator.isValidDocumentId('a' * 256),
        isFalse,
      ); // Too long (>255)
    });
  });

  group('InputValidator - UUID Tests', () {
    test('should accept valid UUIDs', () {
      expect(
        InputValidator.isValidUuid('550e8400-e29b-41d4-a716-446655440000'),
        isTrue,
      );
      expect(
        InputValidator.isValidUuid('6ba7b810-9dad-11d1-80b4-00c04fd430c8'),
        isTrue,
      );
      expect(
        InputValidator.isValidUuid('6ba7b811-9dad-11d1-80b4-00c04fd430c8'),
        isTrue,
      );
    });

    test('should reject invalid UUIDs', () {
      expect(InputValidator.isValidUuid(null), isFalse);
      expect(InputValidator.isValidUuid(''), isFalse);
      expect(InputValidator.isValidUuid('not-a-uuid'), isFalse);
      expect(InputValidator.isValidUuid('123456'), isFalse);
      expect(InputValidator.isValidUuid('550e8400-e29b-41d4-a716'), isFalse);
    });
  });

  group('InputValidator - Message Sanitization', () {
    test('should sanitize message content', () {
      expect(InputValidator.sanitizeMessage('Hello world'), 'Hello world');
      expect(InputValidator.sanitizeMessage('  Hello  '), 'Hello');
      expect(
        InputValidator.sanitizeMessage('Test\nmultiline\nmessage'),
        'Test\nmultiline\nmessage',
      );
    });

    test('should remove HTML tags from messages', () {
      expect(
        InputValidator.sanitizeMessage('<script>alert("XSS")</script>'),
        'alert("XSS")',
      );
      expect(InputValidator.sanitizeMessage('<b>Bold text</b>'), 'Bold text');
      expect(InputValidator.sanitizeMessage('<a href="#">Link</a>'), 'Link');
    });

    test('should handle null and empty messages', () {
      expect(InputValidator.sanitizeMessage(null), isNull);
      expect(InputValidator.sanitizeMessage(''), isNull);
      expect(InputValidator.sanitizeMessage('   '), isNull);
    });

    test('should enforce maximum message length', () {
      final longMessage = 'a' * 6000;
      final sanitized = InputValidator.sanitizeMessage(longMessage);
      expect(sanitized?.length, lessThanOrEqualTo(5000));
    });
  });

  group('InputValidator - Search Query Sanitization', () {
    test('should sanitize search queries', () {
      expect(InputValidator.sanitizeSearchQuery('test query'), 'test query');
      expect(InputValidator.sanitizeSearchQuery('test  query'), 'test query');
      expect(InputValidator.sanitizeSearchQuery('  test  '), 'test');
    });

    test('should remove special characters from search', () {
      expect(InputValidator.sanitizeSearchQuery('test<script>'), 'testscript');
      expect(
        InputValidator.sanitizeSearchQuery('test@example'),
        'test@example',
      );
      expect(InputValidator.sanitizeSearchQuery('test!'), 'test!');
    });

    test('should handle null and empty search queries', () {
      expect(InputValidator.sanitizeSearchQuery(null), isNull);
      expect(InputValidator.sanitizeSearchQuery(''), isNull);
      expect(InputValidator.sanitizeSearchQuery('   '), isNull);
    });
  });
}
