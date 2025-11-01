import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:campus_mesh/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for scraping notices from the school website
/// URL: https://rangpur.polytech.gov.bd/site/view/notices
class WebsiteScraperService {
  static final WebsiteScraperService _instance = WebsiteScraperService._internal();
  factory WebsiteScraperService() => _instance;
  WebsiteScraperService._internal();

  static const String _websiteUrl = 'https://rangpur.polytech.gov.bd/site/view/notices';
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
      debugPrint('Fetching notices from website...');
      
      // Note: Since we cannot directly parse HTML without additional packages,
      // we'll implement a basic approach using HTTP client
      // For production, consider using packages like html or web_scraper
      
      final response = await http.get(
        Uri.parse(_websiteUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; RPICommunicationApp/1.0)',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to load website: ${response.statusCode}');
      }

      // Parse HTML to extract notices
      // This is a simplified implementation
      // In production, use a proper HTML parser
      final notices = _parseNoticesFromHtml(response.body);
      
      // Cache the results
      await _cacheNotices(notices);
      
      // Update last check time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
      
      // Notify listeners
      _noticesController.add(notices);
      
      debugPrint('Fetched ${notices.length} notices from website');
      return notices;
    } catch (e) {
      debugPrint('Error fetching website notices: $e');
      
      // Return cached notices on error
      return await _getCachedNotices();
    }
  }

  /// Parse notices from HTML content
  /// This is a simplified implementation
  /// For production, use a proper HTML parser like html package
  List<ScrapedNotice> _parseNoticesFromHtml(String html) {
    final notices = <ScrapedNotice>[];
    
    try {
      // TODO: Implement proper HTML parsing using 'html' package
      // This is a placeholder that returns empty list
      // 
      // Recommended approach:
      // 1. Add dependency: html: ^0.15.4
      // 2. Parse HTML: var document = parse(html);
      // 3. Find notice elements: document.querySelectorAll('.notice-item');
      // 4. Extract title, date, link from each element
      // 5. Create ScrapedNotice objects from extracted data
      //
      // Example (uncomment when html package is added):
      // var document = parse(html);
      // var noticeElements = document.querySelectorAll('.notice-item');
      // for (var element in noticeElements) {
      //   notices.add(ScrapedNotice(
      //     id: element.attributes['id'] ?? 'notice_${DateTime.now().millisecondsSinceEpoch}',
      //     title: element.querySelector('.notice-title')?.text ?? '',
      //     description: element.querySelector('.notice-desc')?.text ?? '',
      //     url: element.querySelector('a')?.attributes['href'] ?? _websiteUrl,
      //     publishedDate: _parseDate(element.querySelector('.notice-date')?.text),
      //     source: 'Website',
      //   ));
      // }
      
      debugPrint('HTML parsing not yet implemented. Add html package for full functionality.');
    } catch (e) {
      debugPrint('Error parsing HTML: $e');
    }
    
    return notices;
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
        DateTime.now().millisecondsSinceEpoch - lastCheck > 1800000) { // 30 minutes
      return await _fetchNotices();
    }
    
    return await _getCachedNotices();
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
  List<NotificationModel> toNotificationModels(List<ScrapedNotice> notices, String userId) {
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
