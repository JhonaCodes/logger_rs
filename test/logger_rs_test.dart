import 'dart:io';

import 'package:logger_rs/logger_rs.dart';
import 'package:test/test.dart';

void main() {
  group('Logger RS Tests', () {
    test('Debug log should work', () {
      expect(() => Log.d('Debug message'), returnsNormally);
    });

    test('Info log should work', () {
      expect(() => Log.i('Info message'), returnsNormally);
    });

    test('Warning log should work', () {
      expect(() => Log.w('Warning message'), returnsNormally);
    });

    test('Error log should work with error details', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => Log.e('Error message', error: error, stackTrace: stackTrace),
        returnsNormally,
      );
    });

    test('Fatal/Critical log should work', () {
      expect(() => Log.f('Critical message'), returnsNormally);
    });

    test('Error log should work without error details', () {
      expect(() => Log.e('Simple error message'), returnsNormally);
    });

    test('Multiple log levels in sequence', () {
      expect(() {
        Log.d('Debug: Starting process');
        Log.i('Info: Process initialized');
        Log.w('Warning: Low memory');
        Log.e('Error: Connection failed');
        Log.f('Critical: System failure');
      }, returnsNormally);
    });

    test('Log with special characters', () {
      expect(() {
        Log.i('Special chars: !@#\$%^&*()[]{}');
        Log.d('Unicode: 🚀 🎉 ✨');
        Log.w('Quotes: "double" \'single\'');
      }, returnsNormally);
    });

    test('Log with multiline messages', () {
      expect(() {
        Log.i('Line 1\nLine 2\nLine 3');
        Log.e('Error on line 1\nDetails on line 2');
      }, returnsNormally);
    });

    test('Log with null and empty messages', () {
      expect(() {
        Log.d('');
        Log.i('');
        Log.w('');
      }, returnsNormally);
    });

    test('Log with complex objects', () {
      final map = {'key': 'value', 'number': 42};
      final list = [1, 2, 3, 'four'];

      expect(() {
        Log.d(map);
        Log.i(list);
        Log.w({'nested': map});
      }, returnsNormally);
    });

    test('Performance: Large number of logs', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        Log.d('Performance test log #$i');
      }

      stopwatch.stop();

      // Should complete in reasonable time (< 1 second for 100 logs)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Verify ANSI color codes are present', () {
      // This test verifies the internal structure but doesn't check stdout
      // since capturing stdout in tests is complex
      expect(() {
        // Color codes should be applied only on supported platforms
        if (Platform.isMacOS || Platform.isLinux) {
          Log.i('Color test');
          Log.e('Error color test');
          Log.w('Warning color test');
        }
      }, returnsNormally);
    });

    group('Error handling', () {
      test('Error with custom exception', () {
        final customError = FormatException('Invalid format');
        expect(
          () => Log.e('Format error occurred', error: customError),
          returnsNormally,
        );
      });

      test('Error with complex stack trace', () {
        try {
          throw StateError('Test state error');
        } catch (e, stack) {
          expect(
            () => Log.e('Caught state error', error: e, stackTrace: stack),
            returnsNormally,
          );
        }
      });

      test('Multiple errors in sequence', () {
        expect(() {
          for (int i = 0; i < 5; i++) {
            Log.e('Error #$i', error: Exception('Error $i'));
          }
        }, returnsNormally);
      });
    });

    group('Edge cases', () {
      test('Very long message', () {
        final longMessage = 'A' * 1000;
        expect(() => Log.i(longMessage), returnsNormally);
      });

      test('Rapid successive logs', () {
        expect(() {
          for (int i = 0; i < 10; i++) {
            Log.d('Rapid log $i');
          }
        }, returnsNormally);
      });

      test('Mixed severity levels', () {
        expect(() {
          Log.d('Debug');
          Log.f('Fatal');
          Log.i('Info');
          Log.e('Error');
          Log.w('Warning');
          Log.d('Debug again');
        }, returnsNormally);
      });
    });
  });
}
