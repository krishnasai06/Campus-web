import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

// Config
import 'config/theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await BackgroundService.init();
    await BackgroundService.scheduleTask();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => DataProvider()..initCache()),
      ],
      child: const SrmClientApp(),
    ),
  );
}

class SrmClientApp extends StatelessWidget {
  const SrmClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRM Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isCheckingAuth) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isLoggedIn ? const DashboardScreen() : const LoginScreen();
        },
      ),
    );
  }
}
