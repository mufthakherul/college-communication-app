import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Type of QR code data
enum QRDataType {
  devicePairing,
  noticeShare,
  messageShare,
  contactInfo,
  fileInfo,
  custom,
}

/// QR code data wrapper for sharing information
class QRCodeData {
  final QRDataType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? senderId;
  final String? senderName;

  QRCodeData({
    required this.type,
    required this.data,
    DateTime? createdAt,
    this.expiresAt,
    this.senderId,
    this.senderName,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if QR code is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'senderId': senderId,
    'senderName': senderName,
    'appSignature': 'campus_mesh_v1', // App-specific signature
  };

  /// Create from JSON
  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      type: QRDataType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QRDataType.custom,
      ),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
    );
  }

  /// Convert to QR string
  String toQRString() {
    try {
      final jsonData = toJson();
      return jsonEncode(jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error encoding QR data: $e');
      }
      rethrow;
    }
  }

  /// Create from QR string
  factory QRCodeData.fromQRString(String qrString) {
    try {
      final json = jsonDecode(qrString) as Map<String, dynamic>;

      // Verify app signature
      if (json['appSignature'] != 'campus_mesh_v1') {
        throw Exception('Invalid QR code format');
      }

      return QRCodeData.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding QR string: $e');
      }
      rethrow;
    }
  }

  /// Get human-readable description
  String getDescription() {
    switch (type) {
      case QRDataType.devicePairing:
        return 'Device Pairing';
      case QRDataType.noticeShare:
        return 'Notice';
      case QRDataType.messageShare:
        return 'Message';
      case QRDataType.contactInfo:
        return 'Contact Information';
      case QRDataType.fileInfo:
        return 'File Information';
      case QRDataType.custom:
        return 'Custom Data';
    }
  }
}

/// Service for generating and parsing QR codes for data sharing
class QRDataService {
  static final QRDataService _instance = QRDataService._internal();
  factory QRDataService() => _instance;
  QRDataService._internal();

  /// Generate QR code for sharing a notice
  QRCodeData generateNoticeQR({
    required String noticeId,
    required String title,
    required String content,
    required String type,
    String? senderId,
    String? senderName,
    Duration? expiry,
  }) {
    return QRCodeData(
      type: QRDataType.noticeShare,
      data: {
        'noticeId': noticeId,
        'title': title,
        'content': content,
        'noticeType': type,
      },
      senderId: senderId,
      senderName: senderName,
      expiresAt: expiry != null ? DateTime.now().add(expiry) : null,
    );
  }

  /// Generate QR code for sharing a message
  QRCodeData generateMessageQR({
    required String messageId,
    required String content,
    String? senderId,
    String? senderName,
    Duration? expiry,
  }) {
    return QRCodeData(
      type: QRDataType.messageShare,
      data: {'messageId': messageId, 'content': content},
      senderId: senderId,
      senderName: senderName,
      expiresAt: expiry != null ? DateTime.now().add(expiry) : null,
    );
  }

  /// Generate QR code for sharing contact information
  QRCodeData generateContactQR({
    required String userId,
    required String name,
    required String email,
    String? department,
    String? year,
    String? role,
  }) {
    return QRCodeData(
      type: QRDataType.contactInfo,
      data: {
        'userId': userId,
        'name': name,
        'email': email,
        'department': department,
        'year': year,
        'role': role,
      },
      senderId: userId,
      senderName: name,
    );
  }

  /// Generate QR code for file information
  QRCodeData generateFileInfoQR({
    required String fileId,
    required String fileName,
    required String fileType,
    required int fileSize,
    String? downloadUrl,
    String? senderId,
    String? senderName,
    Duration? expiry,
  }) {
    return QRCodeData(
      type: QRDataType.fileInfo,
      data: {
        'fileId': fileId,
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'downloadUrl': downloadUrl,
      },
      senderId: senderId,
      senderName: senderName,
      expiresAt: expiry != null ? DateTime.now().add(expiry) : null,
    );
  }

  /// Generate custom QR code
  QRCodeData generateCustomQR({
    required Map<String, dynamic> data,
    String? senderId,
    String? senderName,
    Duration? expiry,
  }) {
    return QRCodeData(
      type: QRDataType.custom,
      data: data,
      senderId: senderId,
      senderName: senderName,
      expiresAt: expiry != null ? DateTime.now().add(expiry) : null,
    );
  }

  /// Parse QR code string
  QRCodeData? parseQRCode(String qrString) {
    try {
      return QRCodeData.fromQRString(qrString);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse QR code: $e');
      }
      return null;
    }
  }

  /// Validate QR code
  bool validateQRCode(String qrString) {
    try {
      final qrData = QRCodeData.fromQRString(qrString);
      return !qrData.isExpired;
    } catch (e) {
      return false;
    }
  }
}
