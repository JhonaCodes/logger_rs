import 'package:logger_rs/logger_rs.dart';
import 'package:test/test.dart';

void main() {
  group('Logger RS Tests', () {
    group('Basic logging', () {
      test('Debug log (d) should work', () {
        expect(() => Log.d('Debug message'), returnsNormally);
      });

      test('Info log (i) should work', () {
        expect(() => Log.i('Info message'), returnsNormally);
      });

      test('Warning log (w) should work', () {
        expect(() => Log.w('Warning message'), returnsNormally);
      });

      test('Error log (e) should work', () {
        expect(() => Log.e('Error message'), returnsNormally);
      });

      test('Fatal/Critical log (f) should work', () {
        expect(() => Log.f('Critical message'), returnsNormally);
      });

      test('Trace log (t) should work', () {
        expect(() => Log.t('Trace message'), returnsNormally);
      });
    });

    group('Error logging with details', () {
      test('Error with error object', () {
        final error = Exception('Test error');
        expect(
          () => Log.e('Error occurred', error: error),
          returnsNormally,
        );
      });

      test('Error with stack trace', () {
        final stackTrace = StackTrace.current;
        expect(
          () => Log.e('Error occurred', stackTrace: stackTrace),
          returnsNormally,
        );
      });

      test('Error with both error and stack trace', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        expect(
          () => Log.e('Error occurred', error: error, stackTrace: stackTrace),
          returnsNormally,
        );
      });

      test('Error with custom exception types', () {
        expect(
          () => Log.e('Format error', error: FormatException('Invalid')),
          returnsNormally,
        );
        expect(
          () => Log.e('State error', error: StateError('Bad state')),
          returnsNormally,
        );
        expect(
          () => Log.e('Argument error', error: ArgumentError('Bad arg')),
          returnsNormally,
        );
      });

      test('Error from try-catch block', () {
        try {
          throw StateError('Test state error');
        } catch (e, stack) {
          expect(
            () => Log.e('Caught error', error: e, stackTrace: stack),
            returnsNormally,
          );
        }
      });
    });

    group('All log levels in sequence', () {
      test('All levels execute without error', () {
        expect(() {
          Log.t('Most verbose message');
          Log.d('Debugging information');
          Log.i('General information');
          Log.w('Something to note');
          Log.e('Something failed');
          Log.f('System failure');
        }, returnsNormally);
      });

      test('Mixed severity levels', () {
        expect(() {
          Log.d('Debug');
          Log.f('Fatal');
          Log.i('Info');
          Log.e('Error');
          Log.w('Warning');
          Log.t('Trace');
          Log.d('Debug again');
        }, returnsNormally);
      });
    });

    group('Special content', () {
      test('Special characters', () {
        expect(() {
          Log.i('Special chars: !@#\$%^&*()[]{}');
          Log.d('Quotes: "double" \'single\'');
          Log.w('Backslash: \\ and tab: \t');
        }, returnsNormally);
      });

      test('Unicode and emojis', () {
        expect(() {
          Log.d('Unicode: 🚀 🎉 ✨');
          Log.i('Japanese: こんにちは');
          Log.w('Arabic: مرحبا');
        }, returnsNormally);
      });

      test('Multiline messages', () {
        expect(() {
          Log.i('Line 1\nLine 2\nLine 3');
          Log.e('Error on line 1\nDetails on line 2');
        }, returnsNormally);
      });

      test('Empty messages', () {
        expect(() {
          Log.d('');
          Log.i('');
          Log.w('');
          Log.e('');
          Log.f('');
          Log.t('');
        }, returnsNormally);
      });

      test('Very long message', () {
        final longMessage = 'A' * 1000;
        expect(() => Log.i(longMessage), returnsNormally);
      });

      test('Complex objects', () {
        final map = {'key': 'value', 'number': 42};
        final list = [1, 2, 3, 'four'];

        expect(() {
          Log.d(map);
          Log.i(list);
          Log.w({'nested': map});
        }, returnsNormally);
      });
    });

    group('Performance', () {
      test('100 logs complete in reasonable time', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          Log.d('Performance test log #$i');
        }

        stopwatch.stop();
        // Should complete in less than 2 seconds for 100 logs
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('Mixed level logs performance', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 50; i++) {
          Log.t('Trace $i');
          Log.d('Debug $i');
          Log.i('Info $i');
          Log.w('Warning $i');
        }

        stopwatch.stop();
        // 200 logs should complete in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(4000));
      });

      test('Rapid successive logs', () {
        expect(() {
          for (int i = 0; i < 20; i++) {
            Log.d('Rapid log $i');
          }
        }, returnsNormally);
      });

      test('Error logs with details performance', () {
        final stopwatch = Stopwatch()..start();
        final error = Exception('Test');
        final stack = StackTrace.current;

        for (int i = 0; i < 20; i++) {
          Log.e('Error $i', error: error, stackTrace: stack);
        }

        stopwatch.stop();
        // Error logs with full details should still be reasonable
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });
    });

    group('Multiple errors in sequence', () {
      test('Multiple errors with different exceptions', () {
        expect(() {
          for (int i = 0; i < 5; i++) {
            Log.e('Error #$i', error: Exception('Error $i'));
          }
        }, returnsNormally);
      });

      test('Alternating error and fatal', () {
        expect(() {
          for (int i = 0; i < 5; i++) {
            if (i.isEven) {
              Log.e('Error #$i');
            } else {
              Log.f('Fatal #$i');
            }
          }
        }, returnsNormally);
      });
    });
  });
}
