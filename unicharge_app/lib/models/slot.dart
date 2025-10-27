enum SlotStatus {
  available,
  occupied,
  reserved,
  maintenance,
}

enum SlotType {
  parkingSpace,
  chargingPad,
}

enum BatteryStatus {
  charged,
  charging,
  swapped,
  empty,
}

class Slot {
  final String id;
  final String stationId;
  final int slotIndex;
  final SlotType type;
  final SlotStatus status;
  final BatteryStatus? batteryStatus;
  final DateTime lastUpdated;
  final String? reservedBy;
  final String? occupiedBy;

  Slot({
    required this.id,
    required this.stationId,
    required this.slotIndex,
    required this.type,
    required this.status,
    this.batteryStatus,
    required this.lastUpdated,
    this.reservedBy,
    this.occupiedBy,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['\$id'] ?? json['id'] ?? '',
      stationId: json['station_id'] ?? '',
      slotIndex: json['slot_index'] ?? 0,
      type: SlotType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SlotType.parkingSpace,
      ),
      status: SlotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SlotStatus.available,
      ),
      batteryStatus: json['battery_status'] != null
          ? BatteryStatus.values.firstWhere(
              (e) => e.name == json['battery_status'],
              orElse: () => BatteryStatus.charged,
            )
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
      reservedBy: json['reserved_by'],
      occupiedBy: json['occupied_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'slot_index': slotIndex,
      'type': type.name,
      'status': status.name,
      'battery_status': batteryStatus?.name,
      'last_updated': lastUpdated.toIso8601String(),
      'reserved_by': reservedBy,
      'occupied_by': occupiedBy,
    };
  }

  Slot copyWith({
    String? id,
    String? stationId,
    int? slotIndex,
    SlotType? type,
    SlotStatus? status,
    BatteryStatus? batteryStatus,
    DateTime? lastUpdated,
    String? reservedBy,
    String? occupiedBy,
  }) {
    return Slot(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      slotIndex: slotIndex ?? this.slotIndex,
      type: type ?? this.type,
      status: status ?? this.status,
      batteryStatus: batteryStatus ?? this.batteryStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      reservedBy: reservedBy ?? this.reservedBy,
      occupiedBy: occupiedBy ?? this.occupiedBy,
    );
  }

  bool get isAvailable => status == SlotStatus.available;
  bool get isOccupied => status == SlotStatus.occupied;
  bool get isReserved => status == SlotStatus.reserved;
  bool get isMaintenance => status == SlotStatus.maintenance;
}
