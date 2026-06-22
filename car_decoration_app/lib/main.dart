import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLoggedIn = await AuthService.isLoggedIn();
  String initialRoute = '/auth/login';

  if (isLoggedIn) {
    final role = await ApiClient.getRole();
    switch (role?.toLowerCase()) {
      case 'shop':
        initialRoute = '/shop/dashboard';
        break;
      case 'admin':
        initialRoute = '/admin/dashboard';
        break;
      default:
        initialRoute = '/customer/home';
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: CarDecorationApp(initialRoute: initialRoute),
    ),
  );
}
