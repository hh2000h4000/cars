import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'services/app_logger.dart';

// ─── إعداد Sentry ──────────────────────────────────────────────
// احصل على DSN من: https://sentry.io → New Project → Flutter
// ثم ضعه هنا أو مرره عبر: flutter run --dart-define=SENTRY_DSN=https://...
const _sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue: 'https://e2ed34c1fa48770a44c874aea24e60f3@o4511620516675584.ingest.us.sentry.io/4511620525457409',
);

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.tracesSampleRate = kDebugMode ? 0.0 : 1.0;
      options.environment = kDebugMode ? 'development' : 'production';
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
      // في debug mode: يطبع في console بدون إرسال لـ Sentry
      options.debug = kDebugMode;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // التقاط كل Flutter framework errors
      FlutterError.onError = (details) {
        AppLogger.error(
          'Flutter Framework Error',
          error: details.exception,
          stackTrace: details.stack,
          context: {'widget': details.context?.toDescription()},
        );
      };

      // التقاط كل Dart async errors غير المعالجة
      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.error('Unhandled Dart Error', error: error, stackTrace: stack);
        return true;
      };

      final isLoggedIn = await AuthService.isLoggedIn();
      String initialRoute = '/auth/login';

      if (isLoggedIn) {
        final role = await ApiClient.getRole();
        switch (role) {
          case 'ShopOwner':
            initialRoute = '/shop/dashboard';
            break;
          case 'Admin':
            initialRoute = '/admin/dashboard';
            break;
          default:
            initialRoute = '/customer/home';
        }
      }

      runApp(
        ChangeNotifierProvider(
          create: (_) {
            final provider = AppProvider();
            if (isLoggedIn) provider.initFromApi();
            return provider;
          },
          child: CarDecorationApp(initialRoute: initialRoute),
        ),
      );
    },
  );
}
