# Environment Setup Guide

This guide explains how to configure UniCharge using environment variables for flexible deployment and development.

## Quick Setup

### Option 1: Using Setup Scripts

**Linux/macOS:**
```bash
./setup_env.sh
```

**Windows:**
```cmd
setup_env.bat
```

### Option 2: Manual Setup

1. **Create .env file** in the project root:
```bash
# Appwrite Configuration
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_DATABASE_ID=parkcharge_db
APPWRITE_API_KEY=your-api-key

# Collection IDs
APPWRITE_STATIONS_COLLECTION_ID=stations
APPWRITE_SLOTS_COLLECTION_ID=slots
APPWRITE_BOOKINGS_COLLECTION_ID=bookings
APPWRITE_USERS_COLLECTION_ID=users
```

2. **Load environment variables:**
```bash
# Linux/macOS
source .env

# Windows
set /p VAR= < .env
```

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `APPWRITE_ENDPOINT` | Appwrite server endpoint | `https://cloud.appwrite.io/v1` | Yes |
| `APPWRITE_PROJECT_ID` | Your Appwrite project ID | `YOUR_PROJECT_ID` | Yes |
| `APPWRITE_DATABASE_ID` | Database ID | `parkcharge_db` | No |
| `APPWRITE_API_KEY` | API key for server operations | `YOUR_API_KEY` | Yes |
| `APPWRITE_STATIONS_COLLECTION_ID` | Stations collection ID | `stations` | No |
| `APPWRITE_SLOTS_COLLECTION_ID` | Slots collection ID | `slots` | No |
| `APPWRITE_BOOKINGS_COLLECTION_ID` | Bookings collection ID | `bookings` | No |
| `APPWRITE_USERS_COLLECTION_ID` | Users collection ID | `users` | No |

## Appwrite Setup

### 1. Create Appwrite Project

1. Go to [appwrite.io](https://appwrite.io)
2. Sign up or log in
3. Create a new project
4. Note your Project ID

### 2. Get API Key

1. Go to your project dashboard
2. Navigate to "API Keys"
3. Create a new API key with these permissions:
   - `databases.read`
   - `databases.write`
   - `collections.read`
   - `collections.write`
   - `documents.read`
   - `documents.write`

### 3. Create Database and Collections

Run the initialization script after setting up environment variables:

```bash
python init_demo_data.py
```

Or create manually using the Appwrite console:

**Database:** `parkcharge_db`

**Collections:**
- `stations` - Parking/charging stations
- `slots` - Individual parking/charging slots
- `bookings` - User bookings and reservations
- `users` - User profiles and preferences

## Development Workflow

### 1. Set Environment Variables

```bash
# Load environment variables
source .env

# Verify configuration
echo $APPWRITE_PROJECT_ID
echo $APPWRITE_API_KEY
```

### 2. Initialize Demo Data

```bash
python init_demo_data.py
```

### 3. Start Simulation (Optional)

```bash
python simulate_update.py
```

### 4. Run Flutter App

```bash
cd unicharge_app
flutter run
```

## Production Deployment

### Environment Variables in Production

**Docker:**
```dockerfile
ENV APPWRITE_ENDPOINT=https://your-appwrite-instance.com/v1
ENV APPWRITE_PROJECT_ID=your-production-project-id
ENV APPWRITE_API_KEY=your-production-api-key
```

**Kubernetes:**
```yaml
env:
  - name: APPWRITE_ENDPOINT
    value: "https://your-appwrite-instance.com/v1"
  - name: APPWRITE_PROJECT_ID
    value: "your-production-project-id"
  - name: APPWRITE_API_KEY
    valueFrom:
      secretKeyRef:
        name: appwrite-secrets
        key: api-key
```

**Cloud Platforms:**
- **Vercel:** Add environment variables in project settings
- **Netlify:** Add environment variables in site settings
- **Heroku:** Use `heroku config:set` command

### Security Best Practices

1. **Never commit .env files** to version control
2. **Use different API keys** for development and production
3. **Rotate API keys** regularly
4. **Use environment-specific endpoints** (dev/staging/prod)
5. **Store sensitive data** in secure secret management systems

## Troubleshooting

### Common Issues

1. **Environment variables not loaded:**
   ```bash
   # Check if variables are set
   env | grep APPWRITE
   
   # Reload environment
   source .env
   ```

2. **Appwrite connection failed:**
   - Verify endpoint URL
   - Check project ID
   - Validate API key permissions

3. **Collection not found:**
   - Run `python init_demo_data.py`
   - Check collection IDs in environment variables

4. **Flutter build errors:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Debug Mode

Enable debug logging in the Flutter app:

```dart
// In main.dart
void main() {
  AppwriteConfig.printConfig(); // This will print current config
  runApp(const UniChargeApp());
}
```

## Configuration Validation

The app includes built-in configuration validation:

- **Configuration Screen:** Access via Settings → Appwrite Configuration
- **Startup Check:** App shows configuration screen if not properly configured
- **Debug Output:** Configuration status printed on app startup

## Multiple Environments

### Development
```bash
# .env.development
APPWRITE_ENDPOINT=https://dev.appwrite.io/v1
APPWRITE_PROJECT_ID=dev-project-id
```

### Staging
```bash
# .env.staging
APPWRITE_ENDPOINT=https://staging.appwrite.io/v1
APPWRITE_PROJECT_ID=staging-project-id
```

### Production
```bash
# .env.production
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=prod-project-id
```

Load specific environment:
```bash
source .env.development
# or
source .env.production
```

## Support

If you encounter issues:

1. Check the [troubleshooting section](#troubleshooting)
2. Review the [main README.md](README.md)
3. Check [Appwrite documentation](https://appwrite.io/docs)
4. Create an issue in the project repository
