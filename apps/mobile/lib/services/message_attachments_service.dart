import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:appwrite/appwrite.dart';

/// Service to handle message attachments (images, files, videos, audio, documents)
class MessageAttachmentsService {
  static final MessageAttachmentsService _instance =
      MessageAttachmentsService._internal();
  factory MessageAttachmentsService() => _instance;
  MessageAttachmentsService._internal();

  final _appwrite = AppwriteService();
  static const String _bucketId = AppwriteConfig.messageAttachmentsBucketId;
  static const int _maxFileSizeMB = 50; // 50 MB max file size
  static const int _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;

  /// Supported file extensions by category
  static const Map<String, List<String>> supportedExtensions = {
    'image': ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'],
    'video': ['mp4', 'mov', 'avi', 'mkv', 'webm'],
    'audio': ['mp3', 'wav', 'ogg', 'm4a', 'aac'],
    'document': ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
    'file': ['zip', 'rar', '7z', 'tar', 'gz'],
  };

  /// Upload attachment to Supabase storage
  Future<Map<String, dynamic>> uploadAttachment({
    required File file,
    required String userId,
    String? customFileName,
  }) async {
    try {
      // Check file size
      final fileSize = await file.length();
      if (fileSize > _maxFileSizeBytes) {
        throw Exception(
          'File size (${_formatFileSize(fileSize)}) exceeds maximum allowed size ($_maxFileSizeMB MB)',
        );
      }

      // Generate unique file name
      final fileName = customFileName ?? path.basename(file.path);
      final fileExtension = path
          .extension(fileName)
          .toLowerCase()
          .replaceAll('.', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${userId}_${timestamp}_$fileName';
      final filePath = '$userId/$uniqueFileName';

      if (kDebugMode) {
        print('Uploading attachment: $fileName (${_formatFileSize(fileSize)})');
      }

      // Upload to Appwrite storage
      final uploadedFile = await _appwrite.storage.createFile(
        bucketId: _bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: uniqueFileName),
      );

      // Get file URL
      final fileUrl = '${AppwriteConfig.endpoint}/storage/buckets/$_bucketId/files/${uploadedFile.$id}/view?project=${AppwriteConfig.projectId}';

      // Generate thumbnail for images/videos if needed
      String? thumbnailUrl;
      if (_isImageFile(fileExtension) || _isVideoFile(fileExtension)) {
        thumbnailUrl = fileUrl; // Can be enhanced with actual thumbnail generation
      }

      if (kDebugMode) {
        print('Upload successful: $fileUrl');
      }

      return {
        'url': fileUrl,
        'fileId': uploadedFile.$id,
        'fileName': fileName,
        'fileSize': fileSize,
        'filePath': filePath,
        'thumbnailUrl': thumbnailUrl,
        'extension': fileExtension,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading attachment: $e');
      }
      rethrow;
    }
  }

  /// Delete attachment from storage
  Future<void> deleteAttachment(String fileId) async {
    try {
      await _appwrite.storage.deleteFile(
        bucketId: _bucketId,
        fileId: fileId,
      );

      if (kDebugMode) {
        print('Deleted attachment: $fileId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting attachment: $e');
      }
      rethrow;
    }
  }

  /// Download attachment to local storage
  Future<File> downloadAttachment({
    required String url,
    required String fileId,
    required String fileName,
    required String savePath,
  }) async {
    try {
      if (kDebugMode) {
        print('Downloading attachment: $fileName');
      }

      // Download file from Appwrite
      final bytes = await _appwrite.storage.getFileDownload(
        bucketId: _bucketId,
        fileId: fileId,
      );

      // Save to local storage
      final file = File('$savePath/$fileName');
      await file.writeAsBytes(bytes);

      if (kDebugMode) {
        print('Downloaded to: ${file.path}');
      }

      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading attachment: $e');
      }
      rethrow;
    }
  }

  /// Check if file is an image
  bool _isImageFile(String extension) {
    return supportedExtensions['image']!.contains(extension);
  }

  /// Check if file is a video
  bool _isVideoFile(String extension) {
    return supportedExtensions['video']!.contains(extension);
  }

  /// Check if file extension is supported
  bool isSupportedFile(String extension) {
    return supportedExtensions.values.any((list) => list.contains(extension));
  }

  /// Get category for file extension
  String? getFileCategory(String extension) {
    for (final entry in supportedExtensions.entries) {
      if (entry.value.contains(extension)) {
        return entry.key;
      }
    }
    return 'file'; // Default category
  }

  /// Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get max file size in MB
  int get maxFileSizeMB => _maxFileSizeMB;

  /// Get max file size in bytes
  int get maxFileSizeBytes => _maxFileSizeBytes;
}
