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

    // ══════════════════════════════════════════════════════════════════════════
    // TAG LOGGING TESTS
    // ══════════════════════════════════════════════════════════════════════════

    group('Tag logging', () {
      setUp(() {
        // Clear all tags before each test
        Log.clearAll();
      });

      group('Basic tag operations', () {
        test('tag() should work with string message', () {
          expect(() => Log.tag('test', 'Hello world'), returnsNormally);
        });

        test('tag() should work with Map message', () {
          expect(
            () => Log.tag('test', {'key': 'value', 'count': 42}),
            returnsNormally,
          );
        });

        test('tag() should work with different levels', () {
          expect(() {
            Log.tag('test', 'Trace', level: Level.FINEST);
            Log.tag('test', 'Debug', level: Level.FINE);
            Log.tag('test', 'Info', level: Level.INFO);
            Log.tag('test', 'Warning', level: Level.WARNING);
            Log.tag('test', 'Error', level: Level.SEVERE);
            Log.tag('test', 'Critical', level: Level.SHOUT);
          }, returnsNormally);
        });

        test('tag() should work with error and stackTrace', () {
          final error = Exception('Test error');
          final stack = StackTrace.current;
          expect(
            () => Log.tag(
              'test',
              'Error occurred',
              level: Level.SEVERE,
              error: error,
              stackTrace: stack,
            ),
            returnsNormally,
          );
        });

        test('hasTag() returns true after tagging', () {
          Log.tag('myTag', 'message');
          expect(Log.hasTag('myTag'), isTrue);
        });

        test('hasTag() returns false for non-existent tag', () {
          expect(Log.hasTag('nonExistent'), isFalse);
        });

        test('entryCount() returns correct count', () {
          Log.tag('counter', 'one');
          Log.tag('counter', 'two');
          Log.tag('counter', 'three');
          expect(Log.entryCount('counter'), equals(3));
        });

        test('entryCount() returns 0 for non-existent tag', () {
          expect(Log.entryCount('nonExistent'), equals(0));
        });
      });

      group('Error detection', () {
        test('hasErrors() returns false when no errors', () {
          Log.tag('clean', 'Debug message', level: Level.FINE);
          Log.tag('clean', 'Info message', level: Level.INFO);
          expect(Log.hasErrors('clean'), isFalse);
        });

        test('hasErrors() returns true with WARNING', () {
          Log.tag('warn', 'Warning!', level: Level.WARNING);
          expect(Log.hasErrors('warn'), isTrue);
        });

        test('hasErrors() returns true with SEVERE (ERROR)', () {
          Log.tag('err', 'Error!', level: Level.SEVERE);
          expect(Log.hasErrors('err'), isTrue);
        });

        test('hasErrors() returns true with SHOUT (CRITICAL)', () {
          Log.tag('crit', 'Critical!', level: Level.SHOUT);
          expect(Log.hasErrors('crit'), isTrue);
        });

        test('hasErrors() returns false for non-existent tag', () {
          expect(Log.hasErrors('nonExistent'), isFalse);
        });
      });

      group('Clear operations', () {
        test('clear() removes specific tag', () {
          Log.tag('toRemove', 'message');
          Log.tag('toKeep', 'message');
          Log.clear('toRemove');
          expect(Log.hasTag('toRemove'), isFalse);
          expect(Log.hasTag('toKeep'), isTrue);
        });

        test('clearAll() removes all tags', () {
          Log.tag('tag1', 'message');
          Log.tag('tag2', 'message');
          Log.tag('tag3', 'message');
          Log.clearAll();
          expect(Log.hasTag('tag1'), isFalse);
          expect(Log.hasTag('tag2'), isFalse);
          expect(Log.hasTag('tag3'), isFalse);
        });

        test('clear() on non-existent tag does not throw', () {
          expect(() => Log.clear('nonExistent'), returnsNormally);
        });
      });

      group('Export operations', () {
        test('export() prints to console and clears tag', () {
          Log.tag('export', 'Message 1');
          Log.tag('export', 'Message 2');
          expect(Log.hasTag('export'), isTrue);
          expect(() => Log.export('export'), returnsNormally);
          expect(Log.hasTag('export'), isFalse);
        });

        test('export() on non-existent tag does not throw', () {
          expect(() => Log.export('nonExistent'), returnsNormally);
        });

        test('export(onlyOnError: true) skips when no errors', () {
          Log.tag('noErrors', 'Info', level: Level.INFO);
          Log.tag('noErrors', 'Debug', level: Level.FINE);
          // Should clear without printing separator
          expect(() => Log.export('noErrors', onlyOnError: true), returnsNormally);
          expect(Log.hasTag('noErrors'), isFalse);
        });

        test('export(onlyOnError: true) exports when has errors', () {
          Log.tag('hasError', 'Info', level: Level.INFO);
          Log.tag('hasError', 'Error!', level: Level.SEVERE);
          expect(() => Log.export('hasError', onlyOnError: true), returnsNormally);
          expect(Log.hasTag('hasError'), isFalse);
        });

        test('exportAll() exports all tags', () {
          Log.tag('all1', 'message');
          Log.tag('all2', 'message');
          expect(() => Log.exportAll(), returnsNormally);
          expect(Log.hasTag('all1'), isFalse);
          expect(Log.hasTag('all2'), isFalse);
        });

        test('exportAll(onlyOnError: true) only exports tags with errors', () {
          Log.tag('withError', 'Error!', level: Level.SEVERE);
          Log.tag('withoutError', 'Info', level: Level.INFO);
          expect(() => Log.exportAll(onlyOnError: true), returnsNormally);
          // Both should be cleared
          expect(Log.hasTag('withError'), isFalse);
          expect(Log.hasTag('withoutError'), isFalse);
        });
      });

      group('Multiple tags', () {
        test('Multiple tags can coexist', () {
          Log.tag('auth', 'Login started');
          Log.tag('network', 'Request sent');
          Log.tag('auth', 'Login completed');
          Log.tag('network', 'Response received');

          expect(Log.entryCount('auth'), equals(2));
          expect(Log.entryCount('network'), equals(2));
        });

        test('Tags are independent', () {
          Log.tag('tagA', 'Error!', level: Level.SEVERE);
          Log.tag('tagB', 'Info', level: Level.INFO);

          expect(Log.hasErrors('tagA'), isTrue);
          expect(Log.hasErrors('tagB'), isFalse);
        });
      });

      group('Real-world scenarios', () {
        test('Authentication flow simulation', () {
          expect(() {
            // UI Layer
            Log.tag('auth', 'User tapped login');
            Log.tag('auth', {'screen': 'LoginPage'});

            // Service Layer
            Log.tag('auth', 'Validating credentials', level: Level.INFO);

            // Repository Layer
            Log.tag('auth', 'API call: POST /auth/login', level: Level.FINE);

            // Error scenario
            Log.tag(
              'auth',
              'Auth failed: Invalid password',
              level: Level.SEVERE,
              error: Exception('401 Unauthorized'),
            );

            // Export for analysis
            Log.export('auth');
          }, returnsNormally);
        });

        test('Conditional export on success', () {
          // Successful flow
          Log.tag('checkout', 'Cart validated', level: Level.INFO);
          Log.tag('checkout', 'Payment processed', level: Level.INFO);
          Log.tag('checkout', 'Order created', level: Level.INFO);

          // No errors, so with onlyOnError it should just clear
          Log.export('checkout', onlyOnError: true);
          expect(Log.hasTag('checkout'), isFalse);
        });

        test('Conditional export on failure', () {
          // Failed flow
          Log.tag('payment', 'Processing payment', level: Level.INFO);
          Log.tag(
            'payment',
            'Payment declined',
            level: Level.SEVERE,
            error: Exception('Card declined'),
          );

          // Has error, so should export
          expect(Log.hasErrors('payment'), isTrue);
          Log.export('payment', onlyOnError: true);
          expect(Log.hasTag('payment'), isFalse);
        });
      });

      group('Performance', () {
        test('100 tags in single tag complete quickly', () {
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < 100; i++) {
            Log.tag('perf', 'Message #$i');
          }

          stopwatch.stop();
          expect(stopwatch.elapsedMilliseconds, lessThan(2000));
          expect(Log.entryCount('perf'), equals(100));

          Log.clear('perf');
        });

        test('Many tags with few entries each', () {
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < 50; i++) {
            Log.tag('tag_$i', 'Entry 1');
            Log.tag('tag_$i', 'Entry 2');
          }

          stopwatch.stop();
          expect(stopwatch.elapsedMilliseconds, lessThan(2000));

          Log.clearAll();
        });
      });
    });

    // ══════════════════════════════════════════════════════════════════════════
    // PERFORMANCE BENCHMARKS
    // ══════════════════════════════════════════════════════════════════════════

    group('Performance Benchmarks', () {
      setUp(() {
        Log.clearAll();
      });

      tearDown(() {
        Log.clearAll();
      });

      group('Tag creation performance', () {
        test('1000 simple tags - measure time per operation', () {
          const iterations = 1000;
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < iterations; i++) {
            Log.tag('bench', 'Simple message $i');
          }

          stopwatch.stop();
          final totalMs = stopwatch.elapsedMilliseconds;
          final avgMicroseconds =
              (stopwatch.elapsedMicroseconds / iterations).toStringAsFixed(2);

          // ignore: avoid_print
          print('\n📊 1000 simple tags:');
          // ignore: avoid_print
          print('   Total: ${totalMs}ms');
          // ignore: avoid_print
          print('   Avg per tag: ${avgMicroseconds}μs');

          expect(totalMs, lessThan(5000)); // Should complete in < 5s
          expect(Log.entryCount('bench'), equals(iterations));
        });

        test('1000 tags with Map data - measure overhead', () {
          const iterations = 1000;
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < iterations; i++) {
            Log.tag('bench_map', {
              'index': i,
              'data': 'value_$i',
              'nested': {'key': 'value'},
            });
          }

          stopwatch.stop();
          final totalMs = stopwatch.elapsedMilliseconds;
          final avgMicroseconds =
              (stopwatch.elapsedMicroseconds / iterations).toStringAsFixed(2);

          // ignore: avoid_print
          print('\n📊 1000 Map tags:');
          // ignore: avoid_print
          print('   Total: ${totalMs}ms');
          // ignore: avoid_print
          print('   Avg per tag: ${avgMicroseconds}μs');

          expect(totalMs, lessThan(5000));
        });

        test('500 error tags with auto stack trace - measure overhead', () {
          const iterations = 500;
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < iterations; i++) {
            Log.tag(
              'bench_error',
              'Error message $i',
              level: Level.SEVERE,
            );
          }

          stopwatch.stop();
          final totalMs = stopwatch.elapsedMilliseconds;
          final avgMicroseconds =
              (stopwatch.elapsedMicroseconds / iterations).toStringAsFixed(2);

          // ignore: avoid_print
          print('\n📊 500 error tags (auto stack trace):');
          // ignore: avoid_print
          print('   Total: ${totalMs}ms');
          // ignore: avoid_print
          print('   Avg per tag: ${avgMicroseconds}μs');

          expect(totalMs, lessThan(10000)); // Stack traces are slower
        });

        test('Compare DEBUG vs ERROR level overhead', () {
          const iterations = 500;

          // DEBUG level (no stack trace)
          final debugWatch = Stopwatch()..start();
          for (int i = 0; i < iterations; i++) {
            Log.tag('debug_bench', 'Debug $i', level: Level.FINE);
          }
          debugWatch.stop();
          Log.clear('debug_bench');

          // ERROR level (auto stack trace)
          final errorWatch = Stopwatch()..start();
          for (int i = 0; i < iterations; i++) {
            Log.tag('error_bench', 'Error $i', level: Level.SEVERE);
          }
          errorWatch.stop();
          Log.clear('error_bench');

          final debugAvg =
              (debugWatch.elapsedMicroseconds / iterations).toStringAsFixed(2);
          final errorAvg =
              (errorWatch.elapsedMicroseconds / iterations).toStringAsFixed(2);
          final overhead =
              (errorWatch.elapsedMicroseconds / debugWatch.elapsedMicroseconds)
                  .toStringAsFixed(2);

          // ignore: avoid_print
          print('\n📊 DEBUG vs ERROR comparison ($iterations iterations):');
          // ignore: avoid_print
          print('   DEBUG avg: ${debugAvg}μs');
          // ignore: avoid_print
          print('   ERROR avg: ${errorAvg}μs');
          // ignore: avoid_print
          print('   ERROR overhead: ${overhead}x');

          expect(debugWatch.elapsedMilliseconds, lessThan(5000));
          expect(errorWatch.elapsedMilliseconds, lessThan(10000));
        });
      });

      group('Export performance', () {
        test('Export 100 entries - measure formatting time', () {
          // Setup
          for (int i = 0; i < 100; i++) {
            Log.tag('export_bench', 'Message $i');
          }

          final stopwatch = Stopwatch()..start();
          Log.export('export_bench');
          stopwatch.stop();

          // ignore: avoid_print
          print('\n📊 Export 100 entries:');
          // ignore: avoid_print
          print('   Total: ${stopwatch.elapsedMilliseconds}ms');
        });

        test('Export 500 entries with mixed levels', () {
          // Setup mixed entries
          for (int i = 0; i < 500; i++) {
            final level = switch (i % 5) {
              0 => Level.FINEST,
              1 => Level.FINE,
              2 => Level.INFO,
              3 => Level.WARNING,
              _ => Level.SEVERE,
            };
            Log.tag('export_mixed', 'Message $i', level: level);
          }

          final stopwatch = Stopwatch()..start();
          Log.export('export_mixed');
          stopwatch.stop();

          // ignore: avoid_print
          print('\n📊 Export 500 mixed entries:');
          // ignore: avoid_print
          print('   Total: ${stopwatch.elapsedMilliseconds}ms');

          expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        });

        test('ExportAll with 10 tags x 50 entries each', () {
          // Setup 10 tags with 50 entries each
          for (int t = 0; t < 10; t++) {
            for (int e = 0; e < 50; e++) {
              Log.tag('tag_$t', 'Entry $e');
            }
          }

          final stopwatch = Stopwatch()..start();
          Log.exportAll();
          stopwatch.stop();

          // ignore: avoid_print
          print('\n📊 ExportAll (10 tags x 50 entries):');
          // ignore: avoid_print
          print('   Total: ${stopwatch.elapsedMilliseconds}ms');

          expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        });
      });

      group('Memory efficiency', () {
        test('Tag storage grows linearly', () {
          final counts = <int>[];
          final times = <int>[];

          for (final size in [100, 200, 500, 1000]) {
            Log.clearAll();
            final stopwatch = Stopwatch()..start();

            for (int i = 0; i < size; i++) {
              Log.tag('memory_test', 'Message $i with some content');
            }

            stopwatch.stop();
            counts.add(size);
            times.add(stopwatch.elapsedMicroseconds);
          }

          // ignore: avoid_print
          print('\n📊 Linear scaling test:');
          for (int i = 0; i < counts.length; i++) {
            final avgPerOp = (times[i] / counts[i]).toStringAsFixed(2);
            // ignore: avoid_print
            print('   ${counts[i]} entries: ${times[i]}μs (${avgPerOp}μs/op)');
          }

          // Verify roughly linear scaling (4x entries should be < 6x time)
          final ratio = times.last / times.first;
          final countRatio = counts.last / counts.first;
          // ignore: avoid_print
          print('   Scaling factor: ${(ratio / countRatio).toStringAsFixed(2)}x');

          expect(ratio, lessThan(countRatio * 2)); // Allow 2x overhead max
        });

        test('Clear releases entries immediately', () {
          // Create many entries
          for (int i = 0; i < 1000; i++) {
            Log.tag('clear_test', 'Message $i');
          }
          expect(Log.entryCount('clear_test'), equals(1000));

          // Clear should be instant
          final stopwatch = Stopwatch()..start();
          Log.clear('clear_test');
          stopwatch.stop();

          // ignore: avoid_print
          print('\n📊 Clear 1000 entries:');
          // ignore: avoid_print
          print('   Time: ${stopwatch.elapsedMicroseconds}μs');

          expect(Log.entryCount('clear_test'), equals(0));
          expect(stopwatch.elapsedMicroseconds, lessThan(1000)); // < 1ms
        });

        test('ClearAll with multiple tags', () {
          // Create 20 tags with 100 entries each
          for (int t = 0; t < 20; t++) {
            for (int e = 0; e < 100; e++) {
              Log.tag('multi_$t', 'Entry $e');
            }
          }

          final stopwatch = Stopwatch()..start();
          Log.clearAll();
          stopwatch.stop();

          // ignore: avoid_print
          print('\n📊 ClearAll (20 tags x 100 entries):');
          // ignore: avoid_print
          print('   Time: ${stopwatch.elapsedMicroseconds}μs');

          expect(stopwatch.elapsedMicroseconds, lessThan(5000)); // < 5ms
        });
      });

      group('Concurrent tag operations', () {
        test('Multiple tags simultaneously', () {
          const tagsCount = 10;
          const entriesPerTag = 100;
          final stopwatch = Stopwatch()..start();

          // Simulate interleaved logging from multiple "sources"
          for (int i = 0; i < entriesPerTag; i++) {
            for (int t = 0; t < tagsCount; t++) {
              Log.tag('concurrent_$t', 'Entry $i from tag $t');
            }
          }

          stopwatch.stop();
          final totalEntries = tagsCount * entriesPerTag;
          final avgMicroseconds =
              (stopwatch.elapsedMicroseconds / totalEntries).toStringAsFixed(2);

          // ignore: avoid_print
          print('\n📊 Concurrent tags ($tagsCount tags x $entriesPerTag entries):');
          // ignore: avoid_print
          print('   Total: ${stopwatch.elapsedMilliseconds}ms');
          // ignore: avoid_print
          print('   Avg per entry: ${avgMicroseconds}μs');

          // Verify all entries recorded correctly
          for (int t = 0; t < tagsCount; t++) {
            expect(Log.entryCount('concurrent_$t'), equals(entriesPerTag));
          }

          expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        });
      });

      group('Throughput benchmarks', () {
        test('Maximum throughput - simple messages', () {
          const duration = Duration(seconds: 1);
          var count = 0;
          final stopwatch = Stopwatch()..start();

          while (stopwatch.elapsed < duration) {
            Log.tag('throughput', 'msg');
            count++;
          }

          stopwatch.stop();
          final opsPerSecond =
              (count / stopwatch.elapsedMilliseconds * 1000).round();

          // ignore: avoid_print
          print('\n📊 Throughput (1 second):');
          // ignore: avoid_print
          print('   Operations: $count');
          // ignore: avoid_print
          print('   Ops/second: $opsPerSecond');

          Log.clear('throughput');

          // Should handle at least 1000 ops/second
          expect(opsPerSecond, greaterThan(1000));
        });
      });

      group('Summary report', () {
        test('Generate performance summary', () {
          // ignore: avoid_print
          print('\n');
          // ignore: avoid_print
          print('╔══════════════════════════════════════════════════════════════╗');
          // ignore: avoid_print
          print('║              TAG LOGGING PERFORMANCE SUMMARY                 ║');
          // ignore: avoid_print
          print('╠══════════════════════════════════════════════════════════════╣');

          // Simple tag benchmark
          var sw = Stopwatch()..start();
          for (int i = 0; i < 1000; i++) {
            Log.tag('summary', 'msg $i');
          }
          sw.stop();
          final simpleAvg = (sw.elapsedMicroseconds / 1000).toStringAsFixed(1);
          Log.clear('summary');

          // Map tag benchmark
          sw = Stopwatch()..start();
          for (int i = 0; i < 1000; i++) {
            Log.tag('summary', {'i': i, 'data': 'value'});
          }
          sw.stop();
          final mapAvg = (sw.elapsedMicroseconds / 1000).toStringAsFixed(1);
          Log.clear('summary');

          // Error tag benchmark
          sw = Stopwatch()..start();
          for (int i = 0; i < 500; i++) {
            Log.tag('summary', 'error', level: Level.SEVERE);
          }
          sw.stop();
          final errorAvg = (sw.elapsedMicroseconds / 500).toStringAsFixed(1);

          // Export benchmark
          sw = Stopwatch()..start();
          Log.export('summary');
          sw.stop();
          final exportMs = sw.elapsedMilliseconds;

          // ignore: avoid_print
          print('║  Simple tag (string):      $simpleAvg μs/op              ║');
          // ignore: avoid_print
          print('║  Map tag (JSON):           $mapAvg μs/op              ║');
          // ignore: avoid_print
          print('║  Error tag (+ stack):      $errorAvg μs/op              ║');
          // ignore: avoid_print
          print('║  Export 500 entries:       ${exportMs}ms                       ║');
          // ignore: avoid_print
          print('╚══════════════════════════════════════════════════════════════╝');
          // ignore: avoid_print
          print('\n');
        });
      });
    });
  });
}
