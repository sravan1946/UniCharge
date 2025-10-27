# Appwrite Database Setup Guide for ParkCharge

This guide explains how to set up the Appwrite database collections and sample data for the ParkCharge app.

## Quick Setup

### Option 1: Automated Setup (Recommended)

Run the Python setup script to automatically create collections and populate sample data:

```bash
cd /home/sravan/dev/UniCharge
python3 scripts/setup_appwrite_data.py
```

**Prerequisites:**
```bash
pip3 install appwrite python-dotenv
```

### Option 2: Manual Setup

Follow the manual setup instructions below.

---

## Database Configuration

**Database Name:** `parkcharge_db` (or as configured in `.env`)

---

## Collection 1: Stations (`stations`)

### Attributes

| Key | Type | Size | Required | Description |
|-----|------|------|----------|-------------|
| `name` | string | 100 | ✅ | Station name |
| `address` | string | 200 | ✅ | Full address |
| `latitude` | double | - | ✅ | GPS latitude |
| `longitude` | double | - | ✅ | GPS longitude |
| `type` | string | 20 | ✅ | Station type: `charging`, `parking`, or `hybrid` |
| `pricePerHour` | double | - | ✅ | Price per hour in local currency |
| `batterySwap` | boolean | - | ✅ | Whether battery swap is available |
| `totalSlots` | integer | - | ✅ | Total number of slots |
| `availableSlots` | integer | - | ✅ | Currently available slots |
| `imageUrl` | string | 500 | ❌ | Station image URL |
| `amenities` | string | 1000 | ❌ | Comma-separated list of amenities |
| `createdAt` | datetime | - | ✅ | Creation timestamp |
| `updatedAt` | datetime | - | ✅ | Last update timestamp |

### Sample Data

```json
{
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
  "amenities": "WiFi,Restroom,Café,24/7 Access"
}
```

---

## Collection 2: Slots (`slots`)

### Attributes

| Key | Type | Size | Required | Description |
|-----|------|------|----------|-------------|
| `stationId` | string | 50 | ✅ | Reference to station ID |
| `slotIndex` | integer | - | ✅ | Slot number/index |
| `type` | string | 20 | ✅ | Slot type: `parking_space` or `charging_pad` |
| `status` | string | 20 | ✅ | Status: `available`, `occupied`, `reserved`, or `maintenance` |
| `batteryStatus` | string | 20 | ❌ | Battery status: `charged`, `charging`, `empty`, or `swapped` |
| `lastUpdated` | datetime | - | ✅ | Last status update time |
| `reservedByUserId` | string | 50 | ❌ | User ID if reserved |
| `reservedUntil` | datetime | - | ❌ | Reservation expiry time |

### Sample Data

```json
{
  "stationId": "station_id_here",
  "slotIndex": 1,
  "type": "charging_pad",
  "status": "available",
  "batteryStatus": "charged",
  "lastUpdated": "2024-10-27T00:00:00.000Z"
}
```

---

## Collection 3: Bookings (`bookings`)

### Attributes

| Key | Type | Size | Required | Description |
|-----|------|------|----------|-------------|
| `userId` | string | 50 | ✅ | User ID |
| `stationId` | string | 50 | ✅ | Station ID |
| `slotId` | string | 50 | ✅ | Slot ID |
| `status` | string | 20 | ✅ | Status: `pending`, `active`, `completed`, or `cancelled` |
| `startTime` | datetime | - | ✅ | Booking start time |
| `endTime` | datetime | - | ❌ | Booking end time |
| `pricePerHour` | double | - | ✅ | Price per hour at booking time |
| `durationHours` | integer | - | ✅ | Booking duration in hours |
| `totalPrice` | double | - | ✅ | Total booking price |
| `createdAt` | datetime | - | ✅ | Creation timestamp |
| `cancelledAt` | datetime | - | ❌ | Cancellation timestamp |
| `cancellationReason` | string | 200 | ❌ | Reason for cancellation |

### Sample Data

```json
{
  "userId": "user_id_here",
  "stationId": "station_id_here",
  "slotId": "slot_id_here",
  "status": "active",
  "startTime": "2024-10-27T10:00:00.000Z",
  "pricePerHour": 50.0,
  "durationHours": 2,
  "totalPrice": 100.0,
  "createdAt": "2024-10-27T09:00:00.000Z"
}
```

---

## Collection 4: Users (`users`)

### Attributes

| Key | Type | Size | Required | Description |
|-----|------|------|----------|-------------|
| `email` | string | 100 | ✅ | User email |
| `name` | string | 100 | ✅ | User full name |
| `phoneNumber` | string | 20 | ❌ | Phone number |
| `profileImageUrl` | string | 500 | ❌ | Profile image URL |
| `totalBookings` | integer | - | ✅ | Total bookings count |
| `totalHoursParked` | double | - | ✅ | Total hours parked |
| `loyaltyPoints` | integer | - | ✅ | Loyalty points |
| `createdAt` | datetime | - | ✅ | Account creation time |
| `updatedAt` | datetime | - | ✅ | Last update timestamp |
| `preferences` | string | 1000 | ❌ | JSON string of user preferences |

### Sample Data

```json
{
  "email": "john.doe@example.com",
  "name": "John Doe",
  "phoneNumber": "+91 9876543210",
  "totalBookings": 24,
  "totalHoursParked": 156.5,
  "loyaltyPoints": 2450,
  "preferences": "{\"notifications\": true, \"darkMode\": false}"
}
```

---

## Permissions Setup

For each collection, set the following permissions:

### Development (Recommended)
- **Read:** `read("any")` - Allow anyone to read
- **Write:** `write("any")` - Allow anyone to write

### Production
- **Read:** `read("users")` - Only authenticated users
- **Write:** `write("users")` - Only authenticated users

---

## Data Types Reference

### Station Types
- `charging` - EV charging only
- `parking` - Parking only  
- `hybrid` - Both charging and parking

### Slot Status Values
- `available` - Slot is available
- `occupied` - Slot is in use
- `reserved` - Slot is reserved
- `maintenance` - Slot is under maintenance

### Slot Type Values
- `parking_space` - Standard parking space
- `charging_pad` - EV charging pad

### Battery Status Values (for charging pads)
- `charged` - Battery is fully charged
- `charging` - Battery is currently charging
- `empty` - Battery is empty
- `swapped` - Battery has been swapped

### Booking Status Values
- `pending` - Booking created but not started
- `active` - Booking is currently active
- `completed` - Booking has ended
- `cancelled` - Booking was cancelled

---

## Sample Data Included

The setup script creates:

### 5 Sample Stations (in Bangalore)
1. **MG Road Charging Hub** - Hybrid, 20 slots
2. **Koramangala Tech Park** - Hybrid, 30 slots
3. **Whitefield Mall Station** - Charging, 15 slots
4. **Indiranagar Metro Station** - Parking, 50 slots
5. **Electronic City Hub** - Hybrid, 25 slots

### Slots
- Automatically creates slots for each station based on `totalSlots`
- Mix of available, occupied, and maintenance status
- Proper slot types based on station type

### 3 Sample Users
- John Doe - 24 bookings, 156.5 hours parked
- Jane Smith - 18 bookings, 98 hours parked
- Mike Wilson - 32 bookings, 210 hours parked

---

## Verification

After running the setup script, verify the collections were created:

1. **Check Database**
   - Database ID: `parkcharge_db` (or your custom ID)
   - Should see 4 collections: stations, slots, bookings, users

2. **Test Data**
   - Stations collection should have 5 documents
   - Slots collection should have multiple slots per station
   - Users collection should have 3 sample users

---

## Environment Variables

Make sure your `.env` file has these variables set:

```env
APPWRITE_ENDPOINT=https://your-appwrite-instance.com/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key
DATABASE_ID=parkcharge_db
STATIONS_COLLECTION_ID=stations
SLOTS_COLLECTION_ID=slots
BOOKINGS_COLLECTION_ID=bookings
USERS_COLLECTION_ID=users
```

---

## Troubleshooting

### Issue: "Collection already exists"
- This is normal if you're re-running the script
- The script will skip existing collections

### Issue: "Attribute already exists"
- Attributes are created only once
- This warning can be ignored

### Issue: "Permission denied"
- Check your API key permissions in Appwrite
- Ensure the API key has database write permissions

### Issue: Sample data not showing in app
1. Verify `.env` file has correct values
2. Check that collection IDs match in the app
3. Restart the Flutter app after setup

---

## Next Steps

1. ✅ Run the setup script to create collections
2. ✅ Verify data in Appwrite dashboard
3. ✅ Test the app - locations should appear on map
4. ✅ Run the simulation script to see live updates

```bash
# Run simulation (optional)
python3 simulation/simulate.py
```

---

## Notes

- The setup script uses `ID.unique()` to generate unique IDs for all documents
- All timestamps use UTC timezone in ISO 8601 format
- Amenities are stored as comma-separated strings for simplicity
- User preferences are stored as JSON strings
- Slot indices start from 1 (not 0)

