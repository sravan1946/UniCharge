# Charging Stations Fetch from Appwrite - Implementation Summary

## Overview

The app now fetches charging stations from your Appwrite database. The implementation handles data parsing, distance calculations, and proper error handling.

## Implementation Details

### 1. **Database Service Updated** (`lib/services/appwrite_database_service.dart`)

#### Key Features:
- ✅ **Fetch all stations** from Appwrite `stations` collection
- ✅ **Distance calculation** using Haversine formula
- ✅ **Data type conversion** from Appwrite to Dart types
- ✅ **Amenities parsing** from comma-separated string to List
- ✅ **Enum conversion** for station types
- ✅ **Error handling** with user-friendly messages

#### Data Parsing:
The service now handles various data types from Appwrite:

```dart
// Parse amenities from string to list
List<String> amenitiesList = [];
if (data['amenities'] != null) {
  if (data['amenities'] is String) {
    amenitiesList = (data['amenities'] as String).split(',').map((s) => s.trim()).toList();
  } else if (data['amenities'] is List) {
    amenitiesList = List<String>.from(data['amenities']);
  }
}

// Handle type conversions (String to numeric)
'latitude': (data['latitude'] is String) ? double.parse(data['latitude']) : data['latitude'],
'totalSlots': (data['totalSlots'] is String) ? int.parse(data['totalSlots']) : data['totalSlots'],
```

#### Station Type Parsing:
```dart
String _parseStationType(dynamic type) {
  if (type is String) {
    switch (type.toLowerCase()) {
      case 'charging':
        return 'charging';
      case 'parking':
        return 'parking';
      case 'hybrid':
        return 'hybrid';
      default:
        return 'hybrid';
    }
  }
  return type.toString();
}
```

### 2. **Appwrite Configuration** (`lib/core/appwrite_config.dart`)

- Uses environment variables from `.env` file
- Supports custom Appwrite endpoint via `APPWRITE_ENDPOINT`
- Self-signed certificate support for development
- Database ID: `parkcharge_db`
- Collection IDs:
  - `stations` - Charging stations
  - `slots` - Individual parking/charging slots
  - `bookings` - User bookings
  - `users` - User profiles

### 3. **Provider Integration** (`lib/providers/stations_provider.dart`)

The existing provider setup works with the updated service:

- `StationsStateNotifier` - Manages station list state
- `nearbyStationsProvider` - Fetches stations based on location
- `selectedStationProvider` - Tracks selected station
- `stationByIdProvider` - Fetches single station by ID
- `stationSlotsProvider` - Fetches slots for a station

## How It Works

### 1. **Location-Based Fetch**
```dart
await loadNearbyStations(position);
// Fetches all stations within 10km radius (configurable)
```

### 2. **Distance Calculation**
Using the Haversine formula to calculate distance between user location and each station:
```dart
double _calculateDistance(double lat1, double lon1, double lat2, double lon2)
```

### 3. **Error Handling**
```dart
on AppwriteException catch (e) {
  switch (e.code) {
    case 400: return 'Invalid request data';
    case 401: return 'Unauthorized access';
    case 404: return 'Resource not found';
    case 429: return 'Too many requests';
    default: return 'Database operation failed';
  }
}
```

## Setup Required

### 1. **Environment Variables**
Your `.env` file should have:
```env
APPWRITE_ENDPOINT=https://appwrite.p1ng.me/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key
DATABASE_ID=parkcharge_db
STATIONS_COLLECTION_ID=stations
SLOTS_COLLECTION_ID=slots
BOOKINGS_COLLECTION_ID=bookings
USERS_COLLECTION_ID=users
```

### 2. **Run Setup Script**
```bash
cd /home/sravan/dev/UniCharge
python3 scripts/setup_appwrite_data.py
```

This will:
- Create database and collections
- Add 5 sample stations in Bangalore
- Create slots for each station
- Set up correct data structure

### 3. **Verify Data in Appwrite**
Go to your Appwrite dashboard and verify:
- Database: `parkcharge_db` exists
- Collection: `stations` has documents
- Check that data matches expected format

## Sample Station Data Structure

```json
{
  "id": "unique_id",
  "name": "MG Road Charging Hub",
  "address": "MG Road, Bangalore, Karnataka 560001",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "type": "hybrid",
  "pricePerHour": 50.0,
  "batterySwap": true,
  "totalSlots": 20,
  "availableSlots": 15,
  "imageUrl": "https://example.com/mg-road-hub.jpg",
  "amenities": "WiFi,Restroom,Café,24/7 Access",
  "createdAt": "2024-10-27T00:00:00.000Z",
  "updatedAt": "2024-10-27T00:00:00.000Z"
}
```

## Features

### 1. **Automatic Distance Filtering**
- Fetches stations within configurable radius (default: 10km)
- Updates dynamically as user moves

### 2. **Real-time Updates**
- Stations are refreshed when location changes
- Available slots count is synchronized

### 3. **Error Recovery**
- Graceful error handling
- User-friendly error messages
- Retry mechanism built-in

### 4. **Data Type Safety**
- Handles Appwrite's string data types
- Converts to proper Dart types
- Prevents runtime errors

## Usage in App

### Map Screen
```dart
final stationsState = ref.watch(stationsStateProvider);
stationsState.whenData((stations) {
  // Display stations on map
});
```

### Stations List Screen
```dart
final locationState = ref.watch(locationStateProvider);
locationState.whenData((position) {
  ref.read(stationsStateProvider.notifier).loadNearbyStations(position);
});
```

## Testing

1. **Start the app** - Grant location permissions
2. **Check Map Screen** - Should see station markers
3. **Check Stations List** - Should list nearby stations
4. **Tap station** - Should show details

## Troubleshooting

### No Stations Appearing?
1. Run setup script: `python3 scripts/setup_appwrite_data.py`
2. Check `.env` file has correct values
3. Verify Appwrite dashboard shows data
4. Check app logs for errors

### Authentication Errors?
1. Verify API key in `.env`
2. Check permissions in Appwrite collection
3. Ensure database exists

### Wrong Location Data?
1. Verify station coordinates in Appwrite
2. Check data format matches expected structure
3. Run setup script again to reset data

## Next Steps

1. ✅ Stations now fetch from Appwrite
2. ⏳ Test with actual data from setup script
3. ⏳ Add real-time updates via Appwrite Realtime
4. ⏳ Implement booking functionality
5. ⏳ Add user authentication flow

## Notes

- Distance is calculated in kilometers
- Default radius is 10km (configurable)
- Station availability is calculated from slots
- Amenities can be comma-separated or array
- Type conversion handles both string and native types

