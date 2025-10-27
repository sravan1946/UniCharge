import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (if still needed)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, continuing without it');
  }
  
  // Initialize Firebase
  await FirebaseConfig.initialize();
  
  runApp(const ProviderScope(child: ParkChargeApp()));
}

class ParkChargeApp extends ConsumerWidget {
  const ParkChargeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ParkCharge',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
