# UniCharge - Smart Parking & EV Charging Management Platform

A comprehensive Flutter-based mobile application with Appwrite backend for managing smart parking and EV charging stations.

## Features

- 🗺️ **Interactive Maps**: Google Maps integration showing nearby stations
- 🎫 **Seat-Theatre UI**: Visual slot selection interface
- ⚡ **Real-time Updates**: Live slot availability updates via Appwrite Realtime
- 🔋 **EV Charging**: Support for charging pads and battery swap stations
- 📱 **Cross-platform**: Flutter app for iOS and Android
- 🔐 **Authentication**: User registration and login
- 📊 **Admin Dashboard**: Station management and analytics
- 🎮 **Simulation**: Python script for testing and demos

## Tech Stack

- **Frontend**: Flutter with BLoC state management
- **Backend**: Appwrite (Database, Authentication, Realtime, Functions)
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Simulation**: Python with Appwrite SDK

## Project Structure

```
unicharge_app/
├── lib/
│   ├── bloc/           # State management
│   ├── models/         # Data models
│   ├── screens/        # UI screens
│   ├── services/       # API services
│   ├── widgets/        # Reusable widgets
│   └── constants/      # App configuration
├── simulate_update.py  # Python simulation script
└── requirements.txt    # Python dependencies
```

## Setup Instructions

### 1. Appwrite Setup

1. Create an Appwrite project at [appwrite.io](https://appwrite.io)
2. Set up the following collections in your database:

#### Database: `parkcharge_db`

**Collection: `stations`**
```json
{
  "name": "string",
  "latitude": "double",
  "longitude": "double", 
  "type": "string",
  "price_per_hour": "double",
  "battery_swap": "boolean",
  "address": "string",
  "total_slots": "integer",
  "available_slots": "integer",
  "rating": "double",
  "amenities": "string[]"
}
```

**Collection: `slots`**
```json
{
  "station_id": "string",
  "slot_index": "integer",
  "type": "string",
  "status": "string",
  "battery_status": "string",
  "last_updated": "datetime",
  "reserved_by": "string",
  "occupied_by": "string"
}
```

**Collection: `bookings`**
```json
{
  "user_id": "string",
  "station_id": "string",
  "slot_id": "string",
  "status": "string",
  "start_time": "datetime",
  "end_time": "datetime",
  "price": "double",
  "notes": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

**Collection: `users`**
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "profile_image": "string",
  "loyalty_points": "integer",
  "created_at": "datetime",
  "last_login": "datetime",
  "preferences": "string"
}
```

### 2. Flutter App Setup

1. **Install Flutter**: Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install)

2. **Clone and setup**:
   ```bash
   cd unicharge_app
   flutter pub get
   ```

3. **Configure Appwrite**:
   - Update `lib/constants/appwrite_config.dart` with your Appwrite credentials:
   ```dart
   static const String endpoint = 'https://YOUR_APPWRITE_ENDPOINT/v1';
   static const String projectId = 'YOUR_PROJECT_ID';
   static const String databaseId = 'parkcharge_db';
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### 3. Python Simulation Setup

1. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure simulation**:
   - Update `simulate_update.py` with your Appwrite credentials:
   ```python
   APPWRITE_ENDPOINT = 'https://YOUR_APPWRITE_ENDPOINT/v1'
   PROJECT_ID = 'YOUR_PROJECT_ID'
   API_KEY = 'YOUR_API_KEY'
   ```

3. **Run simulation**:
   ```bash
   python simulate_update.py
   ```

## Usage

### Flutter App

1. **Launch the app** and sign up/sign in
2. **Grant location permissions** when prompted
3. **View nearby stations** on the map or list
4. **Select a station** to see slot details
5. **Choose an available slot** and book it
6. **Monitor real-time updates** as slots change status

### Simulation Script

The Python script provides several options:

1. **Initialize sample data** - Creates demo stations and slots
2. **Start slot simulation** - Randomly changes slot statuses
3. **Simulate booking flow** - Creates and manages bookings
4. **Exit** - Stop the simulation

## Features in Detail

### Slot Status System

- **Available** (White/Green): Ready for booking
- **Occupied** (Red): Currently in use
- **Reserved** (Blue): Booked by a user
- **Maintenance** (Orange): Temporarily unavailable

### Battery Status (Charging Pads)

- **Charged**: Battery is fully charged
- **Charging**: Currently charging
- **Swapped**: Battery was recently swapped
- **Empty**: Battery needs charging

### Real-time Updates

The app uses Appwrite Realtime to receive live updates when:
- Slot status changes
- New bookings are created
- Station availability updates

## Development

### Adding New Features

1. **Models**: Add new data models in `lib/models/`
2. **Services**: Extend API services in `lib/services/`
3. **Screens**: Create new UI screens in `lib/screens/`
4. **Widgets**: Build reusable components in `lib/widgets/`
5. **State**: Manage app state in `lib/bloc/`

### Testing

1. **Run simulation** to populate test data
2. **Test booking flow** with multiple users
3. **Verify real-time updates** across devices
4. **Test location services** and map functionality

## Deployment

### Flutter App

- **Android**: Build APK or use Google Play Store
- **iOS**: Build for App Store or TestFlight
- **Web**: Deploy to Firebase Hosting or similar

### Appwrite

- **Cloud**: Use Appwrite Cloud for production
- **Self-hosted**: Deploy on your own infrastructure

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the Appwrite documentation
- Review Flutter documentation

## Roadmap

- [ ] Payment integration
- [ ] Push notifications
- [ ] Offline mode
- [ ] IoT sensor integration
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Admin web dashboard
