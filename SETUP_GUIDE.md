# UniCharge Setup Guide

## Quick Start

### 1. Appwrite Setup (5 minutes)

1. **Create Appwrite Account**
   - Go to [appwrite.io](https://appwrite.io)
   - Sign up for a free account
   - Create a new project

2. **Set up Database**
   - Create database: `parkcharge_db`
   - Create collections with the schemas provided in README.md

3. **Get Credentials**
   - Copy your Project ID and Endpoint
   - Generate an API Key with database permissions

### 2. Flutter App Setup (3 minutes)

```bash
# Navigate to the app directory
cd unicharge_app

# Install dependencies
flutter pub get

# Update configuration
# Edit lib/constants/appwrite_config.dart with your Appwrite credentials

# Run the app
flutter run
```

### 3. Python Simulation Setup (2 minutes)

```bash
# Install Python dependencies
pip install -r requirements.txt

# Update configuration
# Edit simulate_update.py with your Appwrite credentials

# Initialize demo data
python init_demo_data.py

# Run simulation
python simulate_update.py
```

## Configuration Files

### Flutter App Configuration
Update `unicharge_app/lib/constants/appwrite_config.dart`:

```dart
static const String endpoint = 'https://YOUR_APPWRITE_ENDPOINT/v1';
static const String projectId = 'YOUR_PROJECT_ID';
static const String databaseId = 'parkcharge_db';
```

### Python Scripts Configuration
Update both `simulate_update.py` and `init_demo_data.py`:

```python
APPWRITE_ENDPOINT = 'https://YOUR_APPWRITE_ENDPOINT/v1'
PROJECT_ID = 'YOUR_PROJECT_ID'
API_KEY = 'YOUR_API_KEY'
```

## Demo Flow

1. **Start the simulation** to populate data and show real-time updates
2. **Launch the Flutter app** and sign up/sign in
3. **View stations** on the map or in list view
4. **Select a station** to see the seat-theatre style slot interface
5. **Book a slot** and watch real-time updates
6. **Access admin dashboard** to manage stations and view analytics

## Features Demonstrated

- ✅ **Interactive Maps** with Google Maps integration
- ✅ **Seat-Theatre UI** for slot selection
- ✅ **Real-time Updates** via Appwrite Realtime
- ✅ **Authentication** with user registration/login
- ✅ **Booking System** with reservation management
- ✅ **Admin Dashboard** for station management
- ✅ **Simulation Environment** for testing
- ✅ **Charging Animations** for EV stations
- ✅ **Settings Screen** with user preferences

## Troubleshooting

### Common Issues

1. **Appwrite Connection Error**
   - Verify your endpoint and project ID
   - Check API key permissions
   - Ensure collections are created

2. **Flutter Build Error**
   - Run `flutter clean && flutter pub get`
   - Check Flutter version compatibility

3. **Python Import Error**
   - Install requirements: `pip install -r requirements.txt`
   - Check Python version (3.7+)

4. **Location Permission**
   - Grant location permissions in device settings
   - Test on physical device for GPS

### Getting Help

- Check the main README.md for detailed documentation
- Review Appwrite documentation at [appwrite.io/docs](https://appwrite.io/docs)
- Flutter documentation at [docs.flutter.dev](https://docs.flutter.dev)

## Next Steps

1. **Customize** the app with your branding
2. **Add payment integration** for real transactions
3. **Implement IoT sensors** for real hardware
4. **Deploy** to app stores
5. **Scale** with Appwrite Cloud or self-hosted

## Project Structure

```
UniCharge/
├── unicharge_app/          # Flutter mobile app
│   ├── lib/
│   │   ├── bloc/          # State management
│   │   ├── models/        # Data models
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   ├── widgets/       # Reusable components
│   │   └── constants/     # Configuration
│   └── pubspec.yaml       # Dependencies
├── simulate_update.py      # Python simulation
├── init_demo_data.py      # Demo data setup
├── requirements.txt       # Python dependencies
└── README.md             # Full documentation
```

## Success! 🎉

You now have a complete smart parking and EV charging management platform ready for demonstration and further development.
