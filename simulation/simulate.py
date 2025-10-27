#!/usr/bin/env python3
"""
ParkCharge Simulation Script

This script simulates real-time updates to the ParkCharge Appwrite database,
including slot occupancy changes, battery swaps, and vehicle arrivals/departures.

Usage:
    python simulate.py --mode random
    python simulate.py --mode realistic
    python simulate.py --mode interactive
"""

import os
import sys
import time
import random
import argparse
from datetime import datetime, timedelta
from typing import List, Dict, Any
import asyncio

try:
    from appwrite.client import Client
    from appwrite.services.databases import Databases
    from appwrite.query import Query
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

class ParkChargeSimulator:
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
        
        self.stations = []
        self.slots = []
        self.bookings = []
        
    def load_data(self):
        """Load stations, slots, and bookings from Appwrite"""
        try:
            # Load stations
            stations_result = self.databases.list_documents(
                database_id=self.database_id,
                collection_id=self.stations_collection_id,
                queries=[Query.limit(100)]
            )
            self.stations = stations_result.get('documents', [])
            print(f"Loaded {len(self.stations)} stations")
            
            # Load slots
            slots_result = self.databases.list_documents(
                database_id=self.database_id,
                collection_id=self.slots_collection_id,
                queries=[Query.limit(1000)]
            )
            self.slots = slots_result.get('documents', [])
            print(f"Loaded {len(self.slots)} slots")
            
            # Load bookings
            bookings_result = self.databases.list_documents(
                database_id=self.database_id,
                collection_id=self.bookings_collection_id,
                queries=[Query.limit(100)]
            )
            self.bookings = bookings_result.get('documents', [])
            print(f"Loaded {len(self.bookings)} bookings")
            
        except Exception as e:
            print(f"Error loading data: {e}")
            sys.exit(1)
    
    def update_slot_status(self, slot_id: str, status: str, battery_status: str = None, reserved_by_user_id: str = None):
        """Update a slot's status in Appwrite"""
        try:
            update_data = {
                'status': status,
                'lastUpdated': datetime.utcnow().isoformat() + 'Z'
            }
            
            if battery_status:
                update_data['batteryStatus'] = battery_status
            if reserved_by_user_id:
                update_data['reservedByUserId'] = reserved_by_user_id
                update_data['reservedUntil'] = (datetime.utcnow() + timedelta(minutes=15)).isoformat() + 'Z'
            
            self.databases.update_document(
                database_id=self.database_id,
                collection_id=self.slots_collection_id,
                document_id=slot_id,
                data=update_data
            )
            
            print(f"Updated slot {slot_id} -> {status}")
            return True
            
        except Exception as e:
            print(f"Error updating slot {slot_id}: {e}")
            return False
    
    def simulate_random_changes(self):
        """Simulate random slot status changes"""
        print("Starting random simulation mode...")
        
        while True:
            try:
                # Pick a random slot
                if not self.slots:
                    print("No slots available for simulation")
                    break
                
                slot = random.choice(self.slots)
                current_status = slot.get('status', 'available')
                
                # Randomly change status
                if current_status == 'available':
                    new_status = 'occupied'
                    battery_status = 'charging' if slot.get('type') == 'charging_pad' else None
                elif current_status == 'occupied':
                    new_status = 'available'
                    battery_status = 'charged' if slot.get('type') == 'charging_pad' else None
                else:
                    new_status = 'available'
                    battery_status = None
                
                # Update slot
                if self.update_slot_status(slot['$id'], new_status, battery_status):
                    # Update local cache
                    slot['status'] = new_status
                    if battery_status:
                        slot['batteryStatus'] = battery_status
                    slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                
                # Wait before next change
                time.sleep(random.uniform(3, 8))
                
            except KeyboardInterrupt:
                print("\nSimulation stopped by user")
                break
            except Exception as e:
                print(f"Error in simulation: {e}")
                time.sleep(5)
    
    def simulate_realistic_patterns(self):
        """Simulate realistic vehicle arrival/departure patterns"""
        print("Starting realistic simulation mode...")
        
        # Peak hours: 8-10 AM, 6-8 PM
        peak_hours = [(8, 10), (18, 20)]
        
        while True:
            try:
                current_hour = datetime.now().hour
                is_peak_hour = any(start <= current_hour < end for start, end in peak_hours)
                
                # Adjust probability based on time
                if is_peak_hour:
                    arrival_probability = 0.7
                    departure_probability = 0.3
                else:
                    arrival_probability = 0.3
                    departure_probability = 0.2
                
                # Simulate arrivals
                if random.random() < arrival_probability:
                    self._simulate_vehicle_arrival()
                
                # Simulate departures
                if random.random() < departure_probability:
                    self._simulate_vehicle_departure()
                
                # Battery swap simulation
                if random.random() < 0.1:  # 10% chance
                    self._simulate_battery_swap()
                
                time.sleep(random.uniform(2, 6))
                
            except KeyboardInterrupt:
                print("\nSimulation stopped by user")
                break
            except Exception as e:
                print(f"Error in simulation: {e}")
                time.sleep(5)
    
    def _simulate_vehicle_arrival(self):
        """Simulate a vehicle arriving and occupying a slot"""
        available_slots = [slot for slot in self.slots if slot.get('status') == 'available']
        
        if available_slots:
            slot = random.choice(available_slots)
            battery_status = 'charging' if slot.get('type') == 'charging_pad' else None
            
            if self.update_slot_status(slot['$id'], 'occupied', battery_status):
                slot['status'] = 'occupied'
                if battery_status:
                    slot['batteryStatus'] = battery_status
                slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                print(f"Vehicle arrived at slot {slot['$id']}")
    
    def _simulate_vehicle_departure(self):
        """Simulate a vehicle departing and freeing a slot"""
        occupied_slots = [slot for slot in self.slots if slot.get('status') == 'occupied']
        
        if occupied_slots:
            slot = random.choice(occupied_slots)
            battery_status = 'charged' if slot.get('type') == 'charging_pad' else None
            
            if self.update_slot_status(slot['$id'], 'available', battery_status):
                slot['status'] = 'available'
                if battery_status:
                    slot['batteryStatus'] = battery_status
                slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                print(f"Vehicle departed from slot {slot['$id']}")
    
    def _simulate_battery_swap(self):
        """Simulate a battery swap on a charging pad"""
        charging_slots = [
            slot for slot in self.slots 
            if slot.get('type') == 'charging_pad' and slot.get('status') == 'occupied'
        ]
        
        if charging_slots:
            slot = random.choice(charging_slots)
            current_battery_status = slot.get('batteryStatus', 'charging')
            
            # Simulate battery swap
            if current_battery_status == 'charging':
                new_battery_status = 'swapped'
            else:
                new_battery_status = 'charging'
            
            if self.update_slot_status(slot['$id'], 'occupied', new_battery_status):
                slot['batteryStatus'] = new_battery_status
                slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                print(f"Battery swap at slot {slot['$id']} -> {new_battery_status}")
    
    def interactive_mode(self):
        """Interactive mode for manual control"""
        print("Starting interactive mode...")
        print("Commands:")
        print("  arrive <station_id> - Simulate vehicle arrival")
        print("  depart <station_id> - Simulate vehicle departure")
        print("  swap <station_id> - Simulate battery swap")
        print("  status - Show current status")
        print("  quit - Exit")
        
        while True:
            try:
                command = input("\n> ").strip().lower().split()
                
                if not command:
                    continue
                
                if command[0] == 'quit':
                    break
                elif command[0] == 'status':
                    self._show_status()
                elif command[0] == 'arrive' and len(command) > 1:
                    self._manual_arrival(command[1])
                elif command[0] == 'depart' and len(command) > 1:
                    self._manual_departure(command[1])
                elif command[0] == 'swap' and len(command) > 1:
                    self._manual_battery_swap(command[1])
                else:
                    print("Invalid command")
                    
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"Error: {e}")
        
        print("Exiting interactive mode")
    
    def _show_status(self):
        """Show current status of all stations and slots"""
        print("\n=== Current Status ===")
        
        for station in self.stations:
            station_slots = [slot for slot in self.slots if slot.get('stationId') == station['$id']]
            available = len([slot for slot in station_slots if slot.get('status') == 'available'])
            occupied = len([slot for slot in station_slots if slot.get('status') == 'occupied'])
            total = len(station_slots)
            
            print(f"\n{station.get('name', 'Unknown')} ({station['$id']})")
            print(f"  Slots: {available}/{total} available, {occupied} occupied")
            
            for slot in station_slots:
                status = slot.get('status', 'unknown')
                battery_status = slot.get('batteryStatus', 'N/A')
                print(f"    Slot {slot.get('slotIndex', '?')}: {status} (battery: {battery_status})")
    
    def _manual_arrival(self, station_id: str):
        """Manually trigger vehicle arrival at a station"""
        station_slots = [slot for slot in self.slots if slot.get('stationId') == station_id]
        available_slots = [slot for slot in station_slots if slot.get('status') == 'available']
        
        if available_slots:
            slot = random.choice(available_slots)
            battery_status = 'charging' if slot.get('type') == 'charging_pad' else None
            
            if self.update_slot_status(slot['$id'], 'occupied', battery_status):
                slot['status'] = 'occupied'
                if battery_status:
                    slot['batteryStatus'] = battery_status
                slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                print(f"Vehicle arrived at slot {slot['$id']}")
        else:
            print(f"No available slots at station {station_id}")
    
    def _manual_departure(self, station_id: str):
        """Manually trigger vehicle departure from a station"""
        station_slots = [slot for slot in self.slots if slot.get('stationId') == station_id]
        occupied_slots = [slot for slot in station_slots if slot.get('status') == 'occupied']
        
        if occupied_slots:
            slot = random.choice(occupied_slots)
            battery_status = 'charged' if slot.get('type') == 'charging_pad' else None
            
            if self.update_slot_status(slot['$id'], 'available', battery_status):
                slot['status'] = 'available'
                if battery_status:
                    slot['batteryStatus'] = battery_status
                slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                print(f"Vehicle departed from slot {slot['$id']}")
        else:
            print(f"No occupied slots at station {station_id}")
    
    def _manual_battery_swap(self, station_id: str):
        """Manually trigger battery swap at a station"""
        station_slots = [slot for slot in self.slots if slot.get('stationId') == station_id]
        charging_slots = [
            slot for slot in station_slots 
            if slot.get('type') == 'charging_pad' and slot.get('status') == 'occupied'
        ]
        
        if charging_slots:
            slot = random.choice(charging_slots)
            current_battery_status = slot.get('batteryStatus', 'charging')
            new_battery_status = 'swapped' if current_battery_status == 'charging' else 'charging'
            
            if self.update_slot_status(slot['$id'], 'occupied', new_battery_status):
                slot['batteryStatus'] = new_battery_status
                slot['lastUpdated'] = datetime.utcnow().isoformat() + 'Z'
                print(f"Battery swap at slot {slot['$id']} -> {new_battery_status}")
        else:
            print(f"No charging slots available for battery swap at station {station_id}")

def main():
    parser = argparse.ArgumentParser(description='ParkCharge Simulation Script')
    parser.add_argument('--mode', choices=['random', 'realistic', 'interactive'], 
                       default='random', help='Simulation mode')
    
    args = parser.parse_args()
    
    # Check environment variables
    required_vars = ['APPWRITE_ENDPOINT', 'APPWRITE_PROJECT_ID', 'APPWRITE_API_KEY']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"Error: Missing required environment variables: {', '.join(missing_vars)}")
        print("Please set them in your .env file or environment")
        sys.exit(1)
    
    # Initialize simulator
    simulator = ParkChargeSimulator()
    
    try:
        # Load data
        simulator.load_data()
        
        # Run simulation based on mode
        if args.mode == 'random':
            simulator.simulate_random_changes()
        elif args.mode == 'realistic':
            simulator.simulate_realistic_patterns()
        elif args.mode == 'interactive':
            simulator.interactive_mode()
            
    except Exception as e:
        print(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
