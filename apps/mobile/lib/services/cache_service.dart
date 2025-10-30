import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

/// Cache entry with metadata
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl; // Time to live

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  Duration get age => DateTime.now().difference(timestamp);

  String getAgeText() {
    final ageInSeconds = age.inSeconds;
    if (ageInSeconds < 60) {
      return 'Just now';
    } else if (age.inMinutes < 60) {
      return '${age.inMinutes}m ago';
    } else if (age.inHours < 24) {
      return '${age.inHours}h ago';
    } else {
      return '${age.inDays}d ago';
    }
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'ttl': ttl.inMilliseconds,
      };

  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return CacheEntry(
      data: fromJsonT(json['data']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: Duration(milliseconds: json['ttl'] as int),
    );
  }
}

/// Smart caching service with time-based expiry and size limits
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const int _maxCacheSizeMB = 50; // 50 MB cache limit
  static const Duration _defaultTTL = Duration(hours: 1);
  static const Duration _shortTTL = Duration(minutes: 5);
  static const Duration _longTTL = Duration(days: 1);

  final Map<String, CacheEntry> _memoryCache = {};
  Directory? _cacheDirectory;

  /// Initialize cache service
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      // Clean expired cache on startup
      await cleanExpiredCache();
      
      // Check and enforce cache size limit
      await _enforceCacheSizeLimit();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing cache: $e');
      }
    }
  }

  /// Get cached data
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        if (kDebugMode) {
          print('Cache hit (memory): $key (age: ${entry.getAgeText()})');
        }
        return entry.data as T;
      } else {
        _memoryCache.remove(key);
        if (kDebugMode) {
          print('Cache expired (memory): $key');
        }
      }
    }

    // Check disk cache
    if (_cacheDirectory != null && fromJson != null) {
      final file = File('${_cacheDirectory!.path}/$key.json');
      if (await file.exists()) {
        try {
          final jsonStr = await file.readAsString();
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          final entry = CacheEntry.fromJson(json, (data) => fromJson(data as Map<String, dynamic>));
          
          if (!entry.isExpired) {
            // Store in memory cache for faster access
            _memoryCache[key] = entry;
            
            if (kDebugMode) {
              print('Cache hit (disk): $key (age: ${entry.getAgeText()})');
            }
            return entry.data;
          } else {
            await file.delete();
            if (kDebugMode) {
              print('Cache expired (disk): $key');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error reading cache: $e');
          }
        }
      }
    }

    if (kDebugMode) {
      print('Cache miss: $key');
    }
    return null;
  }

  /// Set cached data
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
    bool persistToDisk = false,
  }) async {
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTTL,
    );

    // Store in memory
    _memoryCache[key] = entry;

    // Optionally persist to disk
    if (persistToDisk && _cacheDirectory != null) {
      try {
        final file = File('${_cacheDirectory!.path}/$key.json');
        final jsonStr = jsonEncode(entry.toJson());
        await file.writeAsString(jsonStr);
        
        if (kDebugMode) {
          print('Cached to disk: $key (ttl: ${entry.ttl.inMinutes}m)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error writing cache: $e');
        }
      }
    }

    if (kDebugMode) {
      print('Cached to memory: $key (ttl: ${entry.ttl.inMinutes}m)');
    }
  }

  /// Remove cached data
  Future<void> remove(String key) async {
    _memoryCache.remove(key);

    if (_cacheDirectory != null) {
      final file = File('${_cacheDirectory!.path}/$key.json');
      if (await file.exists()) {
        await file.delete();
      }
    }

    if (kDebugMode) {
      print('Cache removed: $key');
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();

    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await for (final file in _cacheDirectory!.list()) {
        if (file is File) {
          await file.delete();
        }
      }
    }

    if (kDebugMode) {
      print('Cache cleared');
    }
  }

  /// Clean expired cache entries
  Future<void> cleanExpiredCache() async {
    // Clean memory cache
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // Clean disk cache
    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await for (final file in _cacheDirectory!.list()) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final jsonStr = await file.readAsString();
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            final timestamp = DateTime.parse(json['timestamp'] as String);
            final ttl = Duration(milliseconds: json['ttl'] as int);
            
            if (DateTime.now().difference(timestamp) > ttl) {
              await file.delete();
              if (kDebugMode) {
                print('Deleted expired cache file: ${file.path}');
              }
            }
          } catch (e) {
            // Delete corrupted cache files
            await file.delete();
            if (kDebugMode) {
              print('Deleted corrupted cache file: ${file.path}');
            }
          }
        }
      }
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    int totalSize = 0;

    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await for (final file in _cacheDirectory!.list(recursive: true)) {
        if (file is File) {
          try {
            final stat = await file.stat();
            totalSize += stat.size;
          } catch (e) {
            if (kDebugMode) {
              print('Error getting file size: $e');
            }
          }
        }
      }
    }

    return totalSize;
  }

  /// Get cache size in MB
  Future<double> getCacheSizeMB() async {
    final bytes = await getCacheSize();
    return bytes / (1024 * 1024);
  }

  /// Enforce cache size limit by removing oldest entries
  Future<void> _enforceCacheSizeLimit() async {
    final sizeMB = await getCacheSizeMB();
    
    if (sizeMB > _maxCacheSizeMB) {
      if (kDebugMode) {
        print('Cache size ${sizeMB.toStringAsFixed(2)} MB exceeds limit $_maxCacheSizeMB MB');
      }

      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        // Get all cache files with their timestamps
        final files = <File, DateTime>{};
        
        await for (final file in _cacheDirectory!.list()) {
          if (file is File && file.path.endsWith('.json')) {
            try {
              final jsonStr = await file.readAsString();
              final json = jsonDecode(jsonStr) as Map<String, dynamic>;
              final timestamp = DateTime.parse(json['timestamp'] as String);
              files[file] = timestamp;
            } catch (e) {
              // Delete corrupted files
              await file.delete();
            }
          }
        }

        // Sort files by timestamp (oldest first)
        final sortedFiles = files.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        // Delete oldest files until under limit
        for (final entry in sortedFiles) {
          await entry.key.delete();
          if (kDebugMode) {
            print('Deleted old cache file: ${entry.key.path}');
          }

          final newSizeMB = await getCacheSizeMB();
          if (newSizeMB <= _maxCacheSizeMB) {
            break;
          }
        }
      }
    }
  }

  /// Compress cached data using GZip
  Future<void> compressCache(String key, String data) async {
    if (_cacheDirectory == null) return;

    try {
      final file = File('${_cacheDirectory!.path}/$key.gz');
      final encoder = GZipEncoder();
      final compressed = encoder.encode(utf8.encode(data));
      
      if (compressed != null) {
        await file.writeAsBytes(compressed);
        
        if (kDebugMode) {
          final originalSize = utf8.encode(data).length;
          final compressedSize = compressed.length;
          final ratio = (1 - compressedSize / originalSize) * 100;
          print('Compressed cache: $key (${ratio.toStringAsFixed(1)}% reduction)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing cache: $e');
      }
    }
  }

  /// Decompress cached data
  Future<String?> decompressCache(String key) async {
    if (_cacheDirectory == null) return null;

    try {
      final file = File('${_cacheDirectory!.path}/$key.gz');
      if (await file.exists()) {
        final compressed = await file.readAsBytes();
        final decoder = GZipDecoder();
        final decompressed = decoder.decodeBytes(compressed);
        return utf8.decode(decompressed);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error decompressing cache: $e');
      }
    }

    return null;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final sizeMB = await getCacheSizeMB();
    int fileCount = 0;

    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await for (final file in _cacheDirectory!.list()) {
        if (file is File) {
          fileCount++;
        }
      }
    }

    return {
      'memoryCacheSize': _memoryCache.length,
      'diskCacheSize': fileCount,
      'totalSizeMB': sizeMB,
      'maxSizeMB': _maxCacheSizeMB,
      'usagePercent': (sizeMB / _maxCacheSizeMB * 100).clamp(0, 100),
    };
  }

  /// Get TTL presets
  static Duration get shortTTL => _shortTTL;
  static Duration get defaultTTL => _defaultTTL;
  static Duration get longTTL => _longTTL;
}
