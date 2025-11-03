import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:campus_mesh/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for scraping notices from the school website
/// URL: https://rangpur.polytech.gov.bd/site/view/notices
class WebsiteScraperService {
  static final WebsiteScraperService _instance =
      WebsiteScraperService._internal();
  factory WebsiteScraperService() => _instance;
  WebsiteScraperService._internal();

  static const String _websiteUrl =
      'https://rangpur.polytech.gov.bd/site/view/notices';
  static const String _apiUrl =
      'https://rangpur.polytech.gov.bd/api/datatable/notices_view.php';
  static const String _cacheKey = 'scraped_notices_cache';
  static const String _lastCheckKey = 'last_scrape_check';

  Timer? _pollingTimer;
  final _noticesController = StreamController<List<ScrapedNotice>>.broadcast();

  Stream<List<ScrapedNotice>> get noticesStream => _noticesController.stream;

  /// Start periodic checking for new notices
  void startPeriodicCheck({Duration interval = const Duration(minutes: 30)}) {
    _pollingTimer?.cancel();
    _fetchNotices(); // Fetch immediately
    _pollingTimer = Timer.periodic(interval, (_) => _fetchNotices());
  }

  /// Stop periodic checking
  void stopPeriodicCheck() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetch notices from website
  Future<List<ScrapedNotice>> _fetchNotices() async {
    try {
      debugPrint('Fetching notices from website API...');

      // The website uses DataTables with server-side processing
      // Data is loaded via AJAX from the API endpoint
      // We need to make a POST request to the DataTables API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; RPICommunicationApp/1.0)',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'draw': '1',
          'start': '0',
          'length': '20', // Fetch 20 notices at a time
          'domain_id': '',
          'lang': 'bn',
          'subdomain': '',
          'content_type': 'notices',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to load website: ${response.statusCode}');
      }

      // Parse JSON response from DataTables API
      final notices = _parseNoticesFromApi(response.body);

      // Cache the results
      await _cacheNotices(notices);

      // Update last check time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);

      // Notify listeners
      _noticesController.add(notices);

      debugPrint('Fetched ${notices.length} notices from website API');
      return notices;
    } catch (e) {
      debugPrint('Error fetching website notices: $e');

      // Return cached notices on error
      return await _getCachedNotices();
    }
  }

  /// Parse notices from DataTables API JSON response
  List<ScrapedNotice> _parseNoticesFromApi(String jsonString) {
    final notices = <ScrapedNotice>[];

    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // DataTables API returns data in the "data" array
      // Each row is an array: [serial, title_with_link, date, download_link]
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final dataRows = jsonData['data'] as List<dynamic>;

        for (final row in dataRows) {
          if (row is List && row.length >= 3) {
            try {
              // Parse the title column which contains HTML with link
              final titleHtml = row[1].toString();
              final titleDoc = html_parser.parse(titleHtml);
              final titleLink = titleDoc.querySelector('a');

              String title = '';
              String url = '';

              if (titleLink != null) {
                title = titleLink.text.trim();
                url = titleLink.attributes['href'] ?? '';
              } else {
                // Fallback: extract text without HTML
                title = titleDoc.body?.text.trim() ?? '';
              }

              if (title.isEmpty) continue;

              // Parse the date from column 2
              final dateText = row[2].toString().trim();
              final publishedDate = _parseDate(dateText) ?? DateTime.now();

              // Generate a unique ID based on title and date
              final id =
                  'notice_${title.hashCode}_${publishedDate.millisecondsSinceEpoch}';

              notices.add(ScrapedNotice(
                id: id,
                title: title,
                description: title, // Use title as description
                url: _makeAbsoluteUrl(url),
                publishedDate: publishedDate,
                source: 'College Website',
              ));
            } catch (e) {
              debugPrint('Error parsing notice row: $e');
              continue;
            }
          }
        }
      }

      debugPrint('Parsed ${notices.length} notices from API response');
    } catch (e) {
      debugPrint('Error parsing API response: $e');
    }

    return notices;
  }

  /// Convert relative URL to absolute URL
  String _makeAbsoluteUrl(String url) {
    const baseUrl = 'https://rangpur.polytech.gov.bd';

    if (url.isEmpty) return _websiteUrl;
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }

  // Pre-compiled regex patterns for date parsing
  static final _datePatternDDMMYYYY =
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})');
  static final _datePatternYYYYMMDD =
      RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})');

  /// Parse date from text
  DateTime? _parseDate(String? dateText) {
    if (dateText == null || dateText.isEmpty) return null;

    try {
      // Try YYYY-MM-DD format
      final matchYYYY = _datePatternYYYYMMDD.firstMatch(dateText);
      if (matchYYYY != null) {
        try {
          return DateTime.parse(dateText);
        } catch (e) {
          debugPrint('Error parsing YYYY-MM-DD date: $e');
        }
      }

      // Try DD/MM/YYYY format
      final matchDD = _datePatternDDMMYYYY.firstMatch(dateText);
      if (matchDD != null) {
        try {
          final day = int.parse(matchDD.group(1)!);
          final month = int.parse(matchDD.group(2)!);
          final year = int.parse(matchDD.group(3)!);
          return DateTime(year, month, day);
        } catch (e) {
          debugPrint('Error parsing DD/MM/YYYY date: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }

    return null;
  }

  /// Cache notices locally
  Future<void> _cacheNotices(List<ScrapedNotice> notices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final noticesJson = notices.map((n) => n.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(noticesJson));
    } catch (e) {
      debugPrint('Error caching notices: $e');
    }
  }

  /// Get cached notices
  Future<List<ScrapedNotice>> _getCachedNotices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData == null) return [];

      final List<dynamic> noticesJson = jsonDecode(cachedData);
      return noticesJson.map((json) => ScrapedNotice.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading cached notices: $e');
      return [];
    }
  }

  /// Get notices (from cache or fetch new)
  Future<List<ScrapedNotice>> getNotices({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return await _fetchNotices();
    }

    // Check if we need to refresh based on last check time
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);

    if (lastCheck == null ||
        DateTime.now().millisecondsSinceEpoch - lastCheck > 1800000) {
      // 30 minutes
      return await _fetchNotices();
    }

    return await _getCachedNotices();
  }

  /// Sync scraped notices to the database
  /// This method should be called by NoticeService to persist scraped notices
  Future<void> syncToDatabase(
    Future<String> Function({
      required String title,
      required String content,
      required String type,
      required String targetAudience,
      DateTime? expiresAt,
      required String source,
      String? sourceUrl,
    }) createNoticeCallback,
  ) async {
    try {
      final notices = await getNotices(forceRefresh: true);

      debugPrint('Syncing ${notices.length} scraped notices to database...');

      for (final notice in notices) {
        try {
          await createNoticeCallback(
            title: notice.title,
            content: notice.description,
            type: 'announcement',
            targetAudience: 'all',
            source: 'scraped',
            sourceUrl: notice.url,
          );
        } catch (e) {
          debugPrint('Error syncing notice "${notice.title}": $e');
          // Continue with next notice even if one fails
        }
      }

      debugPrint('Finished syncing scraped notices to database');
    } catch (e) {
      debugPrint('Error syncing scraped notices: $e');
    }
  }

  /// Get time of last successful check
  Future<DateTime?> getLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey);

      if (lastCheck == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(lastCheck);
    } catch (e) {
      return null;
    }
  }

  /// Convert scraped notices to notification models
  List<NotificationModel> toNotificationModels(
    List<ScrapedNotice> notices,
    String userId,
  ) {
    return notices.map((notice) {
      return NotificationModel(
        id: notice.id,
        userId: userId,
        type: 'website_notice',
        title: notice.title,
        body: notice.description,
        data: {
          'url': notice.url,
          'source': notice.source,
          'publishedDate': notice.publishedDate.toIso8601String(),
        },
        createdAt: notice.publishedDate,
        read: false,
      );
    }).toList();
  }

  void dispose() {
    stopPeriodicCheck();
    _noticesController.close();
  }
}

/// Model for scraped notice from website
class ScrapedNotice {
  final String id;
  final String title;
  final String description;
  final String url;
  final DateTime publishedDate;
  final String source;

  ScrapedNotice({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.publishedDate,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'url': url,
        'publishedDate': publishedDate.toIso8601String(),
        'source': source,
      };

  factory ScrapedNotice.fromJson(Map<String, dynamic> json) => ScrapedNotice(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        url: json['url'] ?? '',
        publishedDate: DateTime.parse(json['publishedDate']),
        source: json['source'] ?? 'Website',
      );
}
