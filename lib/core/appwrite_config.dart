import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConfig {
  static late Client _client;
  static late Databases _databases;
  static late Realtime _realtime;
  static late Account _account;

  // Database and Collection IDs
  static const String databaseId = 'parkcharge_db';
  static const String stationsCollectionId = 'stations';
  static const String slotsCollectionId = 'slots';
  static const String bookingsCollectionId = 'bookings';
  static const String usersCollectionId = 'users';

  static void initialize() {
    _client = Client()
      ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://appwrite.p1ng.me/v1')
      ..setProject(dotenv.env['APPWRITE_PROJECT_ID'] ?? 'your-project-id')
      ..setSelfSigned(status: true); // Set to false in production

    _databases = Databases(_client);
    _realtime = Realtime(_client);
    _account = Account(_client);
  }

  static Client get client => _client;
  static Databases get databases => _databases;
  static Realtime get realtime => _realtime;
  static Account get account => _account;
}
