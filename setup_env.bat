@echo off
REM UniCharge Environment Setup Script for Windows
REM This script helps you set up environment variables for the UniCharge project

echo 🚀 UniCharge Environment Setup
echo ================================

REM Check if .env file exists
if not exist ".env" (
    if exist "env.example" (
        echo 📝 Copying env.example to .env...
        copy env.example .env
    ) else (
        echo 📝 Creating .env file...
        (
        echo # Appwrite Configuration
        echo APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
        echo APPWRITE_PROJECT_ID=YOUR_PROJECT_ID
        echo APPWRITE_DATABASE_ID=parkcharge_db
        echo APPWRITE_API_KEY=YOUR_API_KEY
        echo.
        echo # Collection IDs
        echo APPWRITE_STATIONS_COLLECTION_ID=stations
        echo APPWRITE_SLOTS_COLLECTION_ID=slots
        echo APPWRITE_BOOKINGS_COLLECTION_ID=bookings
        echo APPWRITE_USERS_COLLECTION_ID=users
        ) > .env
        echo ✅ Created .env file with default values
    )
) else (
    echo 📄 .env file already exists
)

echo.
echo 🔧 Configuration Steps:
echo 1. Edit the .env file with your actual Appwrite credentials
echo 2. Run 'set' command to set environment variables
echo 3. Or use a tool like 'dotenv' to load them
echo.
echo 📋 Required Appwrite Setup:
echo 1. Create an Appwrite project at https://appwrite.io
echo 2. Get your Project ID and API Key
echo 3. Create the database and collections as specified in README.md
echo.
echo 🚀 Quick Start:
echo 1. Update .env with your credentials
echo 2. Run: set /p VAR=^< .env
echo 3. Run: python init_demo_data.py
echo 4. Run: python simulate_update.py
echo 5. Run: flutter run
echo.
echo Happy coding! 🎉
pause
