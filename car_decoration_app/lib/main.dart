import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Directionality(
      textDirection: TextDirection.rtl,
      child: ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const CarDecorationApp(),
      ),
    ),
  );
}
