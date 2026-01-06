#!/usr/bin/env python3
"""
UniCharge Demo Data Initialization Script
Creates sample stations and slots for testing and demonstration
"""

import json
from datetime import datetime, timezone
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID
from dotenv import load_dotenv
import os
import time

# Load environment variables from .env file
load_dotenv()
print("✅ Loaded environment variables from .env file")

# Appwrite Configuration from environment variables
APPWRITE_ENDPOINT = os.getenv('APPWRITE_ENDPOINT', 'https://cloud.appwrite.io/v1')
PROJECT_ID = os.getenv('APPWRITE_PROJECT_ID', 'YOUR_PROJECT_ID')
API_KEY = os.getenv('APPWRITE_API_KEY', 'YOUR_API_KEY')
DATABASE_ID = os.getenv('APPWRITE_DATABASE_ID', 'parkcharge_db')

# Debug output
print(f"🔧 Configuration:")
print(f"   Endpoint: {APPWRITE_ENDPOINT}")
print(f"   Project ID: {PROJECT_ID}")
print(f"   Database ID: {DATABASE_ID}")
print(f"   API Key: {API_KEY[:20]}..." if API_KEY and API_KEY != 'YOUR_API_KEY' else "   API Key: NOT_SET")

# Collection IDs from environment variables
STATIONS_COLLECTION_ID = os.getenv('APPWRITE_STATIONS_COLLECTION_ID', 'stations')
SLOTS_COLLECTION_ID = os.getenv('APPWRITE_SLOTS_COLLECTION_ID', 'slots')
BOOKINGS_COLLECTION_ID = os.getenv('APPWRITE_BOOKINGS_COLLECTION_ID', 'bookings')
USERS_COLLECTION_ID = os.getenv('APPWRITE_USERS_COLLECTION_ID', 'users')

def initialize_demo_data():
    """Initialize demo data for UniCharge app"""
    
    # Initialize Appwrite client
    client = Client()
    client.set_endpoint(APPWRITE_ENDPOINT)
    client.set_project(PROJECT_ID)
    client.set_key(API_KEY)
    
    databases = Databases(client)
    
    print("🚀 Initializing UniCharge Demo Data...")
    
    # Create database if it doesn't exist
    try:
        print(f"📦 Creating database '{DATABASE_ID}'...")
        databases.create(
            database_id=DATABASE_ID,
            name="UniCharge Database",
            enabled=True
        )
        print(f"✅ Database '{DATABASE_ID}' created successfully!")
    except Exception as e:
        if "already exists" in str(e).lower() or "duplicate" in str(e).lower():
            print(f"ℹ️ Database '{DATABASE_ID}' already exists")
        else:
            print(f"⚠️ Database creation error: {e}")
    
    # Create collections
    collections_to_create = [
        {
            "id": STATIONS_COLLECTION_ID,
            "name": "Stations",
            "attributes": [
                {"key": "name", "type": "string", "size": 100, "required": True},
                {"key": "latitude", "type": "double", "required": True},
                {"key": "longitude", "type": "double", "required": True},
                {"key": "type", "type": "string", "size": 20, "required": True},
                {"key": "price_per_hour", "type": "double", "required": True},
                {"key": "battery_swap", "type": "boolean", "required": True},
                {"key": "address", "type": "string", "size": 200, "required": True},
                {"key": "total_slots", "type": "integer", "required": True},
                {"key": "available_slots", "type": "integer", "required": True},
                {"key": "rating", "type": "double", "required": True},
                {"key": "amenities", "type": "string", "size": 500, "required": False},
            ]
        },
        {
            "id": SLOTS_COLLECTION_ID,
            "name": "Slots",
            "attributes": [
                {"key": "station_id", "type": "string", "size": 50, "required": True},
                {"key": "slot_number", "type": "integer", "required": True},
                {"key": "status", "type": "string", "size": 20, "required": True},
                {"key": "type", "type": "string", "size": 20, "required": True},
                {"key": "power_output", "type": "double", "required": False},
                {"key": "connector_type", "type": "string", "size": 50, "required": False},
                {"key": "battery_status", "type": "string", "size": 20, "required": False},
                {"key": "last_updated", "type": "datetime", "required": False},
            ]
        },
        {
            "id": BOOKINGS_COLLECTION_ID,
            "name": "Bookings",
            "attributes": [
                {"key": "user_id", "type": "string", "size": 50, "required": True},
                {"key": "station_id", "type": "string", "size": 50, "required": True},
                {"key": "slot_id", "type": "string", "size": 50, "required": True},
                {"key": "status", "type": "string", "size": 20, "required": True},
                {"key": "start_time", "type": "datetime", "required": True},
                {"key": "end_time", "type": "datetime", "required": False},
                {"key": "price", "type": "double", "required": True},
                {"key": "notes", "type": "string", "size": 500, "required": False},
            ]
        },
        {
            "id": USERS_COLLECTION_ID,
            "name": "Users",
            "attributes": [
                {"key": "name", "type": "string", "size": 100, "required": True},
                {"key": "email", "type": "string", "size": 100, "required": True},
                {"key": "phone", "type": "string", "size": 20, "required": False},
                {"key": "vehicle_type", "type": "string", "size": 50, "required": False},
                {"key": "license_plate", "type": "string", "size": 20, "required": False},
                {"key": "loyalty_points", "type": "integer", "required": False},
                {"key": "preferences", "type": "string", "size": 1000, "required": False},
                {"key": "created_at", "type": "datetime", "required": False},
            ]
        }
    ]
    
    for collection in collections_to_create:
        try:
            print(f"📋 Creating collection '{collection['id']}'...")
            databases.create_collection(
                database_id=DATABASE_ID,
                collection_id=collection["id"],
                name=collection["name"],
                document_security=True
            )
            
            # Wait for collection to be ready
            print(f"   ⏳ Waiting for collection '{collection['id']}' to be ready...")
            time.sleep(2)
            
            # Add attributes
            print(f"   📝 Adding attributes to '{collection['id']}'...")
            for attr in collection["attributes"]:
                try:
                    print(f"     - Creating {attr['type']} attribute '{attr['key']}'...")
                    if attr["type"] == "string":
                        databases.create_string_attribute(
                            database_id=DATABASE_ID,
                            collection_id=collection["id"],
                            key=attr["key"],
                            size=attr.get("size", 255),
                            required=attr.get("required", False)
                        )
                    elif attr["type"] == "integer":
                        databases.create_integer_attribute(
                            database_id=DATABASE_ID,
                            collection_id=collection["id"],
                            key=attr["key"],
                            required=attr.get("required", False)
                        )
                    elif attr["type"] == "double":
                        databases.create_double_attribute(
                            database_id=DATABASE_ID,
                            collection_id=collection["id"],
                            key=attr["key"],
                            required=attr.get("required", False)
                        )
                    elif attr["type"] == "boolean":
                        databases.create_boolean_attribute(
                            database_id=DATABASE_ID,
                            collection_id=collection["id"],
                            key=attr["key"],
                            required=attr.get("required", False)
                        )
                    elif attr["type"] == "datetime":
                        databases.create_datetime_attribute(
                            database_id=DATABASE_ID,
                            collection_id=collection["id"],
                            key=attr["key"],
                            required=attr.get("required", False)
                        )
                    print(f"     ✅ Attribute '{attr['key']}' created successfully")
                except Exception as attr_error:
                    if "already exists" in str(attr_error).lower():
                        print(f"     ℹ️ Attribute '{attr['key']}' already exists")
                    else:
                        print(f"     ❌ Error creating attribute '{attr['key']}': {attr_error}")
            
            print(f"✅ Collection '{collection['id']}' created successfully!")
        except Exception as e:
            if "already exists" in str(e).lower() or "duplicate" in str(e).lower():
                print(f"ℹ️ Collection '{collection['id']}' already exists")
                # Still try to add attributes to existing collection
                print(f"   📝 Adding attributes to existing collection '{collection['id']}'...")
                for attr in collection["attributes"]:
                    try:
                        print(f"     - Creating {attr['type']} attribute '{attr['key']}'...")
                        if attr["type"] == "string":
                            databases.create_string_attribute(
                                database_id=DATABASE_ID,
                                collection_id=collection["id"],
                                key=attr["key"],
                                size=attr.get("size", 255),
                                required=attr.get("required", False)
                            )
                        elif attr["type"] == "integer":
                            databases.create_integer_attribute(
                                database_id=DATABASE_ID,
                                collection_id=collection["id"],
                                key=attr["key"],
                                required=attr.get("required", False)
                            )
                        elif attr["type"] == "double":
                            databases.create_float_attribute(
                                database_id=DATABASE_ID,
                                collection_id=collection["id"],
                                key=attr["key"],
                                required=attr.get("required", False)
                            )
                        elif attr["type"] == "boolean":
                            databases.create_boolean_attribute(
                                database_id=DATABASE_ID,
                                collection_id=collection["id"],
                                key=attr["key"],
                                required=attr.get("required", False)
                            )
                        elif attr["type"] == "datetime":
                            databases.create_datetime_attribute(
                                database_id=DATABASE_ID,
                                collection_id=collection["id"],
                                key=attr["key"],
                                required=attr.get("required", False)
                            )
                        print(f"     ✅ Attribute '{attr['key']}' created successfully")
                    except Exception as attr_error:
                        if "already exists" in str(attr_error).lower():
                            print(f"     ℹ️ Attribute '{attr['key']}' already exists")
                        else:
                            print(f"     ❌ Error creating attribute '{attr['key']}': {attr_error}")
            else:
                print(f"⚠️ Collection creation error for '{collection['id']}': {e}")
    
    # Sample stations data
    stations_data = [
        {
            "name": "MG Road Charging Hub",
            "latitude": 12.9716,
            "longitude": 77.5946,
            "type": "hybrid",
            "price_per_hour": 50,
            "battery_swap": True,
            "address": "MG Road, Bangalore, Karnataka",
            "total_slots": 20,
            "available_slots": 15,
            "rating": 4.5,
            "amenities": json.dumps(["WiFi", "Restroom", "Coffee Shop", "Battery Swap"])
        },
        {
            "name": "Koramangala Parking Center",
            "latitude": 12.9352,
            "longitude": 77.6245,
            "type": "parking",
            "price_per_hour": 30,
            "battery_swap": False,
            "address": "Koramangala, Bangalore, Karnataka",
            "total_slots": 30,
            "available_slots": 25,
            "rating": 4.2,
            "amenities": json.dumps(["Security", "CCTV", "Valet Service"])
        },
        {
            "name": "Whitefield EV Station",
            "latitude": 12.9698,
            "longitude": 77.7500,
            "type": "charging",
            "price_per_hour": 40,
            "battery_swap": True,
            "address": "Whitefield, Bangalore, Karnataka",
            "total_slots": 15,
            "available_slots": 12,
            "rating": 4.7,
            "amenities": json.dumps(["WiFi", "Restroom", "Food Court", "Battery Swap", "Fast Charging"])
        },
        {
            "name": "Indiranagar Smart Hub",
            "latitude": 12.9719,
            "longitude": 77.6412,
            "type": "hybrid",
            "price_per_hour": 45,
            "battery_swap": True,
            "address": "Indiranagar, Bangalore, Karnataka",
            "total_slots": 25,
            "available_slots": 18,
            "rating": 4.3,
            "amenities": json.dumps(["WiFi", "Restroom", "Shopping", "Battery Swap"])
        },
        {
            "name": "Electronic City Parking",
            "latitude": 12.8456,
            "longitude": 77.6603,
            "type": "parking",
            "price_per_hour": 25,
            "battery_swap": False,
            "address": "Electronic City, Bangalore, Karnataka",
            "total_slots": 40,
            "available_slots": 35,
            "rating": 4.0,
            "amenities": json.dumps(["Security", "CCTV", "Covered Parking"])
        }
    ]
    
    # Create stations
    # created_stations = []
    # for station_data in stations_data:
    #     try:
    #         response = databases.create_document(
    #             database_id=DATABASE_ID,
    #             collection_id=STATIONS_COLLECTION_ID,
    #             document_id=ID.unique(),
    #             data=station_data
    #         )
    #         created_stations.append(response)
    #         print(f"✅ Created station: {station_data['name']}")
    #     except Exception as e:
    #         print(f"❌ Error creating station {station_data['name']}: {e}")
    
    # Create slots for each station
    # total_slots_created = 0
    # for station in created_stations:
    #     station_id = station['$id']
    #     total_slots = station['total_slots']
    #     station_type = station['type']
        
    #     print(f"📦 Creating {total_slots} slots for {station['name']}...")
        
    #     for i in range(total_slots):
    #         slot_data = {
    #             "station_id": station_id,
    #             "slot_number": i + 1,
    #             "type": "parking_space" if station_type == "parking" else "charging_pad",
    #             "status": "available",
    #             "last_updated": datetime.now(timezone.utc).isoformat()
    #         }
            
    #         # Add battery status for charging pads
    #         if station_type in ['charging', 'hybrid']:
    #             battery_statuses = ["charged", "charging", "empty"]
    #             slot_data["battery_status"] = battery_statuses[i % len(battery_statuses)]
            
    #         try:
    #             response = databases.create_document(
    #                 database_id=DATABASE_ID,
    #                 collection_id=SLOTS_COLLECTION_ID,
    #                 document_id=ID.unique(),
    #                 data=slot_data
    #             )
    #             total_slots_created += 1
    #         except Exception as e:
    #             print(f"❌ Error creating slot {i+1} for station {station['name']}: {e}")
    
    # Create sample users
    users_data = [
        {
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "+91 9876543210",
            "loyalty_points": 150,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "preferences": json.dumps({
                "notifications": True,
                "dark_mode": False,
                "favorite_stations": []
            })
        },
        {
            "name": "Jane Smith",
            "email": "jane@example.com",
            "phone": "+91 9876543211",
            "loyalty_points": 75,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "preferences": json.dumps({
                "notifications": True,
                "dark_mode": True,
                "favorite_stations": []
            })
        }
    ]
    
    for user_data in users_data:
        try:
            response = databases.create_document(
                database_id=DATABASE_ID,
                collection_id=USERS_COLLECTION_ID,
                document_id=ID.unique(),
                data=user_data
            )
            print(f"✅ Created user: {user_data['name']}")
        except Exception as e:
            print(f"❌ Error creating user {user_data['name']}: {e}")
    
    # Create sample bookings
    if created_stations and total_slots_created > 0:
        # Get some slots to create bookings
        try:
            slots_response = databases.list_documents(
                database_id=DATABASE_ID,
                collection_id=SLOTS_COLLECTION_ID
            )
            sample_slots = slots_response['documents']
            
            for i, slot in enumerate(sample_slots):
                booking_data = {
                    "user_id": "demo_user_" + str(i + 1),
                    "station_id": slot['station_id'],
                    "slot_id": slot['$id'],
                    "status": "completed" if i % 2 == 0 else "active",
                    "start_time": datetime.utcnow().isoformat() + 'Z',
                    "end_time": datetime.utcnow().isoformat() + 'Z' if i % 2 == 0 else None,
                    "price": 50.0 + (i * 10),
                    "notes": f"Demo booking {i + 1}",
                    "created_at": datetime.utcnow().isoformat() + 'Z'
                }
                
                try:
                    response = databases.create_document(
                        database_id=DATABASE_ID,
                        collection_id=BOOKINGS_COLLECTION_ID,
                        document_id=ID.unique(),
                        data=booking_data
                    )
                    print(f"✅ Created booking: {response['$id']}")
                except Exception as e:
                    print(f"❌ Error creating booking: {e}")
                    
        except Exception as e:
            print(f"❌ Error fetching slots for bookings: {e}")
    
    print(f"\n🎉 Demo data initialization complete!")
    print(f"📊 Created {len(created_stations)} stations")
    print(f"📦 Created {total_slots_created} slots")
    print(f"👥 Created {len(users_data)} users")
    print(f"📋 Created sample bookings")
    print(f"\n🚀 You can now run the Flutter app and Python simulation!")

if __name__ == "__main__":
    initialize_demo_data()
