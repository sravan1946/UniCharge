# GitIgnore and Environment Setup

This document explains the `.gitignore` configuration and environment variable setup for the UniCharge project.

## .gitignore Configuration

The project includes a comprehensive `.gitignore` file that excludes:

### 🔐 **Sensitive Files**
- `.env` files (environment variables)
- API keys and secrets
- Configuration files with credentials
- Service account keys

### 🏗️ **Build Artifacts**
- Flutter build outputs (`build/`, `dist/`)
- Android APK files (`*.apk`)
- iOS build files
- Python bytecode (`__pycache__/`, `*.pyc`)

### 🛠️ **Development Files**
- IDE configuration (`.vscode/`, `.idea/`)
- Editor temporary files
- OS-specific files (`.DS_Store`, `Thumbs.db`)
- Log files (`*.log`)

### 📦 **Dependencies**
- `node_modules/`
- Python virtual environments (`venv/`, `.venv/`)
- Flutter packages (`.dart_tool/`, `.packages`)

## Environment Variables

### Quick Setup

1. **Copy the example file:**
   ```bash
   cp env.example .env
   ```

2. **Edit with your credentials:**
   ```bash
   nano .env  # or your preferred editor
   ```

3. **Load environment variables:**
   ```bash
   # Linux/macOS
   source .env
   
   # Windows
   set /p VAR= < .env
   ```

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `APPWRITE_ENDPOINT` | Appwrite server URL | `https://cloud.appwrite.io/v1` |
| `APPWRITE_PROJECT_ID` | Your project ID | `your-project-id` |
| `APPWRITE_API_KEY` | API key for operations | `your-api-key` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APPWRITE_DATABASE_ID` | Database name | `parkcharge_db` |
| `APPWRITE_STATIONS_COLLECTION_ID` | Stations collection | `stations` |
| `APPWRITE_SLOTS_COLLECTION_ID` | Slots collection | `slots` |
| `APPWRITE_BOOKINGS_COLLECTION_ID` | Bookings collection | `bookings` |
| `APPWRITE_USERS_COLLECTION_ID` | Users collection | `users` |

## Security Best Practices

### ✅ **Do**
- Use environment variables for all sensitive data
- Keep `.env` files out of version control
- Use different credentials for dev/staging/prod
- Rotate API keys regularly
- Use `.env.example` as a template

### ❌ **Don't**
- Commit `.env` files to git
- Hardcode credentials in source code
- Share API keys in chat/email
- Use production credentials in development
- Store secrets in configuration files

## Setup Scripts

### Linux/macOS
```bash
./setup_env.sh
```

### Windows
```cmd
setup_env.bat
```

These scripts will:
1. Check if `.env` exists
2. Copy from `env.example` if available
3. Create a new `.env` with defaults if needed
4. Display setup instructions

## Verification

### Check Environment Variables
```bash
# Linux/macOS
env | grep APPWRITE

# Windows
set | findstr APPWRITE
```

### Test Configuration
```bash
# Python scripts will validate on startup
python init_demo_data.py
python simulate_update.py

# Flutter app shows configuration screen if not configured
flutter run
```

## Troubleshooting

### Environment Variables Not Loading
```bash
# Check if .env exists
ls -la .env

# Reload environment
source .env

# Check specific variable
echo $APPWRITE_PROJECT_ID
```

### Git Ignore Not Working
```bash
# Check if file is already tracked
git ls-files | grep .env

# Remove from tracking if needed
git rm --cached .env

# Add to .gitignore
echo ".env" >> .gitignore
```

### Build Errors
```bash
# Clean Flutter build
cd unicharge_app
flutter clean
flutter pub get

# Clean Python cache
find . -name "__pycache__" -type d -exec rm -rf {} +
```

## File Structure

```
UniCharge/
├── .gitignore              # Git ignore rules
├── env.example             # Environment template
├── .env                    # Your environment (ignored)
├── setup_env.sh           # Linux/macOS setup
├── setup_env.bat          # Windows setup
├── unicharge_app/         # Flutter app
│   ├── lib/
│   │   ├── config/        # Environment config
│   │   └── constants/     # App configuration
│   └── .gitignore         # Flutter-specific ignores
├── simulate_update.py     # Python simulation
├── init_demo_data.py      # Data initialization
└── requirements.txt       # Python dependencies
```

## Contributing

When contributing to this project:

1. **Never commit `.env` files**
2. **Update `env.example` if adding new variables**
3. **Test with clean environment**
4. **Document new environment variables**

## Support

If you encounter issues:

1. Check this documentation
2. Verify environment variables are loaded
3. Ensure `.env` file exists and is properly formatted
4. Check the main [README.md](README.md) for setup instructions
5. Create an issue with details about your environment
