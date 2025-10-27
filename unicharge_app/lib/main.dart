import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/auth_state.dart';
import 'services/appwrite_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/config_screen.dart';
import 'constants/appwrite_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Environment variables loaded from .env file");
  } catch (e) {
    print("⚠️ Could not load .env file: $e");
    print("Using system environment variables instead");
  }
  
  // Print configuration status
  AppwriteConfig.printConfig();
  
  runApp(const UniChargeApp());
}

class UniChargeApp extends StatelessWidget {
  const UniChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: MaterialApp(
        title: 'UniCharge',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AppWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Check for persisted session and verify with Appwrite
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    if (!mounted) return;
    
    final authState = context.read<AuthState>();
    
    // First load any persisted user data
    await authState.loadPersistedUser();
    
    if (!mounted) return;
    
    try {
      // Verify session with Appwrite
      final appwriteService = AppwriteService();
      final user = await appwriteService.getCurrentUser();
      
      if (user != null && mounted) {
        authState.setUser(user);
      } else if (mounted) {
        // No valid session, ensure user is cleared
        authState.setUser(null);
      }
    } catch (e) {
      print('Error checking session: $e');
      // No existing session, ensure user is cleared
      if (mounted) {
        authState.setUser(null);
      }
    } finally {
      if (mounted) {
        authState.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if Appwrite is configured
    if (!AppwriteConfig.isConfigured) {
      return const ConfigScreen();
    }

    return Consumer<AuthState>(
      builder: (context, authState, _) {
        if (authState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authState.isAuthenticated) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
