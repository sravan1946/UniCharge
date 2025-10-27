enum StationType {
  parking,
  charging,
  hybrid;

  String get displayName {
    switch (this) {
      case StationType.parking:
        return 'Parking Only';
      case StationType.charging:
        return 'Charging Only';
      case StationType.hybrid:
        return 'Parking & Charging';
    }
  }
}

enum SlotStatus {
  available,
  occupied,
  reserved,
  maintenance;

  String get displayName {
    switch (this) {
      case SlotStatus.available:
        return 'Available';
      case SlotStatus.occupied:
        return 'Occupied';
      case SlotStatus.reserved:
        return 'Reserved';
      case SlotStatus.maintenance:
        return 'Maintenance';
    }
  }
}

enum SlotType {
  parkingSpace,
  chargingPad;

  String get displayName {
    switch (this) {
      case SlotType.parkingSpace:
        return 'Parking Space';
      case SlotType.chargingPad:
        return 'Charging Pad';
    }
  }
}

enum BatteryStatus {
  charged,
  charging,
  swapped,
  empty;

  String get displayName {
    switch (this) {
      case BatteryStatus.charged:
        return 'Charged';
      case BatteryStatus.charging:
        return 'Charging';
      case BatteryStatus.swapped:
        return 'Swapped';
      case BatteryStatus.empty:
        return 'Empty';
    }
  }
}

enum BookingStatus {
  pending,
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
