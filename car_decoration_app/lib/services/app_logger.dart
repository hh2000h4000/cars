import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized logger — all errors flow through here.
/// In debug mode: prints to console.
/// In production: sends to Sentry dashboard.
class AppLogger {
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    debugPrint('[ERROR] $message${error != null ? '\n  → $error' : ''}');
    if (stackTrace != null) debugPrint('  $stackTrace');

    Sentry.captureException(
      error ?? Exception(message),
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('source', message);
        context?.forEach((k, v) => scope.setExtra(k, v));
      },
    );
  }

  static void warning(String message, {Map<String, dynamic>? context}) {
    debugPrint('[WARNING] $message');
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      level: SentryLevel.warning,
      data: context,
    ));
  }

  static void info(String message) {
    debugPrint('[INFO] $message');
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      level: SentryLevel.info,
    ));
  }

  static void apiCall(String method, String path, int? statusCode) {
    final level = (statusCode != null && statusCode >= 400)
        ? SentryLevel.warning
        : SentryLevel.info;
    debugPrint('[API] $method $path → ${statusCode ?? "..."}');
    Sentry.addBreadcrumb(Breadcrumb(
      message: '$method $path',
      category: 'http',
      level: level,
      data: {'status_code': statusCode},
    ));
  }
}
