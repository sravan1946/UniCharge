#!/usr/bin/env python3
"""
ParkCharge Sample Data Setup Script

This script populates the Appwrite database with sample stations, slots, and initial data
for the ParkCharge demo.

Usage:
    python setup_appwrite_data.py
"""

import os
import sys
from datetime import datetime
from typing import List, Dict, Any

try:
    from appwrite.client import Client
    from appwrite.services.databases import Databases
    from appwrite.id import ID
except ImportError:
    print("Error: Appwrite Python SDK not installed.")
    print("Please install it with: pip install appwrite")
    sys.exit(1)

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    print("Warning: python-dotenv not installed. Using system environment variables.")

class ParkChargeDataSetup:
    def __init__(self):
        self.client = Client()
        self.client.set_endpoint(os.getenv('APPWRITE_ENDPOINT', 'https://appwrite.p1ng.me/v1'))
        self.client.set_project(os.getenv('APPWRITE_PROJECT_ID', 'your-project-id'))
        self.client.set_key(os.getenv('APPWRITE_API_KEY', 'your-api-key'))
        
        self.databases = Databases(self.client)
        self.database_id = os.getenv('DATABASE_ID', 'parkcharge_db')
        self.stations_collection_id = os.getenv('STATIONS_COLLECTION_ID', 'stations')
        self.slots_collection_id = os.getenv('SLOTS_COLLECTION_ID', 'slots')
        self.bookings_collection_id = os.getenv('BOOKINGS_COLLECTION_ID', 'bookings')
        self.users_collection_id = os.getenv('USERS_COLLECTION_ID', 'users')
        
    def setup_database(self):
        """Create database and collections if they don't exist"""
        try:
            # Create database
            try:
                self.databases.create(
                    database_id=self.database_id,
                    name='ParkCharge Database',
                    enabled=True
                )
                print(f"Created database: {self.database_id}")
            except Exception as e:
                if "already exists" in str(e).lower():
                    print(f"Database {self.database_id} already exists")
                else:
                    raise e
            
            # Create collections
            collections = [
                {
                    'id': self.stations_collection_id,
                    'name': 'Stations',
                    'attributes': [
                        {'key': 'name', 'type': 'string', 'size': 100, 'required': True},
                        {'key': 'address', 'type': 'string', 'size': 200, 'required': True},
                        {'key': 'latitude', 'type': 'double', 'required': True},
                        {'key': 'longitude', 'type': 'double', 'required': True},
                        {'key': 'type', 'type': 'string', 'size': 20, 'required': True},
                        {'key': 'pricePerHour', 'type': 'double', 'required': True},
                        {'key': 'batterySwap', 'type': 'boolean', 'required': True},
                        {'key': 'totalSlots', 'type': 'integer', 'required': True},
                        {'key': 'availableSlots', 'type': 'integer', 'required': True},
                        {'key': 'imageUrl', 'type': 'string', 'size': 500},
                        {'key': 'amenities', 'type': 'string', 'size': 1000},
                        {'key': 'createdAt', 'type': 'datetime', 'required': True},
                        {'key': 'updatedAt', 'type': 'datetime', 'required': True},
                    ]
                },
                {
                    'id': self.slots_collection_id,
                    'name': 'Slots',
                    'attributes': [
                        {'key': 'stationId', 'type': 'string', 'size': 50, 'required': True},
                        {'key': 'slotIndex', 'type': 'integer', 'required': True},
                        {'key': 'type', 'type': 'string', 'size': 20, 'required': True},
                        {'key': 'status', 'type': 'string', 'size': 20, 'required': True},
                        {'key': 'batteryStatus', 'type': 'string', 'size': 20},
                        {'key': 'lastUpdated', 'type': 'datetime', 'required': True},
                        {'key': 'reservedByUserId', 'type': 'string', 'size': 50},
                        {'key': 'reservedUntil', 'type': 'datetime'},
                    ]
                },
                {
                    'id': self.bookings_collection_id,
                    'name': 'Bookings',
                    'attributes': [
                        {'key': 'userId', 'type': 'string', 'size': 50, 'required': True},
                        {'key': 'stationId', 'type': 'string', 'size': 50, 'required': True},
                        {'key': 'slotId', 'type': 'string', 'size': 50, 'required': True},
                        {'key': 'status', 'type': 'string', 'size': 20, 'required': True},
                        {'key': 'startTime', 'type': 'datetime', 'required': True},
                        {'key': 'endTime', 'type': 'datetime'},
                        {'key': 'pricePerHour', 'type': 'double', 'required': True},
                        {'key': 'durationHours', 'type': 'integer', 'required': True},
                        {'key': 'totalPrice', 'type': 'double', 'required': True},
                        {'key': 'createdAt', 'type': 'datetime', 'required': True},
                        {'key': 'cancelledAt', 'type': 'datetime'},
                        {'key': 'cancellationReason', 'type': 'string', 'size': 200},
                    ]
                },
                {
                    'id': self.users_collection_id,
                    'name': 'Users',
                    'attributes': [
                        {'key': 'email', 'type': 'string', 'size': 100, 'required': True},
                        {'key': 'name', 'type': 'string', 'size': 100, 'required': True},
                        {'key': 'phoneNumber', 'type': 'string', 'size': 20},
                        {'key': 'profileImageUrl', 'type': 'string', 'size': 500},
                        {'key': 'totalBookings', 'type': 'integer', 'required': True},
                        {'key': 'totalHoursParked', 'type': 'double', 'required': True},
                        {'key': 'loyaltyPoints', 'type': 'integer', 'required': True},
                        {'key': 'createdAt', 'type': 'datetime', 'required': True},
                        {'key': 'updatedAt', 'type': 'datetime', 'required': True},
                        {'key': 'preferences', 'type': 'string', 'size': 1000},
                    ]
                }
            ]
            
            for collection in collections:
                try:
                    self.databases.create_collection(
                        database_id=self.database_id,
                        collection_id=collection['id'],
                        name=collection['name'],
                        permissions=['read("any")', 'write("any")']
                    )
                    print(f"Created collection: {collection['id']}")
                    
                    # Add attributes
                    for attr in collection['attributes']:
                        try:
                            self.databases.create_string_attribute(
                                database_id=self.database_id,
                                collection_id=collection['id'],
                                key=attr['key'],
                                size=attr.get('size', 255),
                                required=attr.get('required', False)
                            )
                        except Exception as e:
                            if 'already exists' not in str(e).lower():
                                print(f"Error creating string attribute {attr['key']}: {e}")
                    
                except Exception as e:
                    if "already exists" in str(e).lower():
                        print(f"Collection {collection['id']} already exists")
                    else:
                        print(f"Error creating collection {collection['id']}: {e}")
                        
        except Exception as e:
            print(f"Error setting up database: {e}")
            sys.exit(1)
    
    def create_sample_stations(self):
        """Create sample stations"""
        sample_stations = [
            {
                'name': 'MG Road Charging Hub',
                'address': 'MG Road, Bangalore, Karnataka 560001',
                'latitude': 12.9716,
                'longitude': 77.5946,
                'type': 'hybrid',
                'pricePerHour': 50.0,
                'batterySwap': True,
                'totalSlots': 20,
                'availableSlots': 15,
                'imageUrl': 'https://example.com/mg-road-hub.jpg',
                'amenities': 'WiFi,Restroom,Café,24/7 Access',
            },
            {
                'name': 'Koramangala Tech Park',
                'address': 'Koramangala, Bangalore, Karnataka 560034',
                'latitude': 12.9352,
                'longitude': 77.6245,
                'type': 'hybrid',
                'pricePerHour': 45.0,
                'batterySwap': False,
                'totalSlots': 30,
                'availableSlots': 22,
                'imageUrl': 'https://example.com/koramangala-tech.jpg',
                'amenities': 'WiFi,Restroom,Security',
            },
            {
                'name': 'Whitefield Mall Station',
                'address': 'Whitefield, Bangalore, Karnataka 560066',
                'latitude': 12.9698,
                'longitude': 77.7500,
                'type': 'charging',
                'pricePerHour': 60.0,
                'batterySwap': True,
                'totalSlots': 15,
                'availableSlots': 8,
                'imageUrl': 'https://example.com/whitefield-mall.jpg',
                'amenities': 'WiFi,Shopping Mall,Food Court',
            },
            {
                'name': 'Indiranagar Metro Station',
                'address': 'Indiranagar, Bangalore, Karnataka 560038',
                'latitude': 12.9719,
                'longitude': 77.6412,
                'type': 'parking',
                'pricePerHour': 30.0,
                'batterySwap': False,
                'totalSlots': 50,
                'availableSlots': 35,
                'imageUrl': 'https://example.com/indiranagar-metro.jpg',
                'amenities': 'Metro Access,WiFi,Security',
            },
            {
                'name': 'Electronic City Hub',
                'address': 'Electronic City, Bangalore, Karnataka 560100',
                'latitude': 12.8456,
                'longitude': 77.6603,
                'type': 'hybrid',
                'pricePerHour': 40.0,
                'batterySwap': True,
                'totalSlots': 25,
                'availableSlots': 18,
                'imageUrl': 'https://example.com/electronic-city.jpg',
                'amenities': 'WiFi,Restroom,Café,24/7 Access',
            }
        ]
        
        created_stations = []
        current_time = datetime.utcnow().isoformat() + 'Z'
        
        for station_data in sample_stations:
            try:
                station_id = ID.unique()
                document_data = {
                    **station_data,
                    'createdAt': current_time,
                    'updatedAt': current_time,
                }
                
                self.databases.create_document(
                    database_id=self.database_id,
                    collection_id=self.stations_collection_id,
                    document_id=station_id,
                    data=document_data
                )
                
                created_stations.append(station_id)
                print(f"Created station: {station_data['name']} ({station_id})")
                
            except Exception as e:
                print(f"Error creating station {station_data['name']}: {e}")
        
        return created_stations
    
    def create_sample_slots(self, station_ids: List[str]):
        """Create sample slots for each station"""
        slot_types = ['parking_space', 'charging_pad']
        slot_statuses = ['available', 'occupied', 'maintenance']
        battery_statuses = ['charged', 'charging', 'empty', 'swapped']
        
        created_slots = []
        current_time = datetime.utcnow().isoformat() + 'Z'
        
        for station_id in station_ids:
            # Get station data to determine slot count
            try:
                station_doc = self.databases.get_document(
                    database_id=self.database_id,
                    collection_id=self.stations_collection_id,
                    document_id=station_id
                )
                total_slots = station_doc.get('totalSlots', 10)
                station_type = station_doc.get('type', 'hybrid')
                
                # Create slots
                for i in range(total_slots):
                    slot_id = ID.unique()
                    
                    # Determine slot type based on station type
                    if station_type == 'charging':
                        slot_type = 'charging_pad'
                    elif station_type == 'parking':
                        slot_type = 'parking_space'
                    else:  # hybrid
                        slot_type = slot_types[i % 2]  # Alternate between parking and charging
                    
                    # Determine initial status (mostly available)
                    if i < total_slots * 0.8:  # 80% available
                        status = 'available'
                    elif i < total_slots * 0.95:  # 15% occupied
                        status = 'occupied'
                    else:  # 5% maintenance
                        status = 'maintenance'
                    
                    # Battery status for charging pads
                    battery_status = None
                    if slot_type == 'charging_pad':
                        if status == 'available':
                            battery_status = 'charged'
                        elif status == 'occupied':
                            battery_status = 'charging'
                        else:
                            battery_status = 'empty'
                    
                    slot_data = {
                        'stationId': station_id,
                        'slotIndex': i + 1,
                        'type': slot_type,
                        'status': status,
                        'lastUpdated': current_time,
                    }
                    
                    if battery_status:
                        slot_data['batteryStatus'] = battery_status
                    
                    self.databases.create_document(
                        database_id=self.database_id,
                        collection_id=self.slots_collection_id,
                        document_id=slot_id,
                        data=slot_data
                    )
                    
                    created_slots.append(slot_id)
                
                print(f"Created {total_slots} slots for station {station_id}")
                
            except Exception as e:
                print(f"Error creating slots for station {station_id}: {e}")
        
        return created_slots
    
    def create_sample_users(self):
        """Create sample user profiles"""
        sample_users = [
            {
                'email': 'john.doe@example.com',
                'name': 'John Doe',
                'phoneNumber': '+91 9876543210',
                'totalBookings': 24,
                'totalHoursParked': 156.5,
                'loyaltyPoints': 2450,
            },
            {
                'email': 'jane.smith@example.com',
                'name': 'Jane Smith',
                'phoneNumber': '+91 9876543211',
                'totalBookings': 18,
                'totalHoursParked': 98.0,
                'loyaltyPoints': 1800,
            },
            {
                'email': 'mike.wilson@example.com',
                'name': 'Mike Wilson',
                'phoneNumber': '+91 9876543212',
                'totalBookings': 32,
                'totalHoursParked': 210.0,
                'loyaltyPoints': 3200,
            }
        ]
        
        created_users = []
        current_time = datetime.utcnow().isoformat() + 'Z'
        
        for user_data in sample_users:
            try:
                user_id = ID.unique()
                document_data = {
                    **user_data,
                    'createdAt': current_time,
                    'updatedAt': current_time,
                    'preferences': '{"notifications": true, "darkMode": false}',
                }
                
                self.databases.create_document(
                    database_id=self.database_id,
                    collection_id=self.users_collection_id,
                    document_id=user_id,
                    data=document_data
                )
                
                created_users.append(user_id)
                print(f"Created user: {user_data['name']} ({user_id})")
                
            except Exception as e:
                print(f"Error creating user {user_data['name']}: {e}")
        
        return created_users
    
    def run_setup(self):
        """Run the complete setup process"""
        print("Starting ParkCharge data setup...")
        
        # Setup database and collections
        self.setup_database()
        
        # Create sample data
        print("\nCreating sample stations...")
        station_ids = self.create_sample_stations()
        
        print("\nCreating sample slots...")
        slot_ids = self.create_sample_slots(station_ids)
        
        print("\nCreating sample users...")
        user_ids = self.create_sample_users()
        
        print(f"\nSetup complete!")
        print(f"Created {len(station_ids)} stations")
        print(f"Created {len(slot_ids)} slots")
        print(f"Created {len(user_ids)} users")
        print("\nYou can now run the simulation script to see live updates!")

def main():
    # Check environment variables
    required_vars = ['APPWRITE_ENDPOINT', 'APPWRITE_PROJECT_ID', 'APPWRITE_API_KEY']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"Error: Missing required environment variables: {', '.join(missing_vars)}")
        print("Please set them in your .env file or environment")
        sys.exit(1)
    
    # Run setup
    setup = ParkChargeDataSetup()
    setup.run_setup()

if __name__ == '__main__':
    main()
