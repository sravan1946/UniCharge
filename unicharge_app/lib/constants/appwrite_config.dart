import '../config/env_config.dart';

class AppwriteConfig {
  // Use environment variables for configuration
  static String get endpoint => EnvConfig.appwriteEndpoint;
  static String get projectId => EnvConfig.appwriteProjectId;
  static String get databaseId => EnvConfig.appwriteDatabaseId;
  static String get apiKey => EnvConfig.appwriteApiKey;
  
  // Collection IDs
  static String get stationsCollectionId => EnvConfig.stationsCollectionId;
  static String get slotsCollectionId => EnvConfig.slotsCollectionId;
  static String get bookingsCollectionId => EnvConfig.bookingsCollectionId;
  static String get usersCollectionId => EnvConfig.usersCollectionId;
  
  // Realtime channels
  static String get stationsChannel => EnvConfig.stationsChannel;
  static String get slotsChannel => EnvConfig.slotsChannel;
  static String get bookingsChannel => EnvConfig.bookingsChannel;
  static String get usersChannel => EnvConfig.usersChannel;

  // Configuration validation
  static bool get isConfigured => EnvConfig.isConfigured;
  
  static void printConfig() => EnvConfig.printConfig();
}
