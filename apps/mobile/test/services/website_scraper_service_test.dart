import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/website_scraper_service.dart';
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
      scraperService.startPeriodicCheck(interval: const Duration(seconds: 1));

      // Verify it doesn't throw errors
      expect(() => scraperService.stopPeriodicCheck(), returnsNormally);
    });

    test(
      'should fetch notices from website',
      () async {
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
        expect(
          noticesReceived || errorOccurred,
          isTrue,
          reason:
              'Service should respond (either with data or handle errors gracefully)',
        );

        // Log scraping results for verification (using debugPrint for test output)
        debugPrint('\n========================================');
        debugPrint('✅ NOTICE SCRAPING TEST RESULTS');
        debugPrint('========================================');

        if (errorOccurred) {
          debugPrint('⚠️  Network error occurred: $errorMessage');
          debugPrint(
            'This is acceptable in CI environments with limited network access',
          );
          debugPrint('========================================\n');
        } else if (receivedNotices != null) {
          expect(
            receivedNotices,
            isA<List<ScrapedNotice>>(),
            reason: 'Received data should be a list of ScrapedNotice',
          );

          debugPrint('Total notices scraped: ${receivedNotices!.length}');

          // If notices were found, verify their structure and display details
          if (receivedNotices!.isNotEmpty) {
            debugPrint('\n📋 LATEST NOTICE DETAILS:');
            debugPrint('----------------------------------------');

            final latestNotice = receivedNotices!.first;
            debugPrint('ID: ${latestNotice.id}');
            debugPrint('Title: ${latestNotice.title}');
            debugPrint('Description: ${latestNotice.description}');
            debugPrint('URL: ${latestNotice.url}');
            debugPrint('Published Date: ${latestNotice.publishedDate}');
            debugPrint('Source: ${latestNotice.source}');
            debugPrint('----------------------------------------');

            // Show all notices in brief
            if (receivedNotices!.length > 1) {
              debugPrint('\n📄 ALL SCRAPED NOTICES:');
              for (int i = 0; i < receivedNotices!.length; i++) {
                final notice = receivedNotices![i];
                debugPrint(
                  '${i + 1}. ${notice.title} (${notice.publishedDate.toLocal().toString().split(' ')[0]})',
                );
              }
            }
            debugPrint('========================================\n');

            // Verify structure
            expect(
              latestNotice.id,
              isNotEmpty,
              reason: 'Notice should have an ID',
            );
            expect(
              latestNotice.title,
              isNotEmpty,
              reason: 'Notice should have a title',
            );
            expect(
              latestNotice.source,
              equals('College Website'),
              reason: 'Notice source should be College Website',
            );
          } else {
            debugPrint('⚠️  No notices found on the website');
            debugPrint('This could mean:');
            debugPrint('  - The website has no notices currently');
            debugPrint('  - The HTML structure has changed');
            debugPrint('  - Network/connectivity issues');
            debugPrint('========================================\n');
          }
        } else {
          debugPrint('⚠️  Service did not emit notices within timeout period');
          debugPrint('Test still passes as service is working correctly');
          debugPrint('========================================\n');
        }
      },
      timeout: const Timeout(Duration(seconds: 40)),
    );

    test(
      'should handle network errors gracefully',
      () async {
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
        expect(
          streamEmitted,
          isTrue,
          reason: 'Service should emit to stream even on errors',
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test('should cache scraped notices', () async {
      // Verify that notices are cached using SharedPreferences

      final subscription = scraperService.noticesStream.listen((notices) {
        // Listen to stream to trigger fetch
      });

      // Fetch notices
      scraperService.startPeriodicCheck();
      await Future.delayed(const Duration(seconds: 5));
      scraperService.stopPeriodicCheck();
      await subscription.cancel();

      // Check if SharedPreferences has cached data
      final prefs = await SharedPreferences.getInstance();
      const cacheKey = 'scraped_notices_cache';
      const lastCheckKey = 'last_scrape_check';

      // At least one of these should be set after a fetch attempt
      final hasCacheKey = prefs.containsKey(cacheKey);
      final hasLastCheckKey = prefs.containsKey(lastCheckKey);

      expect(
        hasCacheKey || hasLastCheckKey,
        isTrue,
        reason: 'Service should cache fetch results or timestamp',
      );
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('WebsiteScraperService HTML Parsing', () {
    test(
      'should parse notices with valid structure',
      () {
        // TODO: Implement HTML parsing test with mock HTML
        // This requires exposing the internal parsing method or using mock HTTP responses
      },
      skip: 'Placeholder - requires refactoring to expose parsing method',
    );

    test(
      'should handle malformed HTML gracefully',
      () {
        // TODO: Test that malformed HTML doesn't crash the parser
      },
      skip: 'Placeholder - requires refactoring to expose parsing method',
    );

    test(
      'should extract absolute URLs from relative paths',
      () {
        // TODO: Test URL normalization logic
      },
      skip: 'Placeholder - requires refactoring to expose URL helper method',
    );

    test(
      'should parse various date formats',
      () {
        // TODO: Test date parsing logic with various formats
      },
      skip: 'Placeholder - requires refactoring to expose date parsing method',
    );
  });

  group('WebsiteScraperService Integration', () {
    test(
      'should integrate with NoticeService',
      () {
        // TODO: Verify that scraped notices can be stored in the notice service
      },
      skip: 'Placeholder - requires NoticeService mock or integration setup',
    );

    test(
      'should not duplicate notices on multiple scrapes',
      () {
        // TODO: Verify that the same notice isn't added multiple times
      },
      skip: 'Placeholder - requires multiple scrape simulation',
    );

    test(
      'should update existing notices if content changes',
      () {
        // TODO: Verify that notices are updated when website content changes
      },
      skip: 'Placeholder - requires mock HTTP responses with different content',
    );
  });
}
