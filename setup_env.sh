#!/bin/bash

# UniCharge Environment Setup Script
# This script helps you set up environment variables for the UniCharge project

echo "🚀 UniCharge Environment Setup"
echo "================================"

# Check if .env file exists
if [ ! -f ".env" ]; then
    if [ -f "env.example" ]; then
        echo "📝 Copying env.example to .env..."
        cp env.example .env
    else
        echo "📝 Creating .env file..."
        cat > .env << EOF
# Appwrite Configuration
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=YOUR_PROJECT_ID
APPWRITE_DATABASE_ID=parkcharge_db
APPWRITE_API_KEY=YOUR_API_KEY

# Collection IDs
APPWRITE_STATIONS_COLLECTION_ID=stations
APPWRITE_SLOTS_COLLECTION_ID=slots
APPWRITE_BOOKINGS_COLLECTION_ID=bookings
APPWRITE_USERS_COLLECTION_ID=users
EOF
    echo "✅ Created .env file with default values"
else
    echo "📄 .env file already exists"
fi

echo ""
echo "🔧 Configuration Steps:"
echo "1. Edit the .env file with your actual Appwrite credentials"
echo "2. Run 'source .env' to load environment variables"
echo "3. Or run 'export \$(cat .env | xargs)' to load them"
echo ""
echo "📋 Required Appwrite Setup:"
echo "1. Create an Appwrite project at https://appwrite.io"
echo "2. Get your Project ID and API Key"
echo "3. Create the database and collections as specified in README.md"
echo ""
echo "🚀 Quick Start:"
echo "1. Update .env with your credentials"
echo "2. Run: source .env"
echo "3. Run: python init_demo_data.py"
echo "4. Run: python simulate_update.py"
echo "5. Run: flutter run"
echo ""
echo "Happy coding! 🎉"
