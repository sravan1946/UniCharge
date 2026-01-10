# ParkCharge - Smart Parking & EV Charging Management Platform

![ParkCharge Logo](https://via.placeholder.com/200x100/00BCD4/FFFFFF?text=ParkCharge)

A comprehensive Flutter-based mobile and web application for managing smart parking and EV charging stations, built with Appwrite backend and real-time updates.

## 🚀 Features

### Mobile App (Flutter)
- **Dashboard**: Real-time charging status, battery level, and session management
- **Map View**: Interactive Google Maps with station markers and availability
- **Stations List**: Searchable list of nearby stations with filters
- **Profile**: User statistics, settings, and booking history
- **Real-time Updates**: Live slot status changes via Appwrite Realtime
- **Custom Animations**: Rive-powered charging and battery swap animations

### Web Dashboard (Flutter Web)
- **Simulation Controls**: Manual slot manipulation and auto-simulation
- **Analytics Panel**: Real-time occupancy statistics and revenue estimates
- **Station Management**: Visual grid of all slots with status controls
- **Battery Swap Simulation**: Trigger battery swap animations

### Backend (Appwrite)
- **Authentication**: User registration, login, and session management
- **Database**: Structured collections for stations, slots, bookings, and users
- **Realtime**: Live updates for slot status changes
- **Functions**: Server-side validation and business logic

### Simulation (Python)
- **Random Mode**: Random slot status changes for demo purposes
- **Realistic Mode**: Time-based patterns with peak hour simulation
- **Interactive Mode**: Manual control via CLI commands
- **Battery Swap**: Simulated battery replacement animations

## 🏗️ Architecture

```
┌────────────────────────────┐
│     Flutter App (Mobile)    │
│  - Dashboard, Map, List     │
│  - Real-time updates        │
└──────────────┬─────────────┘
               │
┌────────────────────────────┐
│   Flutter Web Dashboard    │
│  - Simulation controls     │
│  - Analytics panel         │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│     Appwrite Backend       │
│  - Auth, Database, Realtime│
│  - Functions, Storage      │
└──────────────┬─────────────┘
               │
┌────────────────────────────┐
│   Python Simulation        │
│  - Random/Realistic modes  │
│  - Battery swap simulation │
└────────────────────────────┘
```

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile and web development
- **Riverpod** - State management and dependency injection
- **Google Maps Flutter** - Interactive maps and location services
- **Rive** - Custom animations for charging and battery swap
- **GoRouter** - Navigation and routing

### Backend
- **Appwrite** - Backend-as-a-Service (self-hosted)
- **Appwrite Realtime** - Live updates and subscriptions
- **Appwrite Functions** - Server-side logic and validation

### Simulation
- **Python** - Simulation script with Appwrite SDK
- **Appwrite Python SDK** - Database operations and real-time updates

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Python 3.8 or higher
- Appwrite instance (self-hosted or cloud)
- Google Maps API key

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/parkcharge.git
cd parkcharge
```

### 2. Set Up Environment Variables

Copy the example environment file and configure your settings:

```bash
cp env.example .env
```

Edit `.env` with your configuration:

```env
# Appwrite Configuration
APPWRITE_ENDPOINT=https://appwrite.p1ng.me/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key

# Database Configuration
DATABASE_ID=parkcharge_db
STATIONS_COLLECTION_ID=stations
SLOTS_COLLECTION_ID=slots
BOOKINGS_COLLECTION_ID=bookings
USERS_COLLECTION_ID=users

# Google Maps API Key
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

### 3. Set Up Appwrite

1. Create a new project in your Appwrite console
2. Note down your Project ID and create an API key
3. Run the setup script to create collections and sample data:

```bash
cd scripts
pip install -r ../simulation/requirements.txt
python setup_appwrite_data.py
```

### 4. Install Flutter Dependencies

```bash
flutter pub get
```

### 5. Generate Code

```bash
flutter packages pub run build_runner build
```

### 6. Run the Application

#### Mobile App
```bash
flutter run
```

#### Web Dashboard
```bash
flutter run -d web-server --web-port 8080
```

### 7. Start Simulation

```bash
cd simulation
pip install -r requirements.txt
python simulate.py --mode random
```

## 📱 App Structure

```
lib/
├── core/                    # Core configuration and utilities
│   ├── appwrite_config.dart
│   ├── theme/
│   └── router/
├── models/                  # Data models
│   ├── station_model.dart
│   ├── slot_model.dart
│   ├── booking_model.dart
│   └── user_profile_model.dart
├── services/                # Appwrite service wrappers
│   ├── appwrite_auth_service.dart
│   ├── appwrite_database_service.dart
│   └── appwrite_realtime_service.dart
├── providers/               # Riverpod state management
│   ├── auth_provider.dart
│   ├── location_provider.dart
│   ├── stations_provider.dart
│   ├── booking_provider.dart
│   └── realtime_provider.dart
├── features/                # Feature modules
│   ├── main/               # Main app shell with bottom navigation
│   ├── dashboard/          # Dashboard with charging status
│   ├── map/                # Map view with station markers
│   ├── stations/           # Stations list with search/filter
│   ├── profile/            # User profile and settings
│   └── booking/            # Booking flow and history
└── shared/                 # Shared widgets and utilities
    └── widgets/
```

## 🎮 Simulation Modes

### Random Mode
```bash
python simulate.py --mode random
```
- Randomly changes slot status every 3-8 seconds
- Simulates vehicle arrivals and departures
- Triggers battery swap animations

### Realistic Mode
```bash
python simulate.py --mode realistic
```
- Time-based patterns with peak hours (8-10 AM, 6-8 PM)
- Higher arrival probability during peak hours
- More realistic vehicle flow simulation

### Interactive Mode
```bash
python simulate.py --mode interactive
```
- Manual control via CLI commands
- Commands: `arrive <station_id>`, `depart <station_id>`, `swap <station_id>`
- Real-time status display

## 🔧 Configuration

### Appwrite Collections

#### Stations Collection
- `name`: Station name
- `address`: Full address
- `latitude/longitude`: GPS coordinates
- `type`: parking/charging/hybrid
- `pricePerHour`: Pricing per hour
- `batterySwap`: Battery swap availability
- `totalSlots/availableSlots`: Slot counts

#### Slots Collection
- `stationId`: Reference to station
- `slotIndex`: Slot number within station
- `type`: parking_space/charging_pad
- `status`: available/occupied/reserved/maintenance
- `batteryStatus`: charged/charging/empty/swapped
- `lastUpdated`: Timestamp

#### Bookings Collection
- `userId/stationId/slotId`: References
- `status`: pending/active/completed/cancelled
- `startTime/endTime`: Session timing
- `pricePerHour/durationHours/totalPrice`: Pricing

### Google Maps Configuration

1. Enable Google Maps API in Google Cloud Console
2. Create API key with Maps SDK for Android/iOS
3. Add API key to your `.env` file
4. Configure domain restrictions for web

## 🎨 Customization

### Themes
Edit `lib/core/theme/app_theme.dart` to customize:
- Color schemes (light/dark mode)
- Typography and fonts
- Component styling

### Animations
Replace Rive animations in `assets/animations/`:
- `charging_animation.riv`: Battery charging animation
- `battery_swap_animation.riv`: Battery swap sequence

### Station Data
Modify `scripts/setup_appwrite_data.py` to:
- Add more sample stations
- Customize slot configurations
- Adjust pricing and amenities

## 🚀 Deployment

### Mobile App
- **Android**: Build APK/AAB for Play Store
- **iOS**: Build IPA for App Store
- **Web**: Deploy to Firebase Hosting, Vercel, or Netlify

### Backend
- **Appwrite Cloud**: Use managed Appwrite service
- **Self-hosted**: Deploy on VPS with Docker
- **Functions**: Deploy serverless functions

### Simulation
- **Local**: Run on development machine
- **Server**: Deploy on VPS for continuous simulation
- **Docker**: Containerize for easy deployment

## 🔒 Security

- API keys stored in environment variables
- Appwrite permissions configured per collection
- User authentication via Appwrite Accounts
- HTTPS enforced for all communications

## 📊 Analytics

The web dashboard provides real-time analytics:
- Occupancy percentage per station
- Active bookings count
- Revenue estimates
- Peak hour patterns

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Appwrite](https://appwrite.io/) for the backend platform
- [Flutter](https://flutter.dev/) for the UI framework
- [Rive](https://rive.app/) for animations
- [Google Maps](https://developers.google.com/maps) for mapping services

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Join our Discord community
- Email: support@parkcharge.app

---

**Made with ❤️ for the future of smart mobility**
