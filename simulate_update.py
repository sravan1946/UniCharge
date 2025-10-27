#!/usr/bin/env python3
"""
UniCharge Simulation Script
Simulates real-time updates to parking and charging slots using Appwrite
"""

import time
import random
import json
from datetime import datetime
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID

import os

# Appwrite Configuration from environment variables
APPWRITE_ENDPOINT = os.getenv('APPWRITE_ENDPOINT', 'https://cloud.appwrite.io/v1')
PROJECT_ID = os.getenv('APPWRITE_PROJECT_ID', 'YOUR_PROJECT_ID')
API_KEY = os.getenv('APPWRITE_API_KEY', 'YOUR_API_KEY')
DATABASE_ID = os.getenv('APPWRITE_DATABASE_ID', 'parkcharge_db')

# Collection IDs from environment variables
STATIONS_COLLECTION_ID = os.getenv('APPWRITE_STATIONS_COLLECTION_ID', 'stations')
SLOTS_COLLECTION_ID = os.getenv('APPWRITE_SLOTS_COLLECTION_ID', 'slots')
BOOKINGS_COLLECTION_ID = os.getenv('APPWRITE_BOOKINGS_COLLECTION_ID', 'bookings')

class UniChargeSimulator:
    def __init__(self):
        self.client = Client()
        self.client.set_endpoint(APPWRITE_ENDPOINT)
        self.client.set_project(PROJECT_ID)
        self.client.set_key(API_KEY)
        
        self.databases = Databases(self.client)
        self.stations = []
        self.slots = []
        
    def initialize_data(self):
        """Initialize sample stations and slots"""
        print("Initializing sample data...")
        
        # Create sample stations
        sample_stations = [
            {
                "name": "MG Road Charging Hub",
                "latitude": 12.9716,
                "longitude": 77.5946,
                "type": "hybrid",
                "price_per_hour": 50,
                "battery_swap": True,
                "address": "MG Road, Bangalore",
                "total_slots": 20,
                "available_slots": 15,
                "rating": 4.5,
                "amenities": ["WiFi", "Restroom", "Coffee Shop"]
            },
            {
                "name": "Koramangala Parking Center",
                "latitude": 12.9352,
                "longitude": 77.6245,
                "type": "parking",
                "price_per_hour": 30,
                "battery_swap": False,
                "address": "Koramangala, Bangalore",
                "total_slots": 30,
                "available_slots": 25,
                "rating": 4.2,
                "amenities": ["Security", "CCTV"]
            },
            {
                "name": "Whitefield EV Station",
                "latitude": 12.9698,
                "longitude": 77.7500,
                "type": "charging",
                "price_per_hour": 40,
                "battery_swap": True,
                "address": "Whitefield, Bangalore",
                "total_slots": 15,
                "available_slots": 12,
                "rating": 4.7,
                "amenities": ["WiFi", "Restroom", "Food Court", "Battery Swap"]
            }
        ]
        
        # Create stations in Appwrite
        for station_data in sample_stations:
            try:
                response = self.databases.create_document(
                    database_id=DATABASE_ID,
                    collection_id=STATIONS_COLLECTION_ID,
                    document_id=ID.unique(),
                    data=station_data
                )
                self.stations.append(response)
                print(f"Created station: {station_data['name']}")
            except Exception as e:
                print(f"Error creating station {station_data['name']}: {e}")
        
        # Create slots for each station
        for station in self.stations:
            station_id = station['$id']
            total_slots = station['total_slots']
            
            for i in range(total_slots):
                slot_data = {
                    "station_id": station_id,
                    "slot_index": i + 1,
                    "type": "parking_space" if station['type'] == 'parking' else "charging_pad",
                    "status": "available",
                    "last_updated": datetime.utcnow().isoformat() + 'Z'
                }
                
                # Add battery status for charging pads
                if station['type'] in ['charging', 'hybrid']:
                    slot_data["battery_status"] = random.choice(["charged", "charging", "empty"])
                
                try:
                    response = self.databases.create_document(
                        database_id=DATABASE_ID,
                        collection_id=SLOTS_COLLECTION_ID,
                        document_id=ID.unique(),
                        data=slot_data
                    )
                    self.slots.append(response)
                except Exception as e:
                    print(f"Error creating slot {i+1} for station {station['name']}: {e}")
        
        print(f"Initialized {len(self.stations)} stations with {len(self.slots)} slots")
    
    def simulate_slot_changes(self):
        """Simulate random slot status changes"""
        print("Starting simulation...")
        
        while True:
            try:
                # Get current slots
                response = self.databases.list_documents(
                    database_id=DATABASE_ID,
                    collection_id=SLOTS_COLLECTION_ID
                )
                current_slots = response['documents']
                
                if not current_slots:
                    print("No slots found. Run initialize_data() first.")
                    break
                
                # Randomly select a slot to update
                slot = random.choice(current_slots)
                current_status = slot['status']
                
                # Determine new status based on current status
                if current_status == 'available':
                    new_status = random.choice(['occupied', 'reserved'])
                elif current_status == 'occupied':
                    new_status = random.choice(['available', 'maintenance'])
                elif current_status == 'reserved':
                    new_status = random.choice(['occupied', 'available'])
                elif current_status == 'maintenance':
                    new_status = 'available'
                else:
                    new_status = 'available'
                
                # Update slot
                update_data = {
                    'status': new_status,
                    'last_updated': datetime.utcnow().isoformat() + 'Z'
                }
                
                # Add random battery status changes for charging pads
                if slot['type'] == 'charging_pad' and random.random() < 0.3:
                    battery_statuses = ['charged', 'charging', 'swapped', 'empty']
                    update_data['battery_status'] = random.choice(battery_statuses)
                
                self.databases.update_document(
                    database_id=DATABASE_ID,
                    collection_id=SLOTS_COLLECTION_ID,
                    document_id=slot['$id'],
                    data=update_data
                )
                
                print(f"Updated slot {slot['slot_index']} at station {slot['station_id']}: {current_status} -> {new_status}")
                
                # Update station available slots count
                self._update_station_availability(slot['station_id'])
                
            except Exception as e:
                print(f"Error in simulation: {e}")
            
            # Wait before next update
            time.sleep(random.uniform(3, 8))
    
    def _update_station_availability(self, station_id):
        """Update the available slots count for a station"""
        try:
            # Count available slots for this station
            response = self.databases.list_documents(
                database_id=DATABASE_ID,
                collection_id=SLOTS_COLLECTION_ID,
                queries=[f"station_id={station_id}"]
            )
            slots = response['documents']
            available_count = sum(1 for slot in slots if slot['status'] == 'available')
            
            # Update station
            self.databases.update_document(
                database_id=DATABASE_ID,
                collection_id=STATIONS_COLLECTION_ID,
                document_id=station_id,
                data={'available_slots': available_count}
            )
            
        except Exception as e:
            print(f"Error updating station availability: {e}")
    
    def simulate_booking_flow(self):
        """Simulate a complete booking flow"""
        print("Simulating booking flow...")
        
        try:
            # Get a random available slot
            response = self.databases.list_documents(
                database_id=DATABASE_ID,
                collection_id=SLOTS_COLLECTION_ID,
                queries=["status=available"]
            )
            available_slots = response['documents']
            
            if not available_slots:
                print("No available slots for booking simulation")
                return
            
            slot = random.choice(available_slots)
            
            # Create a booking
            booking_data = {
                "user_id": "demo_user_123",
                "station_id": slot['station_id'],
                "slot_id": slot['$id'],
                "status": "active",
                "start_time": datetime.utcnow().isoformat() + 'Z',
                "price": 50.0,
                "notes": "Simulated booking",
                "created_at": datetime.utcnow().isoformat() + 'Z'
            }
            
            booking_response = self.databases.create_document(
                database_id=DATABASE_ID,
                collection_id=BOOKINGS_COLLECTION_ID,
                document_id=ID.unique(),
                data=booking_data
            )
            
            print(f"Created booking: {booking_response['$id']}")
            
            # Update slot to reserved
            self.databases.update_document(
                database_id=DATABASE_ID,
                collection_id=SLOTS_COLLECTION_ID,
                document_id=slot['$id'],
                data={
                    'status': 'reserved',
                    'reserved_by': 'demo_user_123',
                    'last_updated': datetime.utcnow().isoformat() + 'Z'
                }
            )
            
            print(f"Reserved slot {slot['slot_index']}")
            
            # Simulate slot becoming occupied after some time
            time.sleep(5)
            self.databases.update_document(
                database_id=DATABASE_ID,
                collection_id=SLOTS_COLLECTION_ID,
                document_id=slot['$id'],
                data={
                    'status': 'occupied',
                    'occupied_by': 'demo_user_123',
                    'last_updated': datetime.utcnow().isoformat() + 'Z'
                }
            )
            
            print(f"Slot {slot['slot_index']} is now occupied")
            
        except Exception as e:
            print(f"Error in booking simulation: {e}")

def main():
    simulator = UniChargeSimulator()
    
    print("UniCharge Simulation Script")
    print("=" * 40)
    print("1. Initialize sample data")
    print("2. Start slot simulation")
    print("3. Simulate booking flow")
    print("4. Exit")
    
    while True:
        try:
            choice = input("\nEnter your choice (1-4): ").strip()
            
            if choice == '1':
                simulator.initialize_data()
            elif choice == '2':
                simulator.simulate_slot_changes()
            elif choice == '3':
                simulator.simulate_booking_flow()
            elif choice == '4':
                print("Exiting...")
                break
            else:
                print("Invalid choice. Please enter 1-4.")
                
        except KeyboardInterrupt:
            print("\nSimulation stopped by user.")
            break
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    main()
