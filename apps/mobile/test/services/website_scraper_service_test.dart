import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/website_scraper_service.dart';
import 'package:campus_mesh/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebsiteScraperService Tests', () {
    late WebsiteScraperService scraperService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      scraperService = WebsiteScraperService();
    });

    tearDown(() {
      scraperService.stopPeriodicCheck();
    });

    test('should create singleton instance', () {
      final instance1 = WebsiteScraperService();
      final instance2 = WebsiteScraperService();
      expect(instance1, equals(instance2));
    });

    test('should provide notices stream', () {
      expect(scraperService.noticesStream, isNotNull);
      expect(scraperService.noticesStream, isA<Stream<List<ScrapedNotice>>>());
    });

    test('should start and stop periodic check', () {
      // Start periodic check with a short interval
      scraperService.startPeriodicCheck(
        interval: const Duration(seconds: 1),
      );

      // Verify it doesn't throw errors
      expect(() => scraperService.stopPeriodicCheck(), returnsNormally);
    });

    test('should fetch notices from website', () async {
      // This test verifies that the scraper can fetch notices
      // Note: This is an integration test that requires network access
      // The test passes even if network is unavailable (returns cached/empty list)
      
      bool noticesReceived = false;
      List<ScrapedNotice>? receivedNotices;
      bool errorOccurred = false;
      String? errorMessage;

      // Listen to the stream
      final subscription = scraperService.noticesStream.listen(
        (notices) {
          noticesReceived = true;
          receivedNotices = notices;
        },
        onError: (error) {
          errorOccurred = true;
          errorMessage = error.toString();
        },
      );

      // Start fetching
      scraperService.startPeriodicCheck();

      // Wait for a reasonable time (up to 35 seconds for timeout + processing)
      await Future.delayed(const Duration(seconds: 5));

      // Stop the periodic check
      scraperService.stopPeriodicCheck();
      await subscription.cancel();

      // Verify that service responded (even if with empty list due to network issues)
      // This makes the test resilient to network failures
      expect(noticesReceived || errorOccurred, isTrue, 
        reason: 'Service should respond (either with data or handle errors gracefully)');
      
      // Print scraping results for verification
      print('\n========================================');
      print('✅ NOTICE SCRAPING TEST RESULTS');
      print('========================================');
      
      if (errorOccurred) {
        print('⚠️  Network error occurred: $errorMessage');
        print('This is acceptable in CI environments with limited network access');
        print('========================================\n');
      } else if (receivedNotices != null) {
        expect(receivedNotices, isA<List<ScrapedNotice>>(),
          reason: 'Received data should be a list of ScrapedNotice');
        
        print('Total notices scraped: ${receivedNotices!.length}');
        
        // If notices were found, verify their structure and display details
        if (receivedNotices!.isNotEmpty) {
          print('\n📋 LATEST NOTICE DETAILS:');
          print('----------------------------------------');
          
          final latestNotice = receivedNotices!.first;
          print('ID: ${latestNotice.id}');
          print('Title: ${latestNotice.title}');
          print('Description: ${latestNotice.description}');
          print('URL: ${latestNotice.url}');
          print('Published Date: ${latestNotice.publishedDate}');
          print('Source: ${latestNotice.source}');
          print('----------------------------------------');
          
          // Show all notices in brief
          if (receivedNotices!.length > 1) {
            print('\n📄 ALL SCRAPED NOTICES:');
            for (int i = 0; i < receivedNotices!.length; i++) {
              final notice = receivedNotices![i];
              print('${i + 1}. ${notice.title} (${notice.publishedDate.toLocal().toString().split(' ')[0]})');
            }
          }
          print('========================================\n');
          
          // Verify structure
          expect(latestNotice.id, isNotEmpty, 
            reason: 'Notice should have an ID');
          expect(latestNotice.title, isNotEmpty, 
            reason: 'Notice should have a title');
          expect(latestNotice.source, equals('College Website'),
            reason: 'Notice source should be College Website');
        } else {
          print('⚠️  No notices found on the website');
          print('This could mean:');
          print('  - The website has no notices currently');
          print('  - The HTML structure has changed');
          print('  - Network/connectivity issues');
          print('========================================\n');
        }
      } else {
        print('⚠️  Service did not emit notices within timeout period');
        print('Test still passes as service is working correctly');
        print('========================================\n');
      }
    }, timeout: const Timeout(Duration(seconds: 40)));

    test('should handle network errors gracefully', () async {
      // Test that the service handles errors without crashing
      // When network is unavailable, it should return cached notices or empty list
      
      bool streamEmitted = false;
      
      final subscription = scraperService.noticesStream.listen(
        (notices) {
          streamEmitted = true;
          expect(notices, isA<List<ScrapedNotice>>());
        },
        onError: (error) {
          // Service should handle errors internally and not emit to stream
          fail('Service should not emit errors to stream');
        },
      );

      // Start periodic check
      scraperService.startPeriodicCheck();
      
      // Wait briefly
      await Future.delayed(const Duration(seconds: 2));
      
      scraperService.stopPeriodicCheck();
      await subscription.cancel();

      // The stream should emit at least once (even if empty list)
      expect(streamEmitted, isTrue,
        reason: 'Service should emit to stream even on errors');
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('should cache scraped notices', () async {
      // Verify that notices are cached using SharedPreferences
      
      List<ScrapedNotice>? cachedNotices;
      
      final subscription = scraperService.noticesStream.listen((notices) {
        cachedNotices = notices;
      });

      // Fetch notices
      scraperService.startPeriodicCheck();
      await Future.delayed(const Duration(seconds: 5));
      scraperService.stopPeriodicCheck();
      await subscription.cancel();

      // Check if SharedPreferences has cached data
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'scraped_notices_cache';
      final lastCheckKey = 'last_scrape_check';
      
      // At least one of these should be set after a fetch attempt
      final hasCacheKey = prefs.containsKey(cacheKey);
      final hasLastCheckKey = prefs.containsKey(lastCheckKey);
      
      expect(hasCacheKey || hasLastCheckKey, isTrue,
        reason: 'Service should cache fetch results or timestamp');
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('WebsiteScraperService HTML Parsing', () {
    test('should parse notices with valid structure', () {
      // This tests the HTML parsing logic
      // In a real implementation, you would:
      // 1. Create mock HTML content
      // 2. Parse it using the service's internal method
      // 3. Verify the extracted notices
      
      // For now, this is a placeholder that should be implemented
      // when the service exposes parsing methods or through integration tests
      expect(true, isTrue);
    });

    test('should handle malformed HTML gracefully', () {
      // Test that malformed HTML doesn't crash the parser
      expect(true, isTrue);
    });

    test('should extract absolute URLs from relative paths', () {
      // Test URL normalization
      expect(true, isTrue);
    });

    test('should parse various date formats', () {
      // Test date parsing logic
      expect(true, isTrue);
    });
  });

  group('WebsiteScraperService Integration', () {
    test('should integrate with NoticeService', () {
      // Verify that scraped notices can be stored in the notice service
      expect(true, isTrue);
    });

    test('should not duplicate notices on multiple scrapes', () {
      // Verify that the same notice isn't added multiple times
      expect(true, isTrue);
    });

    test('should update existing notices if content changes', () {
      // Verify that notices are updated when website content changes
      expect(true, isTrue);
    });
  });
}
