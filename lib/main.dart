import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/onboarding_provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_intro_screen.dart';
import 'screens/application_form_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/kyc_screen.dart';
import 'screens/contract_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'navigation/main_navigation.dart';

void main() async {
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

  final prefs = await SharedPreferences.getInstance();
  final introShown = prefs.getBool('intro_shown') ?? false;

  runApp(SmartOneApp(showIntro: !introShown));
}

class SmartOneApp extends StatelessWidget {
  final bool showIntro;
  const SmartOneApp({super.key, required this.showIntro});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: MaterialApp(
        title: 'SmartOne Merchant Onboarding',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute:
            showIntro ? AppConstants.routeIntro : AppConstants.routeWelcome,
        routes: {
          AppConstants.routeIntro: (ctx) => const OnboardingIntroScreen(),
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
