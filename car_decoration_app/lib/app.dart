import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_navigator.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/customer_register_screen.dart';
import 'screens/auth/shop_register_screen.dart';
import 'screens/auth/shop_pending_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/customer/shop_profile_screen.dart';
import 'screens/customer/new_request_screen.dart';
import 'screens/customer/shop_select_screen.dart';
import 'screens/customer/request_detail_screen.dart';
import 'screens/customer/quotation_detail_screen.dart';
import 'screens/customer/chat_screen.dart';
import 'screens/customer/review_screen.dart';
import 'screens/customer/complaint_screen.dart';
import 'screens/customer/add_vehicle_screen.dart';
import 'screens/customer/edit_request_screen.dart';
import 'screens/customer/location_picker_screen.dart';
import 'screens/shop/shop_shell.dart';
import 'screens/shop/shop_request_detail_screen.dart';
import 'screens/shop/send_quote_screen.dart';
import 'models/shop_request.dart';
import 'models/quotation.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/admin_pending_screen.dart';
import 'screens/admin/admin_disputes_screen.dart';

class CarDecorationApp extends StatelessWidget {
  final String initialRoute;
  const CarDecorationApp({super.key, this.initialRoute = '/auth/login'});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'تزيين',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    Widget page;
    switch (settings.name) {
      case '/onboarding':
        page = const OnboardingScreen();
        break;
      case '/auth/login':
        page = const LoginScreen();
        break;
      case '/auth/customer-register':
        page = const CustomerRegisterScreen();
        break;
      case '/auth/shop-register':
        page = const ShopRegisterScreen();
        break;
      case '/auth/shop-pending':
        page = const ShopPendingScreen();
        break;
      case '/customer/home':
        page = const CustomerShell();
        break;
      case '/customer/requests':
        page = const CustomerShell();
        break;
      case '/customer/shop':
        page = ShopProfileScreen(shopId: args as String? ?? 'sh1');
        break;
      case '/customer/requests/new':
        page = const NewRequestScreen();
        break;
      case '/customer/requests/shop-select':
        page = const ShopSelectScreen();
        break;
      case '/customer/request-detail':
        page = RequestDetailScreen(requestId: args as String? ?? '1042');
        break;
      case '/customer/quotation-detail':
        page = QuotationDetailScreen(quotation: args as Quotation);
        break;
      case '/customer/chat':
        page = ChatScreen(chatRoomId: args as String? ?? '');
        break;
      case '/customer/review':
        page = ReviewScreen(args: args as ReviewArgs);
        break;
      case '/customer/complaint':
        page = ComplaintScreen(requestId: args as String? ?? '1042');
        break;
      case '/customer/vehicles':
        page = const CustomerShell();
        break;
      case '/customer/vehicles/add':
        page = const AddVehicleScreen();
        break;
      case '/customer/requests/edit':
        page = const EditRequestScreen();
        break;
      case '/customer/location-picker':
        page = const LocationPickerScreen();
        break;
      case '/shop/dashboard':
        page = const ShopShell();
        break;
      case '/shop/request-detail':
        page = ShopRequestDetailScreen(request: args as ShopRequest);
        break;
      case '/shop/send-quote':
        page = SendQuoteScreen(request: args as ShopRequest);
        break;
      case '/admin/dashboard':
        page = const AdminShell();
        break;
      case '/admin/pending':
        page = const AdminPendingScreen();
        break;
      case '/admin/disputes':
        page = const AdminDisputesScreen();
        break;
      default:
        page = const OnboardingScreen();
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
