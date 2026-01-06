# ParkCharge Setup Guide

This guide will help you set up and run the ParkCharge application.

## Prerequisites

✅ **Flutter SDK** - Already installed (version 3.35.3)
✅ **Dart SDK** - Included with Flutter
✅ **Android Studio** - Already installed
✅ **Chrome** - Available for web development

## Setup Steps

### 1. Environment Variables Setup

The `.env` file exists in your project root. Verify it has the correct configuration:

```bash
# Check your .env file
cat .env
```

Required values:
- `APPWRITE_ENDPOINT` - Your Appwrite server URL
- `APPWRITE_PROJECT_ID` - Your Appwrite project ID
- `APPWRITE_API_KEY` - Your Appwrite API key
- `GOOGLE_MAPS_API_KEY` - Your Google Maps API key

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

✅ Already done!

### 3. Verify Code Generation

The generated files (`.freezed.dart` and `.g.dart`) already exist.

If you modify the models in the future, regenerate them with:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. Missing Fonts (Optional)

The Inter font is referenced in `pubspec.yaml` but the font files are missing from `assets/fonts/`. 

**Option A: Download Inter Fonts**
```bash
# Download Inter font files
cd assets/fonts
wget https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Regular.ttf
wget https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Medium.ttf
wget https://github.com/rsms/inter/raw/master/docs/font-files/Inter-SemiBold.ttf
wget https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Bold.ttf
```

**Option B: Remove Font Reference**
Edit `pubspec.yaml` to remove the font configuration, and the app will use the default system font.

### 5. Missing Assets (Optional)

The following assets are missing but optional:
- `assets/images/` - Placeholder images
- `assets/animations/` - Rive animations for charging effects

These are optional for now and won't prevent the app from running.

### 6. Run the Application

#### Mobile App (Android Emulator or Device)
```bash
flutter run
```

#### Web Version
```bash
flutter run -d chrome
```

#### Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### 7. Appwrite Backend Setup (If Needed)

If your Appwrite backend isn't set up yet:

1. **Set up Appwrite collections** (optional - app creates them automatically):
```bash
cd scripts
pip install -r ../simulation/requirements.txt
python setup_appwrite_data.py
```

2. **Or manually create collections** in Appwrite Console:
   - `stations` - Station data
   - `slots` - Parking/charging slots
   - `bookings` - User bookings
   - `users` - User profiles

### 8. Run Simulation (Optional)

For a demo with realistic data:

```bash
cd simulation
pip install -r requirements.txt
python simulate.py --mode random
```

## Quick Start Commands

```bash
# 1. Get dependencies (already done)
flutter pub get

# 2. Run on connected device
flutter run

# 3. Run on Chrome
flutter run -d chrome

# 4. Build for Android
flutter build apk

# 5. Build for Web
flutter build web
```

## Troubleshooting

### Issue: Fonts not found
The Inter font files are missing. Either download them (see step 4) or remove the font configuration from `pubspec.yaml`.

### Issue: Appwrite connection failed
- Verify your `.env` file has correct Appwrite credentials
- Check if your Appwrite server is running and accessible
- Ensure `self-signed` certificates are allowed in development

### Issue: Google Maps not working
- Verify `GOOGLE_MAPS_API_KEY` in `.env`
- Check API key restrictions in Google Cloud Console
- Ensure Maps SDK is enabled for your platform

### Issue: Build errors
```bash
# Clean build cache
flutter clean
flutter pub get

# Regenerate code
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Current Status

✅ Flutter dependencies installed  
✅ Dart code analysis passing  
✅ Generated model files present  
✅ Environment file exists  

⚠️ Font files missing (optional)  
⚠️ Asset images/animations missing (optional)  

## Next Steps

1. Verify your `.env` file has correct Appwrite and Google Maps credentials
2. Run the app: `flutter run`
3. (Optional) Download Inter fonts if you want custom typography
4. (Optional) Add placeholder images in `assets/images/`
5. (Optional) Add Rive animations in `assets/animations/`

## Development Tips

- Use `flutter run -d chrome` for web development
- Use `flutter run` for mobile development
- Enable developer options: Settings → About → Build number
- Check logs: `flutter logs` or use Android Studio

---

**Ready to run!** 🚀

Use `flutter run` to start the app on your connected device or emulator.

