import 'package:logging/logging.dart';

import 'ansi_colors.dart';
import 'location_resolver.dart';
import 'object_formatter.dart';

/// Formats log records into Rust-style output.
///
/// Each log level has its own formatting style with appropriate colors.
abstract final class LogFormatter {
  /// Formats a log record with the given location info.
  static String format(LogRecord record, LocationInfo location) {
    return switch (record.level) {
      Level.SHOUT => _formatCritical(record, location),
      Level.SEVERE => _formatError(record, location),
      Level.WARNING => _formatWarning(record, location),
      Level.INFO => _formatInfo(record, location),
      Level.FINE => _formatDebug(record, location),
      _ => _formatTrace(record, location),
    };
  }

  static String _formatMessage(dynamic message) {
    return ObjectFormatter.format(message);
  }

  static String _formatCritical(LogRecord record, LocationInfo loc) {
    final msg = _formatMessage(record.message);
    // Cache multiline check - evaluated once
    final newlineIndex = msg.indexOf('\n');
    final isMultiline = newlineIndex != -1;

    final sb = StringBuffer()
      ..write(
        '${AnsiColors.bold}${AnsiColors.magenta}CRITICAL${AnsiColors.reset}',
      )
      ..write(
        ': ${AnsiColors.magentaDim}${isMultiline ? '' : msg}${AnsiColors.reset}',
      )
      ..writeln()
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.magenta}  --> ${AnsiColors.reset}${AnsiColors.gray}${loc.short}${AnsiColors.reset}',
      );

    if (loc.hasDifferentFullPath) {
      sb.writeln('${AnsiColors.gray}       ${loc.full}${AnsiColors.reset}');
    }

    sb.writeln(
      '${AnsiColors.bold}${AnsiColors.magenta}   |${AnsiColors.reset}',
    );

    if (isMultiline) {
      _appendMultilineContent(
        sb,
        msg,
        AnsiColors.magenta,
        AnsiColors.magentaDim,
      );
    }

    sb
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.magenta}   = ${AnsiColors.reset}${AnsiColors.bold}critical${AnsiColors.reset}: ${AnsiColors.magentaDim}System requires immediate attention${AnsiColors.reset}',
      )
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.magenta}   = ${AnsiColors.reset}${AnsiColors.bold}help${AnsiColors.reset}: ${AnsiColors.magentaDim}Check system logs and restart if necessary${AnsiColors.reset}',
      )
      ..write(
        '${AnsiColors.bold}${AnsiColors.magenta}   └─${AnsiColors.reset}',
      );

    return sb.toString();
  }

  static String _formatError(LogRecord record, LocationInfo loc) {
    final msg = _formatMessage(record.message);
    // Cache multiline check - evaluated once
    final isMultiline = msg.contains('\n');

    final sb = StringBuffer()
      ..write('${AnsiColors.bold}${AnsiColors.red}ERROR${AnsiColors.reset}')
      ..write(
        ': ${AnsiColors.redDim}${isMultiline ? '' : msg}${AnsiColors.reset}',
      )
      ..writeln()
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.red}  --> ${AnsiColors.reset}${AnsiColors.gray}${loc.short}${AnsiColors.reset}',
      );

    if (loc.hasDifferentFullPath) {
      sb.writeln('${AnsiColors.gray}       ${loc.full}${AnsiColors.reset}');
    }

    sb.writeln('${AnsiColors.bold}${AnsiColors.red}   |${AnsiColors.reset}');

    if (isMultiline) {
      _appendMultilineContent(sb, msg, AnsiColors.red, AnsiColors.redDim);
    }

    if (record.error != null) {
      sb.writeln(
        '${AnsiColors.bold}${AnsiColors.red}   = ${AnsiColors.reset}${AnsiColors.bold}error${AnsiColors.reset}: ${AnsiColors.redDim}${record.error}${AnsiColors.reset}',
      );
    }

    if (record.stackTrace != null) {
      final stackLines = record.stackTrace.toString().split('\n').take(4);
      var lineNum = 1;
      for (final line in stackLines) {
        final num = lineNum.toString().padLeft(2);
        sb.writeln(
          '${AnsiColors.bold}${AnsiColors.red}$num |${AnsiColors.reset} ${AnsiColors.gray}${line.trim()}${AnsiColors.reset}',
        );
        lineNum++;
      }
    }

    sb.write('${AnsiColors.bold}${AnsiColors.red}   └─${AnsiColors.reset}');

    return sb.toString();
  }

  static String _formatWarning(LogRecord record, LocationInfo loc) {
    final msg = _formatMessage(record.message);
    // Cache multiline check - evaluated once
    final isMultiline = msg.contains('\n');

    final sb = StringBuffer()
      ..write(
        '${AnsiColors.bold}${AnsiColors.yellow}WARNING${AnsiColors.reset}',
      )
      ..write(
        ': ${AnsiColors.yellowDim}${isMultiline ? '' : msg}${AnsiColors.reset}',
      )
      ..writeln()
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.yellow}  --> ${AnsiColors.reset}${AnsiColors.gray}${loc.short}${AnsiColors.reset}',
      );

    if (loc.hasDifferentFullPath) {
      sb.writeln('${AnsiColors.gray}       ${loc.full}${AnsiColors.reset}');
    }

    sb.writeln('${AnsiColors.bold}${AnsiColors.yellow}   |${AnsiColors.reset}');

    if (isMultiline) {
      _appendMultilineContent(sb, msg, AnsiColors.yellow, AnsiColors.yellowDim);
    }

    if (record.error != null) {
      sb.writeln(
        '${AnsiColors.bold}${AnsiColors.yellow}   = ${AnsiColors.reset}${AnsiColors.bold}note${AnsiColors.reset}: ${AnsiColors.yellowDim}${record.error}${AnsiColors.reset}',
      );
    }

    sb.write('${AnsiColors.bold}${AnsiColors.yellow}   └─${AnsiColors.reset}');

    return sb.toString();
  }

  static String _formatInfo(LogRecord record, LocationInfo loc) {
    final msg = _formatMessage(record.message);

    if (!msg.contains('\n')) {
      return '${AnsiColors.bold}${AnsiColors.green}INFO${AnsiColors.reset}: ${AnsiColors.greenDim}$msg${AnsiColors.reset} ${AnsiColors.gray}${loc.short}${AnsiColors.reset}';
    }

    final sb = StringBuffer()
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.green}INFO${AnsiColors.reset}: ${AnsiColors.gray}${loc.short}${AnsiColors.reset}',
      )
      ..writeln('${AnsiColors.bold}${AnsiColors.green}   |${AnsiColors.reset}');

    _appendMultilineContent(sb, msg, AnsiColors.green, AnsiColors.greenDim);
    sb.write('${AnsiColors.bold}${AnsiColors.green}   └─${AnsiColors.reset}');

    return sb.toString();
  }

  static String _formatDebug(LogRecord record, LocationInfo loc) {
    final msg = _formatMessage(record.message);

    if (!msg.contains('\n')) {
      return '${AnsiColors.bold}${AnsiColors.cyan}DEBUG${AnsiColors.reset}: ${AnsiColors.cyanDim}$msg${AnsiColors.reset} ${AnsiColors.gray}${loc.short}${AnsiColors.reset}';
    }

    final sb = StringBuffer()
      ..writeln(
        '${AnsiColors.bold}${AnsiColors.cyan}DEBUG${AnsiColors.reset}: ${AnsiColors.gray}${loc.short}${AnsiColors.reset}',
      )
      ..writeln('${AnsiColors.bold}${AnsiColors.cyan}   |${AnsiColors.reset}');

    _appendMultilineContent(sb, msg, AnsiColors.cyan, AnsiColors.cyanDim);
    sb.write('${AnsiColors.bold}${AnsiColors.cyan}   └─${AnsiColors.reset}');

    return sb.toString();
  }

  static String _formatTrace(LogRecord record, LocationInfo loc) {
    final msg = _formatMessage(record.message);

    if (!msg.contains('\n')) {
      return '${AnsiColors.dim}${AnsiColors.gray}TRACE${AnsiColors.reset}: ${AnsiColors.gray}$msg${AnsiColors.reset} ${AnsiColors.gray}${loc.short}${AnsiColors.reset}';
    }

    final sb = StringBuffer()
      ..writeln(
        '${AnsiColors.dim}${AnsiColors.gray}TRACE${AnsiColors.reset}: ${AnsiColors.gray}${loc.short}${AnsiColors.reset}',
      )
      ..writeln('${AnsiColors.gray}   |${AnsiColors.reset}')
      ..writeln('${AnsiColors.gray}   ┌─${AnsiColors.reset}');

    for (final line in msg.split('\n')) {
      sb.writeln('${AnsiColors.gray}$line${AnsiColors.reset}');
    }
    sb.write('${AnsiColors.gray}   └─${AnsiColors.reset}');

    return sb.toString();
  }

  static void _appendMultilineContent(
    StringBuffer sb,
    String content,
    String color,
    String colorDim,
  ) {
    sb.writeln('${AnsiColors.bold}$color   ┌─${AnsiColors.reset}');
    for (final line in content.split('\n')) {
      sb.writeln('$colorDim$line${AnsiColors.reset}');
    }
  }
}
