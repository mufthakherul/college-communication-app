import 'package:flutter/foundation.dart';

/// Input validation and sanitization utility
/// Provides security-focused input validation for user-generated content
class InputValidator {
  // Prevent instantiation
  InputValidator._();

  /// Maximum lengths for different input types
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int maxPhoneLength = 20;
  static const int maxTitleLength = 200;
  static const int maxContentLength = 10000;
  static const int maxMessageLength = 5000;
  static const int maxUrlLength = 2048;

  /// Validates and sanitizes user display name
  /// Returns sanitized string or null if invalid
  static String? sanitizeName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return null;
    }

    // Remove leading/trailing whitespace
    String sanitized = name.trim();

    // Check length
    if (sanitized.length > maxNameLength) {
      sanitized = sanitized.substring(0, maxNameLength);
    }

    // Remove potentially dangerous characters (HTML/script tags)
    sanitized = sanitized.replaceAll(RegExp(r'[<>]'), '');

    // Remove null bytes and control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    if (sanitized.isEmpty) {
      return null;
    }

    return sanitized;
  }

  /// Validates email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    if (email.length > maxEmailLength) return false;

    // RFC 5322 simplified email regex
    final emailRegex = RegExp(
      r'''^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$''',
    );

    return emailRegex.hasMatch(email);
  }

  /// Validates phone number format (Bangladesh phone numbers)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    if (phone.length > maxPhoneLength) return false;

    // Remove spaces, dashes, parentheses for validation
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Bangladesh phone number format: starts with +880 or 01, followed by 9 digits
    final phoneRegex = RegExp(r'^(\+?880|0)?1[3-9]\d{8}$');

    return phoneRegex.hasMatch(cleaned);
  }

  /// Sanitizes text content (notices, messages, etc.)
  /// Removes dangerous HTML/script tags while preserving safe formatting
  static String? sanitizeContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return null;
    }

    String sanitized = content.trim();

    // Check length
    if (sanitized.length > maxContentLength) {
      sanitized = sanitized.substring(0, maxContentLength);
    }

    // Remove script tags and their content
    sanitized = sanitized.replaceAll(
      RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
          caseSensitive: false),
      '',
    );

    // Remove potentially dangerous attributes
    sanitized = sanitized.replaceAll(
      RegExp(r'''\s*on\w+\s*=\s*["'][^"']*["']''', caseSensitive: false),
      '',
    );

    // Remove javascript: protocol
    sanitized = sanitized.replaceAll(
      RegExp(r'javascript:', caseSensitive: false),
      '',
    );

    // Remove data: URLs (can be used for XSS)
    sanitized = sanitized.replaceAll(
      RegExp(r'data:[^,]*,', caseSensitive: false),
      '',
    );

    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');

    if (sanitized.isEmpty) {
      return null;
    }

    return sanitized;
  }

  /// Sanitizes message content (stricter than general content)
  static String? sanitizeMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return null;
    }

    String sanitized = message.trim();

    // Check length
    if (sanitized.length > maxMessageLength) {
      sanitized = sanitized.substring(0, maxMessageLength);
    }

    // Remove ALL HTML tags for messages (no HTML allowed)
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove null bytes and control characters (except newlines and tabs)
    sanitized =
        sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    if (sanitized.isEmpty) {
      return null;
    }

    return sanitized;
  }

  /// Validates URL format
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    if (url.length > maxUrlLength) return false;

    try {
      final uri = Uri.parse(url);

      // Only allow http and https schemes
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return false;
      }

      // Must have a host
      if (uri.host.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('URL validation error: $e');
      }
      return false;
    }
  }

  /// Validates UUID format (prevents injection in Appwrite queries)
  static bool isValidUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return false;

    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    return uuidRegex.hasMatch(uuid);
  }

  /// Validates Appwrite document ID format
  static bool isValidDocumentId(String? id) {
    if (id == null || id.isEmpty) return false;

    // Appwrite allows alphanumeric, underscore, and hyphen, 1-36 characters
    final idRegex = RegExp(r'^[a-zA-Z0-9_-]{1,36}$');

    return idRegex.hasMatch(id);
  }

  /// Sanitizes search query to prevent injection
  static String? sanitizeSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return null;
    }

    String sanitized = query.trim();

    // Limit length
    if (sanitized.length > 200) {
      sanitized = sanitized.substring(0, 200);
    }

    // Remove special characters that could be used for injection
    // Keep alphanumeric, spaces, and common punctuation
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\s\-.,!?@]'), '');

    // Remove excessive whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    if (sanitized.isEmpty) {
      return null;
    }

    return sanitized;
  }

  /// Validates password strength
  /// Returns error message or null if valid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 128) {
      return 'Password must be less than 128 characters';
    }

    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      return 'Password must contain at least one letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    return null; // Valid
  }

  /// Validates that confirm password matches password
  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }
}
