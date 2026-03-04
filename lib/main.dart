import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/onboarding_provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'screens/application_form_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/kyc_screen.dart';
import 'screens/contract_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'navigation/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SmartOneApp());
}

class SmartOneApp extends StatelessWidget {
  const SmartOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: MaterialApp(
        title: 'SmartOne Merchant Onboarding',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppConstants.routeWelcome,
        routes: {
          AppConstants.routeWelcome: (ctx) => const WelcomeScreen(),
          AppConstants.routeMain: (ctx) => const MainNavigation(),
          AppConstants.routeApplication: (ctx) => const ApplicationFormScreen(),
          AppConstants.routeDocuments: (ctx) => const DocumentsScreen(),
          AppConstants.routeKyc: (ctx) => const KycScreen(),
          AppConstants.routeContract: (ctx) => const ContractScreen(),
          AppConstants.routeAdmin: (ctx) => const AdminPanelScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
