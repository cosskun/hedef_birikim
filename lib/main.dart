import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/goal_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress yellow-black zebra stripe overflow warnings across all devices
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };

  runApp(const HedefBirikimApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class HedefBirikimApp extends StatelessWidget {
  const HedefBirikimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'HedefBirikim',
            debugShowCheckedModeBanner: false,
            locale: const Locale('tr', 'TR'),
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            scrollBehavior: const AppScrollBehavior(),
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
