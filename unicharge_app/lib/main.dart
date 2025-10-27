import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bloc/app_bloc.dart';
import 'services/appwrite_service.dart';
import 'services/location_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/settings_screen.dart';
import 'screens/config_screen.dart';
import 'constants/appwrite_config.dart';

void main() {
  // Print configuration status
  AppwriteConfig.printConfig();
  
  runApp(const UniChargeApp());
}

class UniChargeApp extends StatelessWidget {
  const UniChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc(
            appwriteService: AppwriteService(),
            locationService: LocationService(),
          ),
        ),
      ],
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

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if Appwrite is configured
    if (!AppwriteConfig.isConfigured) {
      return const ConfigScreen();
    }

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppLoaded && state.currentUser != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}