# QR Code Booking System

## Overview
A secure QR code system for booking verification in the UniCharge platform. QR codes are generated when bookings are created and scanned by admins to activate bookings.

## Components

### 1. QR Token Service (`lib/services/qr_token_service.dart`)
Secure token generation and verification service.

**Features:**
- Generates secure tokens in format: `bookingId:timestamp:signature`
- Verifies token validity and expiration (24 hours)
- Extracts booking ID from tokens
- Uses SHA-256 hashing for security

**Key Methods:**
- `generateSecureToken(bookingId)` - Creates a secure token
- `verifyToken(token, bookingId)` - Validates token
- `getBookingIdFromToken(token)` - Extracts booking ID
- `isTokenExpired(token)` - Checks expiration

### 2. Booking Model Updates
Added `qrToken` field to the `BookingModel`:
- Generated automatically when booking is created
- Stored securely in Firestore
- Displayed in QR code format to users

### 3. Booking Confirmation Screen (`lib/features/bookings/screens/booking_confirmation_screen.dart`)
Displays QR code after successful booking creation.

**Features:**
- Large, scannable QR code
- Booking details summary
- Instructions for admins
- Auto-generated using `qr_flutter` package

### 4. Admin QR Scanner (`lib/features/admin/screens/qr_scanner_screen.dart`)
Admin tool for scanning and verifying booking QR codes.

**Features:**
- Camera-based QR code scanning
- Real-time validation
- Secure token verification
- Automatic booking activation on successful scan
- User feedback for all states (scanning, processing, success, error)

**How it works:**
1. Admin opens scanner from Profile screen
2. Camera scans for QR codes
3. Token is extracted and verified
4. Booking is fetched from database
5. Status is checked (must be 'reserved')
6. Booking is activated (status → 'active', slot → 'occupied')
7. Success confirmation is shown

### 5. Database Service Updates
Added methods to `FirestoreDatabaseService`:

- `getBookingById(bookingId)` - Fetches booking by ID
- `createBooking()` - Now generates and stores QR token
- Booking creation includes QR token generation

## Security Features

1. **Token Format**: `bookingId:timestamp:signature`
   - Includes booking ID for verification
   - Timestamp for expiration checking
   - Cryptographic signature for tamper detection

2. **Expiration**: Tokens expire after 24 hours
   - Prevents reuse of old bookings
   - Ensures timely activation

3. **Verification**: Multiple validation steps
   - Token format validation
   - Booking ID matching
   - Status verification (must be 'reserved')
   - Expiration checking

4. **Admin-Only Activation**: 
   - Only admin scanning marks slot as occupied
   - Prevents unauthorized slot activation
   - User shows QR code, admin scans it

## User Flow

### Booking Creation
1. User selects station and slot
2. Chooses duration (1, 2, 4, or 8 hours)
3. Confirms booking
4. Booking is created with status 'reserved'
5. QR code is automatically generated
6. QR code is displayed on confirmation screen
7. User presents QR code to admin at station

### Admin Verification
1. Admin opens QR scanner from Profile screen
2. Scans user's QR code
3. System validates token
4. Booking status changes: 'reserved' → 'active'
5. Slot status changes: 'reserved' → 'occupied'
6. Confirmation shown to admin
7. User can now use the slot

## Dependencies Added

```yaml
# QR Code Generation
qr_flutter: ^4.1.0

# QR Code Scanning
mobile_scanner: ^7.1.3

# Security
crypto: ^3.0.5
```

## Admin Access

Admins can access the QR scanner from:
- **Profile Screen** → "Admin Access" section
- Click "Scan Booking QR Code" button
- Full screen scanner opens

## Error Handling

The system handles various error scenarios:
- Invalid QR code format
- Expired tokens
- Booking not found
- Already activated bookings
- Network errors
- Permission issues

All errors are clearly communicated to admin with descriptive messages.

## Future Enhancements

Potential improvements:
1. Role-based access control for admins
2. Booking history with QR codes
3. Offline QR code generation
4. QR code refresh functionality
5. Multi-language support
6. Analytics for scan rates
7. Push notifications on successful activation

## Testing

To test the system:
1. Create a booking from any station
2. Note the QR code shown
3. Go to Profile screen
4. Click "Scan Booking QR Code"
5. Scan the QR code from the booking confirmation screen
6. Verify booking status changes to 'active'

