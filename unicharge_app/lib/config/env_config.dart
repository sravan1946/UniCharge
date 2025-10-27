import 'dart:io';

class EnvConfig {
  static String get appwriteEndpoint {
    return Platform.environment['APPWRITE_ENDPOINT'] ?? 
           'https://cloud.appwrite.io/v1';
  }

  static String get appwriteProjectId {
    return Platform.environment['APPWRITE_PROJECT_ID'] ?? 
           'YOUR_PROJECT_ID';
  }

  static String get appwriteDatabaseId {
    return Platform.environment['APPWRITE_DATABASE_ID'] ?? 
           'parkcharge_db';
  }

  static String get appwriteApiKey {
    return Platform.environment['APPWRITE_API_KEY'] ?? 
           'YOUR_API_KEY';
  }

  static String get stationsCollectionId {
    return Platform.environment['APPWRITE_STATIONS_COLLECTION_ID'] ?? 
           'stations';
  }

  static String get slotsCollectionId {
    return Platform.environment['APPWRITE_SLOTS_COLLECTION_ID'] ?? 
           'slots';
  }

  static String get bookingsCollectionId {
    return Platform.environment['APPWRITE_BOOKINGS_COLLECTION_ID'] ?? 
           'bookings';
  }

  static String get usersCollectionId {
    return Platform.environment['APPWRITE_USERS_COLLECTION_ID'] ?? 
           'users';
  }

  // Realtime channels
  static String get stationsChannel => 
      'databases.$appwriteDatabaseId.collections.$stationsCollectionId.documents';
  
  static String get slotsChannel => 
      'databases.$appwriteDatabaseId.collections.$slotsCollectionId.documents';
  
  static String get bookingsChannel => 
      'databases.$appwriteDatabaseId.collections.$bookingsCollectionId.documents';
  
  static String get usersChannel => 
      'databases.$appwriteDatabaseId.collections.$usersCollectionId.documents';

  // Validation
  static bool get isConfigured {
    return appwriteProjectId != 'YOUR_PROJECT_ID' && 
           appwriteApiKey != 'YOUR_API_KEY';
  }

  static void printConfig() {
    print('🔧 Appwrite Configuration:');
    print('   Endpoint: $appwriteEndpoint');
    print('   Project ID: $appwriteProjectId');
    print('   Database ID: $appwriteDatabaseId');
    print('   API Key: ${appwriteApiKey.substring(0, 8)}...');
    print('   Configured: $isConfigured');
  }
}
